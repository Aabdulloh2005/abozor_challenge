import 'package:equatable/equatable.dart';

/// Konkurs sovrini.
/// [isGrand] — oliy bosh sovrin: unda qatnashish uchun qo'shimcha shart bor
/// (do'stni taklif qilish / referal havolani ulashish).
class Prize extends Equatable {
  const Prize({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    this.isGrand = false,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Qisqa izoh — "Sovrinlarim" ro'yxatida ko'rsatiladi.
  final String description;
  final String image;
  final bool isGrand;

  @override
  List<Object?> get props => [id];
}
