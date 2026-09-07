import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Saytdagi pastki navigatsiya: Asosiy / Auksionlarim / Sotuv / Bildirishnoma / Profil.
/// Saytda o'rta uchta bo'lim hali bosh sahifaga olib boradi — shu xatti-harakat saqlangan.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const items = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: 'Asosiy'),
    (icon: Icons.gavel_rounded, label: 'Auksionlarim'),
    (icon: Icons.sell_outlined, label: 'Sotuv'),
    (icon: Icons.notifications_none_rounded, label: 'Bildirishnoma'),
    (icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 22,
                          color: i == currentIndex
                              ? AppColors.primary
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: i == currentIndex
                                ? AppColors.primary
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
