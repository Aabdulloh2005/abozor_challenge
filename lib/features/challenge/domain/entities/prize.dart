import 'package:equatable/equatable.dart';

/// Konkurs sovrini. `bannerLabel` — bosh sahifadagi qora bannerda aylanadigan matn,
/// `title`/`subtitle` — challenge oynasidagi karusel matni.
class Prize extends Equatable {
  const Prize({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.bannerLabel,
    required this.image,
  });

  final String id;
  final String title;
  final String subtitle;
  final String bannerLabel;
  final String image;

  @override
  List<Object?> get props => [id];
}
