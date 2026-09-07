import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

/// Saytdagi 2x2 tezkor amallar: Sotib olish / Tez sotish / Auksion / Trade-In.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const _items = <({IconData icon, String title, String subtitle, Color color})>[
    (
      icon: Icons.search_rounded,
      title: 'Sotib olish',
      subtitle: 'Avto izlang',
      color: AppColors.foreground,
    ),
    (
      icon: Icons.sell_outlined,
      title: 'Tez sotish',
      subtitle: 'Tez soting',
      color: AppColors.primary,
    ),
    (
      icon: Icons.wifi_tethering_rounded,
      title: 'Auksion',
      subtitle: '24 soat jonli',
      color: AppColors.primary,
    ),
    (
      icon: Icons.autorenew_rounded,
      title: 'Trade-In',
      subtitle: 'Yangilang',
      color: Color(0xFF2C7BE5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 40, color: item.color),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
