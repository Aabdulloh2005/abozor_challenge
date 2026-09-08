import '../domain/entities/challenge_car.dart';
import '../domain/entities/prize.dart';

/// Ma'lumotlar saytdan bir-bir ko'chirilgan (bright-recollections.lovable.app).
/// To'g'ri javob — saytdagidek o'rtadagi variant.
abstract final class ChallengeData {
  static const cars = <ChallengeCar>[
    ChallengeCar(
      id: 'cobalt',
      name: 'Chevrolet Cobalt 1.5 AT',
      image: 'assets/images/car-cobalt.jpg',
      year: 2021,
      mileage: 109000,
      color: 'Oq',
      transmission: 'Avtomat',
      options: [148000000, 165000000, 192000000],
      correctPrice: 165000000,
    ),
    ChallengeCar(
      id: 'tracker',
      name: 'Chevrolet Tracker 1.2 T',
      image: 'assets/images/car-tracker.jpg',
      year: 2023,
      mileage: 21000,
      color: 'Oq',
      transmission: 'Avtomat',
      options: [196000000, 225000000, 260000000],
      correctPrice: 225000000,
    ),
    ChallengeCar(
      id: 'gentra',
      name: 'Chevrolet Gentra 1.5 AT',
      image: 'assets/images/car-gentra.jpg',
      year: 2020,
      mileage: 94000,
      color: 'Kumush',
      transmission: 'Avtomat',
      options: [150000000, 182000000, 205000000],
      correctPrice: 182000000,
    ),
    ChallengeCar(
      id: 'malibu',
      name: 'Chevrolet Malibu 2.0 XL',
      image: 'assets/images/car-tracker.jpg',
      year: 2022,
      mileage: 48000,
      color: 'Qora',
      transmission: 'Avtomat',
      options: [385000000, 420000000, 470000000],
      correctPrice: 420000000,
    ),
    ChallengeCar(
      id: 'onix',
      name: 'Chevrolet Onix 1.2 T',
      image: 'assets/images/car-cobalt.jpg',
      year: 2024,
      mileage: 12000,
      color: 'Kumush',
      transmission: 'Avtomat',
      options: [205000000, 232000000, 268000000],
      correctPrice: 232000000,
    ),
    ChallengeCar(
      id: 'nexia',
      name: 'Chevrolet Nexia 3 SOHC',
      image: 'assets/images/car-gentra.jpg',
      year: 2019,
      mileage: 132000,
      color: 'Oq',
      transmission: 'Mexanika',
      options: [88000000, 104000000, 121000000],
      correctPrice: 104000000,
    ),
    ChallengeCar(
      id: 'damas',
      name: 'Chevrolet Damas 8/0',
      image: 'assets/images/car-cobalt.jpg',
      year: 2022,
      mileage: 63000,
      color: 'Oq',
      transmission: 'Mexanika',
      options: [96000000, 112000000, 130000000],
      correctPrice: 112000000,
    ),
    ChallengeCar(
      id: 'captiva',
      name: 'Chevrolet Captiva 1.5 T',
      image: 'assets/images/car-tracker.jpg',
      year: 2023,
      mileage: 36000,
      color: 'Kulrang',
      transmission: 'Avtomat',
      options: [330000000, 365000000, 410000000],
      correctPrice: 365000000,
    ),
  ];

  /// Konkurs sovrinlari: bitta oliy bosh sovrin + oddiy sovrinlar.
  static const prizes = <Prize>[
    Prize(
      id: 'iphone',
      title: 'iPhone 17 Pro Max',
      subtitle: 'Oliy bosh sovrin',
      description: "Bosh sovrin — konkurs yakunida bitta g'olibga",
      image: 'assets/images/prize-iphone.jpg',
      isGrand: true,
    ),
    Prize(
      id: 'scooter',
      title: 'Xiaomi Scooter',
      subtitle: 'Yutib oling! 🏆',
      description: "Elektr skuter",
      image: 'assets/images/prize-scooter.jpg',
    ),
    Prize(
      id: 'watch',
      title: 'Apple Watch',
      subtitle: 'Yutib oling! 🏆',
      description: "Smart soat",
      image: 'assets/images/prize-watch.jpg',
    ),
    Prize(
      id: 'airpods',
      title: 'AirPods',
      subtitle: 'Yutib oling! 🏆',
      description: "Simsiz quloqchinlar",
      image: 'assets/images/prize-airpods.jpg',
    ),
    Prize(
      id: 'tires',
      title: 'Hankook shinalar',
      subtitle: 'Yutib oling! 🏆',
      description: "To'plam — 4 dona shina",
      image: 'assets/images/prize-tires.jpg',
    ),
    Prize(
      id: 'battery',
      title: 'Akkumulyator',
      subtitle: 'Yutib oling! 🏆',
      description: "Avtomobil uchun yangi akkumulyator",
      image: 'assets/images/prize-battery.jpg',
    ),
    Prize(
      id: 'carwash',
      title: 'Bepul avtomoyka',
      subtitle: 'Yutib oling! 🏆',
      description: "Abozor Garaj'da bepul yuvish",
      image: 'assets/images/prize-carwash.jpg',
    ),
  ];

  /// Konkurs yakunlanadigan sana (countdown shu sanadan hisoblanadi).
  static final DateTime drawDate = DateTime(2026, 10, 1);

  /// Oliy bosh sovrin (bosh sahifadagi banner va promo uchun).
  static Prize get grandPrize => prizes.firstWhere((prize) => prize.isGrand);
}
