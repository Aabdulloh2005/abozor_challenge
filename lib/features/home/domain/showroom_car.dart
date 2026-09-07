import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Bosh sahifadagi "Avtosalon avtomobillari" ro'yxati (saytdagi 3 ta karta).
class ShowroomCar {
  const ShowroomCar({
    required this.name,
    required this.year,
    required this.mileage,
    required this.badge,
    required this.badgeColor,
    required this.image,
  });

  final String name;
  final int year;
  final String mileage;
  final String badge;
  final Color badgeColor;
  final String image;

  String get subtitle => '$year • $mileage';
}

const kShowroomCars = <ShowroomCar>[
  ShowroomCar(
    name: 'Cobalt 1.5 AT',
    year: 2024,
    mileage: '0 km',
    badge: 'Mavjud',
    badgeColor: AppColors.success,
    image: 'assets/images/car-cobalt.jpg',
  ),
  ShowroomCar(
    name: 'Cobalt 1.5 AT',
    year: 2024,
    mileage: '0 km',
    badge: "Muddatli to'lov",
    badgeColor: Color(0xFFE0A400),
    image: 'assets/images/car-cobalt.jpg',
  ),
  ShowroomCar(
    name: 'Onix 1.2 T',
    year: 2025,
    mileage: '0 km',
    badge: 'Mavjud',
    badgeColor: AppColors.success,
    image: 'assets/images/car-cobalt.jpg',
  ),
];
