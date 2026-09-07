import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../lottery/presentation/cubit/coupon_cubit.dart';

/// Sayt header'i: logo + kupon soni + xabarlar ikonkasi.
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
        BlocBuilder<CouponCubit, int>(
          builder: (context, coupons) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$coupons',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: AppSpacing.xs),
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
