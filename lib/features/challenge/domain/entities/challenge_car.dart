import 'package:equatable/equatable.dart';

/// Konkursdagi bitta savol — mashina va uning 3 ta narx varianti.
class ChallengeCar extends Equatable {
  const ChallengeCar({
    required this.id,
    required this.name,
    required this.image,
    required this.year,
    required this.mileage,
    required this.color,
    required this.transmission,
    required this.options,
    required this.correctPrice,
  });

  final String id;
  final String name;
  final String image;
  final int year;
  final int mileage;
  final String color;
  final String transmission;

  /// So'mdagi 3 ta variant — saytdagi tartibda.
  final List<int> options;

  final int correctPrice;

  bool isCorrect(int price) => price == correctPrice;

  @override
  List<Object?> get props => [id];
}
