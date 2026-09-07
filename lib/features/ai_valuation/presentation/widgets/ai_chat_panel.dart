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
  });

  final VoidCallback? onClose;
  final String? finishedActionLabel;
  final VoidCallback? onFinishedAction;
  final bool showHeader;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  controller: _scrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    if (index >= state.messages.length) {
                      return const _Bubble(
                        role: ChatRole.bot,
                        text: 'Baholanmoqda...',
                      );
                    }
                    final message = state.messages[index];
                    return _Bubble(role: message.role, text: message.text);
                  },
                ),
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
  const _Bubble({required this.role, required this.text});

  final ChatRole role;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isUser = role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
            color: isUser ? Colors.white : AppColors.foreground,
          ),
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
