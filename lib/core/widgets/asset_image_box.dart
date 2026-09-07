import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Rasm topilmasa ilova buzilmasligi uchun placeholder bilan chizadigan wrapper.
class AssetImageBox extends StatelessWidget {
  const AssetImageBox({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String asset;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.border],
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.directions_car_filled_rounded,
          color: AppColors.mutedForeground,
          size: 34,
        ),
      ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
