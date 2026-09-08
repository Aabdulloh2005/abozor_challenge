import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../prizes/presentation/cubit/participation_cubit.dart';
import '../../../prizes/presentation/pages/my_prizes_page.dart';
import '../widgets/garage_banner.dart';

/// Saytdagi /profil sahifasi.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const _menu = <({IconData icon, String label})>[
    (icon: Icons.directions_car_outlined, label: "Mening e'lonlarim"),
    (icon: Icons.build_outlined, label: 'Diagnostika tarixi'),
    (icon: Icons.credit_card_outlined, label: "To'lovlar"),
    (icon: Icons.settings_outlined, label: 'Sozlamalar'),
    (icon: Icons.favorite_border_rounded, label: 'Tanlangan qidiruvlar'),
    (icon: Icons.description_outlined, label: "Biz bilan bog'lanish"),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        children: [
          const Text(
            'Profil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diyor',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '+998 77 348 09 90',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const GarageBanner(),
          const SizedBox(height: AppSpacing.md),
          const _PrizesCard(),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _menu.length; i++) ...[
                  ListTile(
                    onTap: () {},
                    leading: Icon(
                      _menu[i].icon,
                      size: 20,
                      color: AppColors.mutedForeground,
                    ),
                    title: Text(
                      _menu[i].label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  if (i != _menu.length - 1)
                    const Divider(height: 1, indent: 52, endIndent: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: AppColors.foreground),
              child: const Text(
                'Chiqish',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profildagi "Sovrinlarim" kartasi — ishtirok holatini ko'rsatadi.
class _PrizesCard extends StatelessWidget {
  const _PrizesCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParticipationCubit, ParticipationState>(
      builder: (context, state) {
        final count = state.participatingCount;
        return InkWell(
          onTap: () => Navigator.of(context).push(MyPrizesPage.route()),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sovrinlarim',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        count == 0
                            ? "Ishtirok etish uchun mashina narxini toping"
                            : '$count ta sovrinda ishtirok etyapsiz',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
