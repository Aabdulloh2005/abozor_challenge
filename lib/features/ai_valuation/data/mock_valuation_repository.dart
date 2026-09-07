import 'dart:math' as math;

import '../domain/entities/valuation.dart';
import '../domain/repositories/valuation_repository.dart';

/// Saytdagi server funksiyasi o'rniga — offline, deterministik baholash.
/// Chiqish formati saytdagidek: "Taxminiy narx: X - Y so'm" + omillar.
class MockValuationRepository implements ValuationRepository {
  const MockValuationRepository();

  static const Map<String, int> _basePrices = {
    'malibu': 430000000,
    'captiva': 380000000,
    'traverse': 520000000,
    'equinox': 340000000,
    'tahoe': 900000000,
    'onix': 240000000,
    'tracker': 235000000,
    'gentra': 190000000,
    'cobalt': 170000000,
    'lacetti': 130000000,
    'nexia': 110000000,
    'damas': 115000000,
    'labo': 105000000,
    'spark': 95000000,
    'matiz': 70000000,
  };

  static const int _fallbackPrice = 160000000;

  @override
  Future<ValuationResult> estimate(ValuationInput input) async {
    // Saytdagi "Baholanmoqda..." holatini takrorlash uchun.
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final model = input.model.toLowerCase();
    var base = _fallbackPrice;
    for (final entry in _basePrices.entries) {
      if (model.contains(entry.key)) {
        base = entry.value;
        break;
      }
    }

    final currentYear = DateTime.now().year;
    final age = math.max(0, currentYear - input.year);
    var value = base * math.pow(0.93, age).toDouble();

    // Har 10 000 km uchun 20 000 km dan keyin -1.2%.
    final extraMileage = math.max(0, input.mileage - 20000);
    value *= math.max(0.55, 1 - (extraMileage / 10000) * 0.012);

    final condition = input.condition.toLowerCase();
    if (condition.contains('ideal')) {
      value *= 1.05;
    } else if (condition.contains("bo'yal") || condition.contains('boyal')) {
      value *= 0.9;
    }

    if (input.transmission.toLowerCase().contains('mex')) value *= 0.96;

    final center = (value / 1000000).round() * 1000000;
    final min = ((center * 0.94) / 1000000).round() * 1000000;
    final max = ((center * 1.06) / 1000000).round() * 1000000;

    return ValuationResult(
      minPrice: min,
      maxPrice: max,
      factors: _factors(input, age),
    );
  }

  List<String> _factors(ValuationInput input, int age) {
    final positive = <String>[];
    final negative = <String>[];

    if (input.transmission.toLowerCase().contains('avtomat')) {
      positive.add('avtomat uzatmalar qutisi');
    } else {
      negative.add('mexanika qutisi ikkilamchi bozorda sekinroq sotiladi');
    }

    final condition = input.condition.toLowerCase();
    if (condition.contains('ideal')) {
      positive.add('ideal holat');
    } else if (condition.contains("bo'yal") || condition.contains('boyal')) {
      negative.add("bo'yalgan qismlar narxni pasaytiradi");
    } else {
      negative.add('kosmetik kamchiliklar narxga salbiy ta\'sir ko\'rsatadi');
    }

    final color = input.color.toLowerCase();
    if (color.contains('oq') || color.contains('kumush') || color.contains('qora')) {
      positive.add('bozorda xaridorgir ${input.color.toLowerCase()} rang');
    } else {
      negative.add('${input.color.toLowerCase()} rang uchun xaridorlar doirasi torroq');
    }

    if (age <= 2) {
      positive.add('yangi yil va kam yurgan masofa');
    } else if (input.mileage > 90000) {
      negative.add(
        '${input.year}-yil uchun bosib o\'tilgan masofa (${input.mileage} km) biroz yuqori',
      );
    }

    return [
      if (positive.isNotEmpty) '• Ijobiy omillar: ${positive.join(', ')}',
      if (negative.isNotEmpty) '• Salbiy omillar: ${negative.join('; ')}',
    ];
  }
}
