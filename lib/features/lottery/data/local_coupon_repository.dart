import 'package:shared_preferences/shared_preferences.dart';

import '../domain/coupon_repository.dart';

/// Saytdagi bilan bir xil kalit: localStorage['abozor.coupons'].
class LocalCouponRepository implements CouponRepository {
  LocalCouponRepository(this._prefs);

  static const storageKey = 'abozor.coupons';

  final SharedPreferences _prefs;

  @override
  Future<int> read() async => _prefs.getInt(storageKey) ?? 0;

  @override
  Future<int> increment([int by = 1]) async {
    final next = (await read()) + by;
    await _prefs.setInt(storageKey, next);
    return next;
  }

  @override
  Future<void> reset() => _prefs.remove(storageKey);
}
