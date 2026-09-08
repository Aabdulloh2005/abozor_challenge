import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/challenge_car.dart';
import '../../domain/entities/prize.dart';

/// Konkurs oqimi: sovrinni tanlash → mashinani tanlash → narx savoli.
/// To'g'ri javob alohida ekranda ochiladi (oliy sovrin uchun ulashish sharti
/// ham o'sha oxirgi ekranda so'raladi — boshida user bloklanmaydi).
enum ChallengeStep { prizeList, carList, question }

enum ChallengeAnswerStatus { idle, wrong, correct }

class ChallengeState extends Equatable {
  const ChallengeState({
    this.step = ChallengeStep.prizeList,
    this.prize,
    this.car,
    this.selectedPrice,
    this.currency = Currency.uzs,
    this.aiPanelOpen = false,
    this.aiForced = false,
    this.answerStatus = ChallengeAnswerStatus.idle,
  });

  final ChallengeStep step;
  final Prize? prize;
  final ChallengeCar? car;
  final int? selectedPrice;
  final Currency currency;
  final bool aiPanelOpen;

  /// AI paneli "Javobni bilish" (xato javob dialogi) orqali ochilganmi.
  /// Bunda chiqish yo'llari minimallashtiriladi.
  final bool aiForced;
  final ChallengeAnswerStatus answerStatus;

  ChallengeState copyWith({
    ChallengeStep? step,
    Prize? prize,
    ChallengeCar? car,
    int? selectedPrice,
    bool clearCar = false,
    bool clearSelection = false,
    Currency? currency,
    bool? aiPanelOpen,
    bool? aiForced,
    ChallengeAnswerStatus? answerStatus,
  }) {
    return ChallengeState(
      step: step ?? this.step,
      prize: prize ?? this.prize,
      car: clearCar ? null : (car ?? this.car),
      selectedPrice:
          (clearSelection || clearCar) ? null : (selectedPrice ?? this.selectedPrice),
      currency: currency ?? this.currency,
      aiPanelOpen: aiPanelOpen ?? this.aiPanelOpen,
      aiForced: aiForced ?? this.aiForced,
      answerStatus: answerStatus ?? this.answerStatus,
    );
  }

  @override
  List<Object?> get props => [
        step,
        prize,
        car,
        selectedPrice,
        currency,
        aiPanelOpen,
        aiForced,
        answerStatus,
      ];
}

sealed class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => const [];
}

class ChallengePrizeSelected extends ChallengeEvent {
  const ChallengePrizeSelected(this.prize);

  final Prize prize;

  @override
  List<Object?> get props => [prize];
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
  const ChallengeAiPanelToggled({required this.open, this.forced = false});

  final bool open;

  /// true — xato javobdan keyingi "Javobni bilish" orqali ochilgan.
  final bool forced;

  @override
  List<Object?> get props => [open, forced];
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
    on<ChallengePrizeSelected>(
      (event, emit) => emit(
        state.copyWith(
          prize: event.prize,
          step: ChallengeStep.carList,
          clearCar: true,
        ),
      ),
    );

    on<ChallengeCarSelected>(
      (event, emit) => emit(
        state.copyWith(
          step: ChallengeStep.question,
          car: event.car,
          clearSelection: true,
          aiPanelOpen: false,
          aiForced: false,
          answerStatus: ChallengeAnswerStatus.idle,
        ),
      ),
    );

    on<ChallengeBackPressed>((event, emit) {
      switch (state.step) {
        case ChallengeStep.question:
          emit(
            state.copyWith(
              step: ChallengeStep.carList,
              clearCar: true,
              aiPanelOpen: false,
              aiForced: false,
            ),
          );
        case ChallengeStep.carList:
          emit(state.copyWith(step: ChallengeStep.prizeList, clearCar: true));
        case ChallengeStep.prizeList:
          break;
      }
    });

    on<ChallengeCurrencyToggled>(
      (event, emit) => emit(state.copyWith(currency: event.currency)),
    );

    on<ChallengeAnswerSelected>((event, emit) {
      final car = state.car;
      if (car == null) return;
      emit(
        state.copyWith(
          selectedPrice: event.price,
          answerStatus: car.isCorrect(event.price)
              ? ChallengeAnswerStatus.correct
              : ChallengeAnswerStatus.wrong,
        ),
      );
    });

    on<ChallengeAiPanelToggled>(
      (event, emit) => emit(
        state.copyWith(
          aiPanelOpen: event.open,
          aiForced: event.open ? event.forced : false,
        ),
      ),
    );

    on<ChallengeAnswerStatusHandled>(
      (event, emit) => emit(state.copyWith(answerStatus: ChallengeAnswerStatus.idle)),
    );

    on<ChallengeReset>((event, emit) => emit(const ChallengeState()));
  }
}
