import 'package:flutter/material.dart';

import 'main_shell.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Ilova mobil uchun mo'ljallangan — keng ekranda (web/desktop) cho'zilib
/// ketmasligi uchun kontent shu kenglik bilan cheklanadi.
const double kMobileMaxWidth = 430;

class AbozorChallengeApp extends StatelessWidget {
  const AbozorChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abozor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) => _MobileFrame(child: child),
      home: const MainShell(),
    );
  }
}

/// Keng ekranda ilovani telefon kengligidagi ustunga joylaydi.
/// Mobil qurilmada hech narsa o'zgarmaydi.
class _MobileFrame extends StatelessWidget {
  const _MobileFrame({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();
    final media = MediaQuery.of(context);
    if (media.size.width <= kMobileMaxWidth) return content;

    return ColoredBox(
      color: const Color(0xFF15181C),
      child: Center(
        child: SizedBox(
          width: kMobileMaxWidth,
          child: MediaQuery(
            // Ichkaridagi barcha o'lchovlar telefon kengligidan hisoblanadi.
            data: media.copyWith(
              size: Size(kMobileMaxWidth, media.size.height),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.background),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
