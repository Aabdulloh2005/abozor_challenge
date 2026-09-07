import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/asset_image_box.dart';
import '../../data/challenge_data.dart';
import '../bloc/challenge_bloc.dart';
import 'prize_carousel.dart';

/// 1-qadam: sovrin karuseli + "Quyidagilardan birini tanlang" + 8 ta mashina.
class ChallengeCarListView extends StatelessWidget {
  const ChallengeCarListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Text(
            "Mashina narxini toping va konkurs ishtirokchisi bo'ling",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const PrizeCarousel(),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Quyidagilardan birini tanlang',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final car in ChallengeData.cars) ...[
          InkWell(
            onTap: () => context.read<ChallengeBloc>().add(ChallengeCarSelected(car)),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  AssetImageBox(asset: car.image, height: 150, width: double.infinity),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            car.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
