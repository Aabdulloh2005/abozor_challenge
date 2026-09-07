/// Kuponlarni saqlash uchun shartnoma.
/// Hozircha lokal (saytdagidek), keyin backend'ga almashtiriladi.
abstract interface class CouponRepository {
  Future<int> read();

  Future<int> increment([int by = 1]);

  Future<void> reset();
}
