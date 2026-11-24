import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/initial_motor_setup_screen.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!authState.isLoggedIn) {
      return const AuthScreen();
    }

    if (!authState.isOnboardingCompleted) {
      return const InitialMotorSetupScreen();
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _CyberBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _CyberBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _CyberBottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Batasi skala teks agar 5 label nav bar ('Sparepart') tetap 1 baris di 320px-360px.
    final maxNavScale = screenWidth < 360
        ? 1.0
        : (screenWidth < 400 ? 1.08 : 1.15);

    final baseTheme = Theme.of(context).navigationBarTheme;
    final effectiveNavTheme =
        screenWidth < 360 && baseTheme.labelTextStyle != null
            ? baseTheme.copyWith(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  return baseTheme.labelTextStyle!
                      .resolve(states)
                      ?.copyWith(fontSize: 10);
                }),
              )
            : baseTheme;

    final navBg =
        isDark ? BuildHausTheme.darkSurface : BuildHausTheme.lightSurface;
    final topBorderColor =
        isDark ? BuildHausTheme.darkLine : BuildHausTheme.lightLine;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: topBorderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: isDark ? 20 : 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxNavScale,
        child: NavigationBarTheme(
          data: effectiveNavTheme,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            animationDuration: const Duration(milliseconds: 350),
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: _AnimatedNavIcon(icon: Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon:
                    _AnimatedNavIcon(icon: Icons.monitor_heart_rounded),
                label: 'Sehat',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_circle_outlined),
                selectedIcon:
                    _AnimatedNavIcon(icon: Icons.build_circle_rounded),
                label: 'Sparepart',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: _AnimatedNavIcon(icon: Icons.history_rounded),
                label: 'Riwayat',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: _AnimatedNavIcon(icon: Icons.person_rounded),
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  const _AnimatedNavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Icon(
        icon,
        shadows: isDark
            ? [
                Shadow(
                  color: BuildHausTheme.darkAccent.withValues(alpha: 0.45),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }
}
