import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/invite.dart';
import '../../../../core/widgets/asset_image_box.dart';
import '../../../ai_valuation/presentation/pages/ai_assistant_page.dart';
import '../../../challenge/data/challenge_data.dart';
import '../../../challenge/domain/entities/prize.dart';
import '../../../challenge/presentation/pages/challenge_sheet.dart';
import '../cubit/participation_cubit.dart';

/// "Sovrinlarim" — foydalanuvchi qaysi sovrinlarda ishtirok etayotgani,
/// yakungacha qancha qolgani va keyingi qadam nimaligini ko'rsatadi.
class MyPrizesPage extends StatelessWidget {
  const MyPrizesPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const MyPrizesPage());

  void _openChallenge(BuildContext context, Prize prize) {
    ChallengeSheet.show(
      context,
      initialPrize: prize,
      onOpenAiAssistant: () => AiAssistantPage.open(context),
      onOpenProfile: () => Navigator.of(context).maybePop(),
    );
  }

  void _share(BuildContext context) {
    InviteHelper.invite(context);
    context.read<ParticipationCubit>().registerShare();
  }

  @override
  Widget build(BuildContext context) {
    final grand = ChallengeData.grandPrize;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Sovrinlarim'),
      ),
      body: BlocBuilder<ParticipationCubit, ParticipationState>(
        builder: (context, state) {
          final regular = ChallengeData.prizes.where((p) => !p.isGrand).toList();
          final joined = regular
              .where((p) => state.isParticipating(p.id, isGrand: false))
              .toList();
          final available = regular
              .where((p) => !state.isParticipating(p.id, isGrand: false))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.xl,
            ),
            children: [
              _StatusCard(state: state),
              const SizedBox(height: AppSpacing.md),
              _GrandPrizeCard(
                prize: grand,
                state: state,
                onStartQuiz: () => _openChallenge(context, grand),
                onShare: () => _share(context),
              ),
              if (joined.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle('Ishtirok etayotgan sovrinlaringiz'),
                const SizedBox(height: AppSpacing.sm),
                for (final prize in joined) ...[
                  _PrizeRow(prize: prize, participating: true),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                joined.isEmpty ? 'Sovrinlar' : 'Yana ishtirok etishingiz mumkin',
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final prize in available) ...[
                _PrizeRow(
                  prize: prize,
                  participating: false,
                  onTap: () => _openChallenge(context, prize),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Column(
                  children: [
                    Text(
                      "G'oliblar ${_formatDate(ChallengeData.drawDate)} kuni "
                      'tasodifiy tanlov bilan aniqlanadi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRules(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Konkurs qoidalari',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRules(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konkurs qoidalari',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            ...[
              'Ishtirok bepul — hech qanday to\'lov talab qilinmaydi.',
              'Har bir sovrin uchun mashina bozor narxini to\'g\'ri toping.',
              'Oliy bosh sovrin uchun qo\'shimcha shart: taklif havolangizni ulashing.',
              "G'oliblar ${_formatDate(ChallengeData.drawDate)} kuni tasodifiy tanlanadi.",
              "Natijalar Abozor ilovasida e'lon qilinadi.",
            ].map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
    'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
  ];
  return '${date.day}-${months[date.month - 1]}';
}

/// Yuqoridagi holat kartasi: yakungacha qancha qolgani + statistika.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final ParticipationState state;

  @override
  Widget build(BuildContext context) {
    final left = ChallengeData.drawDate.difference(DateTime.now()).inDays;
    final daysLeft = left < 0 ? 0 : left;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.hourglass_bottom_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Konkurs yakuni — ${_formatDate(ChallengeData.drawDate)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$daysLeft kun qoldi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ParticipationStat(
            joined: state.participatingCount,
            total: ChallengeData.prizes.length,
          ),
        ],
      ),
    );
  }
}

/// "7 sovrindan 2 tasida ishtirok etyapsiz" — yagona, real ko'rsatkich.
class _ParticipationStat extends StatelessWidget {
  const _ParticipationStat({required this.joined, required this.total});

  final int joined;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 18,
            color: Colors.white70,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              joined == 0
                  ? "$total sovrindan hech birida ishtirok etmayapsiz"
                  : '$total sovrindan $joined tasida ishtirok etyapsiz',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oliy sovrin: ikki qadamli checklist + progress.
class _GrandPrizeCard extends StatelessWidget {
  const _GrandPrizeCard({
    required this.prize,
    required this.state,
    required this.onStartQuiz,
    required this.onShare,
  });

  final Prize prize;
  final ParticipationState state;
  final VoidCallback onStartQuiz;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final quizDone = state.quizDoneFor(prize.id);
    final shared = state.shared;
    final done = (quizDone ? 1 : 0) + (shared ? 1 : 0);
    final complete = done == 2;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: complete ? AppColors.success : AppColors.primary,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AssetImageBox(
                asset: prize.image,
                height: 130,
                width: double.infinity,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'OLIY BOSH SOVRIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                bottom: AppSpacing.sm,
                right: AppSpacing.md,
                child: Text(
                  prize.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (complete)
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Ishtirok tasdiqlandi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Ishtirok uchun $done/2 qadam bajarildi',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: done / 2,
                    minHeight: 6,
                    backgroundColor: AppColors.secondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      complete ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _StepRow(
                  index: 1,
                  label: 'Avtomobil narxini to\'g\'ri toping',
                  done: quizDone,
                  actionLabel: 'Boshlash',
                  onAction: onStartQuiz,
                ),
                const SizedBox(height: AppSpacing.xs),
                _StepRow(
                  index: 2,
                  label: "Taklif havolasini do'stingizga ulashing",
                  done: shared,
                  actionLabel: 'Ulashish',
                  onAction: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.label,
    required this.done,
    required this.actionLabel,
    required this.onAction,
  });

  final int index;
  final String label;
  final bool done;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: done ? AppColors.success : AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: done ? AppColors.mutedForeground : AppColors.foreground,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (!done)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

class _PrizeRow extends StatelessWidget {
  const _PrizeRow({
    required this.prize,
    required this.participating,
    this.onTap,
  });

  final Prize prize;
  final bool participating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AssetImageBox(
            asset: prize.image,
            height: 44,
            width: 60,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prize.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prize.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (participating)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 13, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Ishtirokdasiz',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: const Text('Ishtirok etish'),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    );
  }
}
