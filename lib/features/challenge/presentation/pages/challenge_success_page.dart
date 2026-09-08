import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/invite.dart';
import '../../../prizes/presentation/cubit/participation_cubit.dart';
import '../../domain/entities/prize.dart';

/// To'g'ri javobdan keyin ochiladigan ALOHIDA ekran (pop-up emas).
/// Ochilishi tantanali: konfetti, "check" belgisining sakrab chiqishi va
/// matn/tugmalarning ketma-ket paydo bo'lishi.
class ChallengeSuccessPage extends StatefulWidget {
  const ChallengeSuccessPage({
    super.key,
    this.prize,
    this.onValuateOwnCar,
    this.onOpenProfile,
  });

  /// Foydalanuvchi tanlagan sovrin. Oliy sovrin bo'lsa — ishtirokni tasdiqlash
  /// uchun havolani ulashish SHU ekranda so'raladi (boshida emas).
  final Prize? prize;
  final VoidCallback? onValuateOwnCar;
  final VoidCallback? onOpenProfile;

  static Route<void> route({
    Prize? prize,
    VoidCallback? onValuateOwnCar,
    VoidCallback? onOpenProfile,
  }) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ChallengeSuccessPage(
        prize: prize,
        onValuateOwnCar: onValuateOwnCar,
        onOpenProfile: onOpenProfile,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ChallengeSuccessPage> createState() => _ChallengeSuccessPageState();
}

class _ChallengeSuccessPageState extends State<ChallengeSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  late final List<_ConfettiPiece> _pieces = _ConfettiPiece.generate(46);

  /// Oliy sovrin uchun havola ulashildimi.
  bool _shared = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _controller.forward();
    // To'g'ri javob = shu sovrinda ishtirok qozonildi.
    final prize = widget.prize;
    if (prize != null) context.read<ParticipationCubit>().join(prize.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Oddiy sovrin: ulashish ixtiyoriy.
  Widget _plainShareButton() {
    return FilledButton.icon(
      onPressed: () {
        InviteHelper.invite(context);
        context.read<ParticipationCubit>().registerShare();
      },
      icon: const Icon(Icons.share_outlined, size: 18),
      label: const Text("Do'stni taklif qilish"),
    );
  }

  /// Oliy bosh sovrin: ishtirokni tasdiqlash uchun havolani ulashish shart.
  Widget _grandShareBlock() {
    if (_shared) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: AppColors.success),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Ishtirokingiz tasdiqlandi — havola nusxalandi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Oliy bosh sovrin uchun oxirgi qadam',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ishtirokingiz hisobga olinishi uchun taklif havolangizni do'stingizga "
            'ulashing.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () {
              InviteHelper.invite(context);
              context.read<ParticipationCubit>().registerShare();
              setState(() => _shared = true);
            },
            icon: const Icon(Icons.share_outlined, size: 18),
            label: const Text('Ulashib, ishtirokni tasdiqlash'),
          ),
        ],
      ),
    );
  }

  Animation<double> _step(double begin, double end, {Curve curve = Curves.easeOutCubic}) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final check = _step(0, 0.30, curve: Curves.elasticOut);
    final title = _step(0.18, 0.42);
    final subtitle = _step(0.26, 0.50);
    final prize = widget.prize;
    final isGrand = prize?.isGrand ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Tantanali fon: yumshoq yashil nur.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.45),
                  radius: 0.9,
                  colors: [
                    AppColors.successSoft,
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    progress: _controller.value,
                    pieces: _pieces,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        ScaleTransition(
                          scale: check,
                          child: _CheckBadge(controller: _controller),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _Reveal(
                          animation: title,
                          child: const Text(
                            "To'g'ri javob!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Reveal(
                          animation: subtitle,
                          child: Text(
                            prize == null
                                ? 'Tabriklaymiz — bozor narxini aniq topdingiz.'
                                : 'Tabriklaymiz — ${prize.title} uchun o\'yinda '
                                    'ishtirok etyapsiz.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _Reveal(
                          animation: _step(0.36, 0.58),
                          child: isGrand ? _grandShareBlock() : _plainShareButton(),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _Reveal(
                          animation: _step(0.44, 0.66),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onValuateOwnCar?.call();
                            },
                            child: const Text('Avtomobilingiz narxini bilib oling'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _Reveal(
                          animation: _step(0.52, 0.74),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onOpenProfile?.call();
                            },
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.foreground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                            ),
                            icon: const Icon(Icons.person_outline_rounded, size: 18),
                            label: const Text(
                              "Profilga o'tish",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Yashil belgi + orqasida kengayib yo'qoladigan halqa.
class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final ring = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.08, 0.55, curve: Curves.easeOut),
    );
    return SizedBox(
      height: 150,
      width: 150,
      child: AnimatedBuilder(
        animation: ring,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 60 + 90 * ring.value,
                width: 60 + 90 * ring.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(
                      alpha: 0.45 * (1 - ring.value),
                    ),
                    width: 2,
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          height: 96,
          width: 96,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
        ),
      ),
    );
  }
}

/// Pastdan suzib chiqadigan element.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.22),
          end: Offset.zero,
        ).animate(animation),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.color,
    required this.width,
    required this.height,
  });

  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double spin;
  final Color color;
  final double width;
  final double height;

  static const _palette = <Color>[
    AppColors.primary,
    AppColors.success,
    Color(0xFFE0A400),
    Color(0xFF2C7BE5),
    Color(0xFFEC6FA0),
  ];

  static List<_ConfettiPiece> generate(int count) {
    final random = math.Random(11);
    return List<_ConfettiPiece>.generate(count, (index) {
      return _ConfettiPiece(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.25,
        speed: 0.7 + random.nextDouble() * 0.6,
        drift: (random.nextDouble() - 0.5) * 0.35,
        spin: (random.nextDouble() - 0.5) * 12,
        color: _palette[index % _palette.length],
        width: 5 + random.nextDouble() * 5,
        height: 9 + random.nextDouble() * 8,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.pieces});

  final double progress;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      final local = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final travel = local * piece.speed;
      final dy = -0.12 * size.height + travel * size.height * 1.25;
      if (dy > size.height) continue;
      final dx = (piece.x + piece.drift * local) * size.width;
      final opacity = (1 - math.pow(local, 3).toDouble()).clamp(0.0, 1.0);

      paint.color = piece.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.spin * local);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
