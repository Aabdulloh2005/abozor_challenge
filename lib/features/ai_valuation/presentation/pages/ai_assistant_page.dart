import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../challenge/data/challenge_data.dart';
import '../../domain/repositories/valuation_repository.dart';
import '../bloc/ai_chat_bloc.dart';
import '../widgets/ai_chat_panel.dart';

/// "Abozor AI narxlash" — alohida to'liq ekran (bottom sheet emas).
class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key, this.onKonkursTap});

  final VoidCallback? onKonkursTap;

  static Route<void> route({VoidCallback? onKonkursTap}) {
    return MaterialPageRoute<void>(
      builder: (_) => AiAssistantPage(onKonkursTap: onKonkursTap),
    );
  }

  static Future<void> open(
    BuildContext context, {
    VoidCallback? onKonkursTap,
  }) {
    return Navigator.of(context).push(route(onKonkursTap: onKonkursTap));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatBloc(context.read<ValuationRepository>())
        ..add(const AiChatStarted()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Abozor AI narxlash'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  _KonkursStrip(onTap: onKonkursTap),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: AiChatPanel(
                      expand: true,
                      finishedActionLabel: 'Yangi baholash',
                      onFinishedAction: () => context.read<AiChatBloc>()
                        ..add(const AiChatRestarted())
                        ..add(const AiChatStarted()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tepadagi konkurs promo-chizig'i.
class _KonkursStrip extends StatelessWidget {
  const _KonkursStrip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final prize = ChallengeData.grandPrize;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KONKURS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${prize.title} — konkursda qatnashing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
    );
  }
}
