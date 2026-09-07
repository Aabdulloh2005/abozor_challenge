import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Sayt header'i: logo + xabarlar ikonkasi.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.change_history_rounded, color: AppColors.primary, size: 20),
        const SizedBox(width: 6),
        const Text(
          'Abozor',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const Spacer(),
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.mail_outline_rounded, size: 16),
        ),
      ],
    );
  }
}
