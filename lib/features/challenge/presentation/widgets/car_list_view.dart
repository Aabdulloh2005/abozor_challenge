import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/asset_image_box.dart';
import '../../data/challenge_data.dart';
import '../bloc/challenge_bloc.dart';

/// 2-qadam: tanlangan sovrin uchun mashinani tanlash.
class ChallengeCarListView extends StatelessWidget {
  const ChallengeCarListView({super.key, required this.state});

  final ChallengeState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChallengeBloc>();
    final prize = state.prize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prize != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                AssetImageBox(
                  asset: prize.image,
                  height: 40,
                  width: 56,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanlangan sovrin',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        prize.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => bloc.add(const ChallengeBackPressed()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "O'zgartirish",
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
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
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Quyidagilardan birini tanlang',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final car in ChallengeData.cars) ...[
          InkWell(
            onTap: () => bloc.add(ChallengeCarSelected(car)),
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
