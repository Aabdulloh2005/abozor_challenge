import 'package:flutter/material.dart';

import 'main_shell.dart';
import 'theme/app_theme.dart';

class AbozorChallengeApp extends StatelessWidget {
  const AbozorChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abozor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}
