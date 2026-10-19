import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Generic placeholder screen for features that are not yet implemented.
/// Shows a "coming soon" message with an icon and description.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? backRoute;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction,
    this.backRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (backRoute != null) {
              context.go(backRoute!);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 40, color: context.muted),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: context.muted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '🛠️ Dalam pengembangan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
