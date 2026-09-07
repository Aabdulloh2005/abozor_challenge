import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/invite.dart';
import '../../../ai_valuation/presentation/widgets/ai_chat_panel.dart';
import '../../../lottery/presentation/cubit/coupon_cubit.dart';
import '../bloc/challenge_bloc.dart';
import '../widgets/car_list_view.dart';
import '../widgets/question_view.dart';
import '../widgets/success_view.dart';

/// Saytdagi "Abozor Challenge" bottom sheet'i.
class ChallengeSheet extends StatefulWidget {
  const ChallengeSheet({
    super.key,
    this.onOpenAiAssistant,
    this.onOpenProfile,
  });

  final VoidCallback? onOpenAiAssistant;
  final VoidCallback? onOpenProfile;

  @override
  State<ChallengeSheet> createState() => _ChallengeSheetState();

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onOpenAiAssistant,
    VoidCallback? onOpenProfile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      builder: (_) => ChallengeSheet(
        onOpenAiAssistant: onOpenAiAssistant,
        onOpenProfile: onOpenProfile,
      ),
    );
  }
}

class _ChallengeSheetState extends State<ChallengeSheet> {
  /// Savol ko'rinishi scroll rejimdan pin rejimga ko'chganda animatsiya
  /// uzilib qolmasligi uchun — subtree state'i saqlanadi.
  final GlobalKey _questionViewKey = GlobalKey(debugLabel: 'challenge-question');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChallengeBloc(),
      child: BlocConsumer<ChallengeBloc, ChallengeState>(
        listenWhen: (previous, current) =>
            previous.answerStatus != current.answerStatus,
        listener: (context, state) async {
          if (state.answerStatus == ChallengeAnswerStatus.wrong) {
            context.read<ChallengeBloc>().add(const ChallengeAnswerStatusHandled());
            final showAi = await _showWrongDialog(context);
            if (showAi == true && context.mounted) {
              context
                  .read<ChallengeBloc>()
                  .add(const ChallengeAiPanelToggled(open: true));
            }
          } else if (state.answerStatus == ChallengeAnswerStatus.correct) {
            context.read<ChallengeBloc>().add(const ChallengeAnswerStatusHandled());
            // Kupon qo'shiladi (saytdagidek to'g'ri javob = +1 kupon).
            context.read<CouponCubit>().increment();
          }
        },
        builder: (context, state) {
          final bloc = context.read<ChallengeBloc>();
          final media = MediaQuery.of(context);

          // AI chat ochilganda sheet yuqoriga cho'ziladi va mashina ma'lumoti
          // tepada pin bo'lib qoladi (chat qolgan joyni to'ldiradi).
          final pinnedMode =
              state.step == ChallengeStep.question && state.aiPanelOpen;
          final pinnedHeight = (media.size.height * 0.9 - media.viewInsets.bottom)
              .clamp(360.0, media.size.height * 0.9)
              .toDouble();

          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () {
                      if (state.step == ChallengeStep.carList) {
                        Navigator.of(context).pop();
                      } else if (state.aiPanelOpen) {
                        bloc.add(const ChallengeAiPanelToggled(open: false));
                      } else {
                        bloc.add(const ChallengeBackPressed());
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Abozor Challenge',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          );

          final content = switch (state.step) {
            ChallengeStep.carList => const ChallengeCarListView(),
            ChallengeStep.question => ChallengeQuestionView(
                key: _questionViewKey,
                state: state,
              ),
            ChallengeStep.success => ChallengeSuccessView(
                onBack: () => bloc.add(const ChallengeBackPressed()),
                onInviteFriend: () => InviteHelper.invite(context),
                onValuateOwnCar: () {
                  Navigator.of(context).pop();
                  widget.onOpenAiAssistant?.call();
                },
                onOpenProfile: () {
                  Navigator.of(context).pop();
                  widget.onOpenProfile?.call();
                },
              ),
          };

          const contentPadding = EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xl,
          );

          return Padding(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: pinnedMode
                  ? SizedBox(
                      height: pinnedHeight,
                      child: Padding(
                        padding: contentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            Expanded(child: content),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: contentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [header, content],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showWrongDialog(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      // Chetini bosib yopib bo'lmaydi — faqat "Javobni bilish" orqali yopiladi.
      barrierDismissible: false,
      barrierLabel: 'Javobingiz xato',
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        // Saytdagidek: orqa fon blur bo'ladi.
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10 * curved.value,
            sigmaY: 10 * curved.value,
          ),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Material(
              color: AppColors.card,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Javobingiz xato',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Abozor AI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  // AI yozayotgandek effekt.
                                  const TypingText(
                                    text:
                                        "Xohlaysizmi, to'g'ri javobni aytib beraman va keyin siz qayta uring",
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Javobni bilish'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 34,
        width: 34,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.foreground),
      ),
    );
  }
}
