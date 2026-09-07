import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/asset_image_box.dart';

/// "Uyingizga borib sotib beramiz" hero banneri.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Stack(
        children: [
          const AssetImageBox(
            asset: 'assets/images/hero-car.jpg',
            height: 170,
            width: double.infinity,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
                children: [
                  TextSpan(text: 'Uyingizga borib '),
                  TextSpan(
                    text: 'sotib\nberamiz',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.sm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 2; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 5,
                    width: i == 0 ? 16 : 5,
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
