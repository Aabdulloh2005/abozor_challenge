import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/asset_image_box.dart';
import '../../data/challenge_data.dart';
import '../../domain/entities/prize.dart';
import '../bloc/challenge_bloc.dart';

/// 1-qadam: sovrinlar ro'yxati (scroll qilinadi).
/// Oliy bosh sovrin alohida ajratilgan, qolganlari oddiy sovrinlar.
class PrizeListView extends StatelessWidget {
  const PrizeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChallengeBloc>();
    final grand = ChallengeData.prizes.where((prize) => prize.isGrand);
    final regular = ChallengeData.prizes.where((prize) => !prize.isGrand);

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
            "Qaysi sovrin uchun o'ynashni tanlang",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final prize in grand) ...[
          PrizeCard(
            prize: prize,
            onTap: () => bloc.add(ChallengePrizeSelected(prize)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const Text(
          'Oddiy sovrinlar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final prize in regular) ...[
          PrizeCard(
            prize: prize,
            onTap: () => bloc.add(ChallengePrizeSelected(prize)),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// Sovrin kartasi — bosh sahifadagi banner dizaynining o'zi.
class PrizeCard extends StatelessWidget {
  const PrizeCard({super.key, required this.prize, this.onTap});

  final Prize prize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: prize.isGrand
              ? Border.all(color: AppColors.primary, width: 1.6)
              : null,
        ),
        child: SizedBox(
          height: prize.isGrand ? 190 : 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AssetImageBox(asset: prize.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              if (prize.isGrand)
                Positioned(
                  left: AppSpacing.md,
                  top: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'OLIY BOSH SOVRIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prize.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: prize.isGrand ? 20 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prize.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (onTap != null)
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
