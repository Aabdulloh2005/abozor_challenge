import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../challenge/data/challenge_data.dart';

/// Konkursdagi ishtirok holati.
/// Hozircha xotirada (backend tayyor bo'lganda shu Cubit'ning ichi almashadi).
class ParticipationState extends Equatable {
  const ParticipationState({
    this.joined = const {},
    this.shared = false,
  });

  /// Narxi to'g'ri topilgan (ya'ni ishtirok qozonilgan) sovrin id'lari.
  final Set<String> joined;

  /// Oliy sovrin uchun havola ulashildimi.
  final bool shared;

  bool quizDoneFor(String prizeId) => joined.contains(prizeId);

  /// Oddiy sovrin: narxni topish yetarli.
  /// Oliy sovrin: narxni topish + havolani ulashish.
  bool isParticipating(String prizeId, {required bool isGrand}) {
    if (!joined.contains(prizeId)) return false;
    return isGrand ? shared : true;
  }

  int get participatingCount => ChallengeData.prizes
      .where((prize) => isParticipating(prize.id, isGrand: prize.isGrand))
      .length;

  ParticipationState copyWith({Set<String>? joined, bool? shared}) {
    return ParticipationState(
      joined: joined ?? this.joined,
      shared: shared ?? this.shared,
    );
  }

  @override
  List<Object?> get props => [joined, shared];
}

class ParticipationCubit extends Cubit<ParticipationState> {
  ParticipationCubit() : super(const ParticipationState());

  /// To'g'ri javobdan keyin chaqiriladi.
  void join(String prizeId) =>
      emit(state.copyWith(joined: {...state.joined, prizeId}));

  /// Taklif havolasi ulashilganda (oliy sovrin sharti).
  void registerShare() => emit(state.copyWith(shared: true));

  void reset() => emit(const ParticipationState());
}
