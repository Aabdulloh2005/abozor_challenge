import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
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
