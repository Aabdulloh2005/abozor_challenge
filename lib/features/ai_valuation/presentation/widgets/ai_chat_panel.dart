import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../bloc/ai_chat_bloc.dart';

/// Saytdagi "Abozor AI narxlash" chat bloki.
/// Ham challenge ichida, ham mustaqil sheet ichida ishlatiladi.
class AiChatPanel extends StatefulWidget {
  const AiChatPanel({
    super.key,
    this.onClose,
    this.finishedActionLabel,
    this.onFinishedAction,
    this.showHeader = true,
    this.expand = false,
  });

  final VoidCallback? onClose;
  final String? finishedActionLabel;
  final VoidCallback? onFinishedAction;
  final bool showHeader;

  /// true bo'lsa chat mavjud balandlikni to'ldiradi (pin qilingan rejim).
  final bool expand;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// Yozib bo'lingan (animatsiyasi tugagan) bot xabarlari — qayta yozilmasin.
  final _typedMessages = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<AiChatBloc>().add(AiChatAnswerSubmitted(text));
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  String _messageKey(int index, ChatMessage message) =>
      '$index:${message.role.name}:${message.text.hashCode}';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        final messages = ListView.separated(
          controller: _scrollController,
          shrinkWrap: !widget.expand,
          padding: EdgeInsets.zero,
          itemCount: state.messages.length + (state.isTyping ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            if (index >= state.messages.length) {
              // AI hisoblayotgan payt: "Baholanmoqda" + jonli nuqtalar.
              return const _ThinkingBubble();
            }
            final message = state.messages[index];
            final key = _messageKey(index, message);
            final animate =
                message.role == ChatRole.bot && !_typedMessages.contains(key);
            return _Bubble(
              key: ValueKey(key),
              role: message.role,
              text: message.text,
              animate: animate,
              onProgress: _scrollToBottom,
              onCompleted: () => _typedMessages.add(key),
            );
          },
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abozor AI narxlash',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Ma'lumotlarni kiritib borib narxni bilib oling",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: AppColors.mutedForeground,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (widget.expand)
                Expanded(child: messages)
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: messages,
                ),
              const SizedBox(height: AppSpacing.sm),
              if (state.finished && widget.finishedActionLabel != null)
                FilledButton(
                  onPressed: widget.onFinishedAction,
                  child: Text(widget.finishedActionLabel!),
                )
              else
                _InputRow(
                  controller: _controller,
                  enabled: state.canType,
                  onSend: _send,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.role,
    required this.text,
    this.animate = false,
    this.onCompleted,
    this.onProgress,
  });

  final ChatRole role;
  final String text;
  final bool animate;
  final VoidCallback? onCompleted;
  final VoidCallback? onProgress;

  @override
  Widget build(BuildContext context) {
    final isUser = role == ChatRole.user;
    final style = TextStyle(
      fontSize: 12.5,
      height: 1.4,
      fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
      color: isUser ? Colors.white : AppColors.foreground,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: animate
            ? TypingText(
                text: text,
                style: style,
                onCompleted: onCompleted,
                onProgress: onProgress,
              )
            : Text(text, style: style),
      ),
    );
  }
}

/// Matnni harfma-harf yozadi — AI yozayotgandek ko'rinadi.
class TypingText extends StatefulWidget {
  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.onCompleted,
    this.onProgress,
    this.tick = const Duration(milliseconds: 16),
  });

  final String text;
  final TextStyle style;
  final VoidCallback? onCompleted;
  final VoidCallback? onProgress;
  final Duration tick;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  Timer? _timer;
  int _visible = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _visible = 0;
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    // Uzun matn tezroq yozilsin (bir tikda bir nechta belgi).
    final step = math.max(1, widget.text.length ~/ 110);
    _timer = Timer.periodic(widget.tick, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _visible = math.min(widget.text.length, _visible + step);
      });
      widget.onProgress?.call();
      if (_visible >= widget.text.length) {
        timer.cancel();
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _visible >= widget.text.length;
    return Text.rich(
      TextSpan(
        text: widget.text.substring(0, _visible),
        children: [
          if (!done)
            TextSpan(
              text: '▌',
              style: widget.style.copyWith(color: AppColors.primary),
            ),
        ],
      ),
      style: widget.style,
    );
  }
}

/// "Baholanmoqda" + sakrab turgan uchta nuqta.
class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Baholanmoqda',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final t = (_controller.value * 3 - index).clamp(0.0, 1.0);
                    final opacity = 0.25 + 0.75 * math.sin(t * math.pi).abs();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          height: 5,
                          width: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Javobingizni yozing...',
              hintStyle: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        InkWell(
          onTap: enabled ? onSend : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary : AppColors.mutedForeground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}
