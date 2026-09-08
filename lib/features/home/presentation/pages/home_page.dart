import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../ai_valuation/presentation/pages/ai_assistant_page.dart';
import '../../../challenge/presentation/pages/challenge_sheet.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/konkurs_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/showroom_section.dart';

/// Saytdagi bosh sahifa.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  void _openChallenge(BuildContext context) {
    ChallengeSheet.show(
      context,
      onOpenAiAssistant: () => _openAi(context),
      onOpenProfile: onOpenProfile,
    );
  }

  void _openAi(BuildContext context) {
    AiAssistantPage.open(
      context,
      onKonkursTap: () {
        Navigator.of(context).pop();
        _openChallenge(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        children: [
          const HomeHeader(),
          const SizedBox(height: AppSpacing.md),
          const HeroBanner(),
          const SizedBox(height: AppSpacing.md),
          const QuickActions(),
          const SizedBox(height: AppSpacing.md),
          KonkursBanner(onTap: () => _openChallenge(context)),
          const SizedBox(height: AppSpacing.md),
          AiAssistantCard(onTap: () => _openAi(context)),
          const SizedBox(height: AppSpacing.lg),
          const ShowroomSection(),
        ],
      ),
    );
  }
}
