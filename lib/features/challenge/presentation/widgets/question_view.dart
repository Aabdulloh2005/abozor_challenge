import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/asset_image_box.dart';
import '../../../ai_valuation/domain/repositories/valuation_repository.dart';
import '../../../ai_valuation/presentation/bloc/ai_chat_bloc.dart';
import '../../../ai_valuation/presentation/widgets/ai_chat_panel.dart';
import '../../domain/entities/challenge_car.dart';
import '../bloc/challenge_bloc.dart';

/// Animatsiya davomiyligi — mashina kartasi kichrayib pin bo'lishi.
const _kMorphDuration = Duration(milliseconds: 420);
const _kMorphCurve = Curves.easeInOutCubic;

/// 2-qadam: mashina kartochkasi, UZS/USD, 3 ta narx varianti va AI paneli.
///
/// AI ochilganda (Bilmayapsizmi / Javobni bilish) mashina kartasi kichrayib
/// tepada pin bo'lib qoladi — user ma'lumotlarni eslab qolishi shart emas.
class ChallengeQuestionView extends StatelessWidget {
  const ChallengeQuestionView({super.key, required this.state});

  final ChallengeState state;

  @override
  Widget build(BuildContext context) {
    final car = state.car;
    if (car == null) return const SizedBox.shrink();
    final bloc = context.read<ChallengeBloc>();
    final aiMode = state.aiPanelOpen;

    return Column(
      mainAxisSize: aiMode ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orqaga qaytish faqat sheet header'idagi strelkada — takrorlanmaydi.
        if (!aiMode) ...[
          Align(
            alignment: Alignment.centerRight,
            child: _CurrencyToggle(
              currency: state.currency,
              onChanged: (value) => bloc.add(ChallengeCurrencyToggled(value)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Katta kartochka <-> pin qilingan kichik kartochka.
        AnimatedCrossFade(
          duration: _kMorphDuration,
          sizeCurve: _kMorphCurve,
          firstCurve: _kMorphCurve,
          secondCurve: _kMorphCurve,
          alignment: Alignment.topCenter,
          crossFadeState:
              aiMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: _ExpandedCarCard(car: car),
          secondChild: _PinnedCarCard(car: car),
        ),
        const SizedBox(height: AppSpacing.md),

        // Narx variantlari — AI ochilganda yig'ilib ketadi.
        AnimatedSize(
          duration: _kMorphDuration,
          curve: _kMorphCurve,
          alignment: Alignment.topCenter,
          child: aiMode
              ? const SizedBox(width: double.infinity)
              : _OptionsSection(state: state, car: car, bloc: bloc),
        ),

        if (aiMode)
          Expanded(child: _AiPanel(car: car, bloc: bloc))
        else
          _HintCard(
            onTap: () => bloc.add(const ChallengeAiPanelToggled(open: true)),
          ),
      ],
    );
  }
}

/// AI chat paneli (pin rejimida qolgan joyni to'ldiradi).
class _AiPanel extends StatelessWidget {
  const _AiPanel({required this.car, required this.bloc});

  final ChallengeCar car;
  final ChallengeBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiChatBloc(context.read<ValuationRepository>())
        ..add(
          AiChatStarted(
            intro:
                "Bilmayapsizmi? Abozor AI bilan birga narxni topamiz. Savollarga javob bering.",
            reveal: AiRevealTarget(
              carName: car.name,
              correctPrice: car.correctPrice,
            ),
          ),
        ),
      child: AiChatPanel(
        expand: true,
        // Yopish tugmasi yo'q: chiqish yo'li bitta — chat oxiridagi
        // "Savolga qaytish" (yoki header'dagi strelka, majburiy rejim bo'lmasa).
        finishedActionLabel: 'Savolga qaytish',
        onFinishedAction: () => bloc.add(const ChallengeAiPanelToggled(open: false)),
      ),
    );
  }
}

/// Odatdagi (katta) mashina kartochkasi.
class _ExpandedCarCard extends StatelessWidget {
  const _ExpandedCarCard({required this.car});

  final ChallengeCar car;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetImageBox(asset: car.image, height: 170, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _SpecTile(label: 'YILI', value: '${car.year}')),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _SpecTile(
                        label: 'YURGAN',
                        value: PriceFormatter.km(car.mileage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(child: _SpecTile(label: 'RANGI', value: car.color)),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _SpecTile(label: 'UZATMA', value: car.transmission),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// AI chat davomida tepada turadigan kichik kartochka.
class _PinnedCarCard extends StatelessWidget {
  const _PinnedCarCard({required this.car});

  final ChallengeCar car;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetImageBox(
            asset: car.image,
            height: 48,
            width: 72,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _MiniChip(text: '${car.year}'),
                    _MiniChip(text: PriceFormatter.km(car.mileage)),
                    _MiniChip(text: car.color),
                    _MiniChip(text: car.transmission),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.push_pin_rounded,
            size: 14,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryForeground,
        ),
      ),
    );
  }
}

/// "Bozor narxi qancha?" + 3 ta variant.
class _OptionsSection extends StatelessWidget {
  const _OptionsSection({
    required this.state,
    required this.car,
    required this.bloc,
  });

  final ChallengeState state;
  final ChallengeCar car;
  final ChallengeBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bozor narxi qancha?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final option in car.options) ...[
          _PriceOption(
            label: PriceFormatter.format(option, state.currency),
            selected: state.selectedPrice == option,
            onTap: () => bloc.add(ChallengeAnswerSelected(option)),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.currency, required this.onChanged});

  final Currency currency;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in Currency.values)
            GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: currency == value ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  value.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: currency == value
                        ? Colors.white
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  const _PriceOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Bilmayapsizmi? To'g'ri javob shu yerda" kartasi.
class _HintCard extends StatelessWidget {
  const _HintCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 17, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bilmayapsizmi?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "To'g'ri javob shu yerda",
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
