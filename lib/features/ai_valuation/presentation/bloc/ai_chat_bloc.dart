import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/valuation.dart';
import '../../domain/repositories/valuation_repository.dart';

/// Challenge ichida AI javobni oshkor qilishi uchun maqsad.
class AiRevealTarget extends Equatable {
  const AiRevealTarget({required this.carName, required this.correctPrice});

  final String carName;
  final int correctPrice;

  @override
  List<Object?> get props => [carName, correctPrice];
}

enum ChatRole { bot, user }

class ChatMessage extends Equatable {
  const ChatMessage(this.role, this.text);

  final ChatRole role;
  final String text;

  @override
  List<Object?> get props => [role, text];
}

sealed class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => const [];
}

/// [reveal] berilsa — challenge rejimi (AI oxirida to'g'ri javobni aytadi).
class AiChatStarted extends AiChatEvent {
  const AiChatStarted({this.reveal, this.intro});

  final AiRevealTarget? reveal;
  final String? intro;

  @override
  List<Object?> get props => [reveal, intro];
}

class AiChatAnswerSubmitted extends AiChatEvent {
  const AiChatAnswerSubmitted(this.answer);

  final String answer;

  @override
  List<Object?> get props => [answer];
}

class AiChatRestarted extends AiChatEvent {
  const AiChatRestarted();
}

class AiChatState extends Equatable {
  const AiChatState({
    this.messages = const [],
    this.answers = const [],
    this.step = 0,
    this.isTyping = false,
    this.finished = false,
    this.reveal,
  });

  final List<ChatMessage> messages;
  final List<String> answers;
  final int step;
  final bool isTyping;
  final bool finished;
  final AiRevealTarget? reveal;

  bool get isChallengeMode => reveal != null;

  bool get canType => !finished && !isTyping;

  AiChatState copyWith({
    List<ChatMessage>? messages,
    List<String>? answers,
    int? step,
    bool? isTyping,
    bool? finished,
    AiRevealTarget? reveal,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      answers: answers ?? this.answers,
      step: step ?? this.step,
      isTyping: isTyping ?? this.isTyping,
      finished: finished ?? this.finished,
      reveal: reveal ?? this.reveal,
    );
  }

  @override
  List<Object?> get props => [messages, answers, step, isTyping, finished, reveal];
}

/// Saytdagi savollar ketma-ketligi — bir-bir ko'chirilgan.
const kAiQuestions = <String>[
  'Avtomobil markasi va modelini kiriting (masalan: Chevrolet Cobalt)',
  'Ishlab chiqarilgan yili?',
  'Yurgan masofasi (km)?',
  'Rangi?',
  'Uzatmasi — avtomat yoki mexanika?',
  "Holati qanday? (masalan: ideal, o'rtacha, bo'yalgan)",
];

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  AiChatBloc(this._repository) : super(const AiChatState()) {
    on<AiChatStarted>(_onStarted);
    on<AiChatAnswerSubmitted>(_onAnswer);
    on<AiChatRestarted>((event, emit) => emit(const AiChatState()));
  }

  final ValuationRepository _repository;

  void _onStarted(AiChatStarted event, Emitter<AiChatState> emit) {
    emit(
      AiChatState(
        reveal: event.reveal,
        messages: [
          if (event.intro != null) ChatMessage(ChatRole.bot, event.intro!),
          ChatMessage(ChatRole.bot, kAiQuestions.first),
        ],
      ),
    );
  }

  Future<void> _onAnswer(
    AiChatAnswerSubmitted event,
    Emitter<AiChatState> emit,
  ) async {
    final answer = event.answer.trim();
    if (answer.isEmpty || !state.canType) return;

    // Javobni tekshirish: AI istalgan matnni qabul qilmaydi.
    final error = _validate(state.step, answer);
    if (error != null) {
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(ChatRole.user, answer),
            ChatMessage(ChatRole.bot, error),
          ],
        ),
      );
      return;
    }

    final answers = [...state.answers, answer];
    final messages = [...state.messages, ChatMessage(ChatRole.user, answer)];
    final nextStep = state.step + 1;

    if (nextStep < kAiQuestions.length) {
      emit(
        state.copyWith(
          answers: answers,
          step: nextStep,
          messages: [...messages, ChatMessage(ChatRole.bot, kAiQuestions[nextStep])],
        ),
      );
      return;
    }

    emit(state.copyWith(answers: answers, step: nextStep, messages: messages, isTyping: true));

    final input = ValuationInput(
      model: answers[0],
      year: _toInt(answers[1], fallback: DateTime.now().year - 4),
      mileage: _toInt(answers[2], fallback: 80000),
      color: answers[3],
      transmission: answers[4],
      condition: answers[5],
    );

    final result = await _repository.estimate(input);

    final buffer = StringBuffer()
      ..writeln(
        'Taxminiy narx: ${PriceFormatter.uzs(result.minPrice).replaceAll(" so'm", '')}'
        " - ${PriceFormatter.uzs(result.maxPrice)}",
      );
    if (!state.isChallengeMode) {
      buffer
        ..writeln()
        ..writeln('Narxga ta\'sir qilgan omillar:');
    } else {
      buffer.writeln();
    }
    for (final factor in result.factors) {
      buffer.writeln(factor);
    }

    final reveal = state.reveal;
    emit(
      state.copyWith(
        isTyping: false,
        finished: true,
        messages: [
          ...messages,
          ChatMessage(ChatRole.bot, buffer.toString().trimRight()),
          if (reveal != null)
            ChatMessage(
              ChatRole.bot,
              'Savoldagi ${reveal.carName} uchun to\'g\'ri javob: '
              '${PriceFormatter.uzs(reveal.correctPrice)}. '
              'Endi yuqoridagi savolga qaytib to\'g\'ri variantni belgilashingiz mumkin.',
            ),
        ],
      ),
    );
  }

  /// Har bir savol uchun mantiqiy tekshiruv. null — javob qabul qilinadi.
  String? _validate(int step, String answer) {
    final lower = answer.toLowerCase();
    final digits = answer.replaceAll(RegExp('[^0-9]'), '');
    final letterCount = RegExp('[a-zA-Z]').allMatches(answer).length;

    switch (step) {
      case 0: // marka va model
        if (letterCount < 3) {
          return "Bu marka va modelga o'xshamadi. Matn bilan yozing — "
              'masalan: Chevrolet Cobalt.';
        }
        return null;

      case 1: // yil
        final maxYear = DateTime.now().year + 1;
        if (digits.length != 4) {
          return "Yilni 4 xonali son bilan yozing — masalan: 2021.";
        }
        final year = int.parse(digits);
        if (year < 1980 || year > maxYear) {
          return "1980-$maxYear oralig'idagi yilni kiriting.";
        }
        return null;

      case 2: // yurgan masofa
        if (digits.isEmpty || letterCount > 4) {
          return "Yurgan masofani km da son bilan yozing — masalan: 109000.";
        }
        final km = int.parse(digits);
        if (km > 1500000) {
          return 'Bu masofa haqiqatga to\'g\'ri kelmaydi. Km da qayta kiriting.';
        }
        return null;

      case 3: // rang
        if (letterCount < 2) {
          return "Rangni so'z bilan yozing — masalan: oq, qora, kumush.";
        }
        return null;

      case 4: // uzatma
        const gearKeys = ['avtomat', 'automat', 'avto', 'mexanik', 'mechanik',
            'variator', 'robot', 'dsg', 'cvt'];
        final short = lower.trim();
        if (!gearKeys.any(lower.contains) && short != 'at' && short != 'mt') {
          return 'Uzatmani aniq yozing: "avtomat" yoki "mexanika".';
        }
        return null;

      case 5: // holat
        const conditionKeys = ['ideal', 'alo', "a'lo", 'yaxshi', 'ortacha',
            "o'rtacha", 'urtacha', 'normal', 'boyalgan', "bo'yalgan", 'yomon'];
        if (!conditionKeys.any(lower.contains)) {
          return "Holatini so'z bilan yozing: ideal, o'rtacha yoki bo'yalgan.";
        }
        return null;
    }
    return null;
  }

  int _toInt(String raw, {required int fallback}) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return fallback;
    return int.tryParse(digits) ?? fallback;
  }
}
