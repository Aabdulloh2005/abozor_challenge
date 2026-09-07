import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/challenge_car.dart';

enum ChallengeStep { carList, question, success }

enum ChallengeAnswerStatus { idle, wrong, correct }

class ChallengeState extends Equatable {
  const ChallengeState({
    this.step = ChallengeStep.carList,
    this.car,
    this.selectedPrice,
    this.currency = Currency.uzs,
    this.aiPanelOpen = false,
    this.answerStatus = ChallengeAnswerStatus.idle,
  });

  final ChallengeStep step;
  final ChallengeCar? car;
  final int? selectedPrice;
  final Currency currency;
  final bool aiPanelOpen;
  final ChallengeAnswerStatus answerStatus;

  ChallengeState copyWith({
    ChallengeStep? step,
    ChallengeCar? car,
    int? selectedPrice,
    bool clearSelection = false,
    Currency? currency,
    bool? aiPanelOpen,
    ChallengeAnswerStatus? answerStatus,
  }) {
    return ChallengeState(
      step: step ?? this.step,
      car: car ?? this.car,
      selectedPrice: clearSelection ? null : (selectedPrice ?? this.selectedPrice),
      currency: currency ?? this.currency,
      aiPanelOpen: aiPanelOpen ?? this.aiPanelOpen,
      answerStatus: answerStatus ?? this.answerStatus,
    );
  }

  @override
  List<Object?> get props =>
      [step, car, selectedPrice, currency, aiPanelOpen, answerStatus];
}

sealed class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => const [];
}

class ChallengeCarSelected extends ChallengeEvent {
  const ChallengeCarSelected(this.car);

  final ChallengeCar car;

  @override
  List<Object?> get props => [car];
}

class ChallengeBackPressed extends ChallengeEvent {
  const ChallengeBackPressed();
}

class ChallengeCurrencyToggled extends ChallengeEvent {
  const ChallengeCurrencyToggled(this.currency);

  final Currency currency;

  @override
  List<Object?> get props => [currency];
}

class ChallengeAnswerSelected extends ChallengeEvent {
  const ChallengeAnswerSelected(this.price);

  final int price;

  @override
  List<Object?> get props => [price];
}

class ChallengeAiPanelToggled extends ChallengeEvent {
  const ChallengeAiPanelToggled({required this.open});

  final bool open;

  @override
  List<Object?> get props => [open];
}

/// Xato javob dialogi ko'rsatilib bo'lgach statusni tozalash uchun.
class ChallengeAnswerStatusHandled extends ChallengeEvent {
  const ChallengeAnswerStatusHandled();
}

class ChallengeReset extends ChallengeEvent {
  const ChallengeReset();
}

class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  ChallengeBloc() : super(const ChallengeState()) {
    on<ChallengeCarSelected>(
      (event, emit) => emit(
        state.copyWith(
          step: ChallengeStep.question,
          car: event.car,
          clearSelection: true,
          aiPanelOpen: false,
          answerStatus: ChallengeAnswerStatus.idle,
        ),
      ),
    );

    on<ChallengeBackPressed>((event, emit) {
      if (state.step == ChallengeStep.question) {
        emit(
          const ChallengeState(),
        );
      } else if (state.step == ChallengeStep.success) {
        emit(state.copyWith(step: ChallengeStep.question));
      }
    });

    on<ChallengeCurrencyToggled>(
      (event, emit) => emit(state.copyWith(currency: event.currency)),
    );

    on<ChallengeAnswerSelected>((event, emit) {
      final car = state.car;
      if (car == null) return;
      final correct = car.isCorrect(event.price);
      emit(
        state.copyWith(
          selectedPrice: event.price,
          answerStatus: correct
              ? ChallengeAnswerStatus.correct
              : ChallengeAnswerStatus.wrong,
          step: correct ? ChallengeStep.success : state.step,
        ),
      );
    });

    on<ChallengeAiPanelToggled>(
      (event, emit) => emit(state.copyWith(aiPanelOpen: event.open)),
    );

    on<ChallengeAnswerStatusHandled>(
      (event, emit) => emit(state.copyWith(answerStatus: ChallengeAnswerStatus.idle)),
    );

    on<ChallengeReset>((event, emit) => emit(const ChallengeState()));
  }
}
