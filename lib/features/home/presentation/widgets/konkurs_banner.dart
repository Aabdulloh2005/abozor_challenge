import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../challenge/data/challenge_data.dart';

/// Bosh sahifadagi qora KONKURS banneri.
/// Sovrin matni saytdagidek almashib turadi.
class KonkursBanner extends StatefulWidget {
  const KonkursBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<KonkursBanner> createState() => _KonkursBannerState();
}

class _KonkursBannerState extends State<KonkursBanner> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % ChallengeData.prizes.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prize = ChallengeData.prizes[_index];
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 54,
            margin: const EdgeInsets.only(left: 14),
            padding: const EdgeInsets.only(left: 40, right: 12),
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              children: [
                const Text(
                  'KONKURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  height: 20,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.white24,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      prize.title,
                      key: ValueKey(prize.id),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
              ],
            ),
          ),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
