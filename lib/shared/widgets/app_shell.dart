import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 350),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: _AnimatedNavIcon(icon: Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: _AnimatedNavIcon(icon: Icons.favorite),
            label: 'Sehat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: _AnimatedNavIcon(icon: Icons.settings),
            label: 'Sparepart',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: _AnimatedNavIcon(icon: Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: _AnimatedNavIcon(icon: Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  const _AnimatedNavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Icon(icon),
    );
  }
}
