import 'package:flutter/material.dart';

import '../core/widgets/app_bottom_nav.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

/// Pastki navigatsiyali asosiy karkas.
/// Saytda "Auksionlarim / Sotuv / Bildirishnoma" hali bosh sahifaga olib boradi —
/// shuning uchun bu yerda ham ular bosh sahifada qoladi.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _onTap(int value) {
    setState(() => _index = value == 4 ? 4 : 0);
  }

  void _openProfile() => setState(() => _index = 4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _index == 4
          ? const ProfileView()
          : HomeView(onOpenProfile: _openProfile),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _onTap,
      ),
    );
  }
}
