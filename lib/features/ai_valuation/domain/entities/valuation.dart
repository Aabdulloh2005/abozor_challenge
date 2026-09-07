import 'package:equatable/equatable.dart';

/// AI baholash uchun foydalanuvchi kiritgan ma'lumotlar.
class ValuationInput extends Equatable {
  const ValuationInput({
    required this.model,
    required this.year,
    required this.mileage,
    required this.color,
    required this.transmission,
    required this.condition,
  });

  final String model;
  final int year;
  final int mileage;
  final String color;
  final String transmission;
  final String condition;

  @override
  List<Object?> get props => [model, year, mileage, color, transmission, condition];
}

/// Natija: saytdagidek narx oralig'i + omillar ro'yxati.
class ValuationResult extends Equatable {
  const ValuationResult({
    required this.minPrice,
    required this.maxPrice,
    required this.factors,
  });

  final int minPrice;
  final int maxPrice;
  final List<String> factors;

  @override
  List<Object?> get props => [minPrice, maxPrice, factors];
}
