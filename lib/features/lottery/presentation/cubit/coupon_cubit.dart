import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/coupon_repository.dart';

/// Kuponlar soni — bosh sahifa header'i, profil kartasi va lotareya sahifasi
/// shu bitta manbadan o'qiydi.
class CouponCubit extends Cubit<int> {
  CouponCubit(this._repository) : super(0);

  final CouponRepository _repository;

  Future<void> load() async => emit(await _repository.read());

  Future<void> increment([int by = 1]) async =>
      emit(await _repository.increment(by));

  Future<void> reset() async {
    await _repository.reset();
    emit(0);
  }
}
