import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Saytdagi "Do'stni taklif qilish (+1)" tugmasi hech narsa qilmaydi —
/// bu yerda kutilgan xatti-harakat: referal havolani nusxalash.
/// Real referal kodi backend'dan kelishi kerak.
abstract final class InviteHelper {
  static const String referralLinkTemplate =
      'https://abozor.uz/challenge?ref={code}';

  static Future<void> invite(BuildContext context, {String code = 'DEMO123'}) async {
    final link = referralLinkTemplate.replaceAll('{code}', code);
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Taklif havolasi nusxalandi: $link'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
