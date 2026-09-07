import '../entities/valuation.dart';

/// Baholash manbai. Hozir mock, keyin real API shu interfeysni implement qiladi
/// (masalan `ApiValuationRepository`) va DI'da bitta qator almashadi.
abstract interface class ValuationRepository {
  Future<ValuationResult> estimate(ValuationInput input);
}
