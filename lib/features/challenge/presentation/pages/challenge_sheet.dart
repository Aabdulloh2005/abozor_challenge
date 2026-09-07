import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/invite.dart';
import '../../../lottery/presentation/cubit/coupon_cubit.dart';
import '../bloc/challenge_bloc.dart';
import '../widgets/car_list_view.dart';
import '../widgets/question_view.dart';
import '../widgets/success_view.dart';

/// Saytdagi "Abozor Challenge" bottom sheet'i.
class ChallengeSheet extends StatelessWidget {
  const ChallengeSheet({
    super.key,
    this.onOpenAiAssistant,
    this.onOpenProfile,
  });

  final VoidCallback? onOpenAiAssistant;
  final VoidCallback? onOpenProfile;

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
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        onTap: () => state.step == ChallengeStep.carList
                            ? Navigator.of(context).pop()
                            : bloc.add(const ChallengeBackPressed()),
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
                  switch (state.step) {
                    ChallengeStep.carList => const ChallengeCarListView(),
                    ChallengeStep.question => ChallengeQuestionView(state: state),
                    ChallengeStep.success => ChallengeSuccessView(
                        onBack: () => bloc.add(const ChallengeBackPressed()),
                        onInviteFriend: () => InviteHelper.invite(context),
                        onValuateOwnCar: () {
                          Navigator.of(context).pop();
                          onOpenAiAssistant?.call();
                        },
                        onOpenProfile: () {
                          Navigator.of(context).pop();
                          onOpenProfile?.call();
                        },
                      ),
                  },
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showWrongDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abozor AI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            "Xohlaysizmi, to'g'ri javobni aytib beraman va keyin siz qayta uring",
                            style: TextStyle(fontSize: 12, height: 1.35),
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
