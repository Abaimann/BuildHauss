import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/motorcycles/presentation/screens/add_motorcycle_screen.dart';
import '../../features/motorcycles/presentation/screens/edit_motorcycle_screen.dart';
import '../../features/health/presentation/screens/health_screen.dart';
import '../../features/parts/presentation/screens/parts_catalog_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/complaints/presentation/screens/complaint_detail_screen.dart';
import '../../features/complaints/presentation/screens/new_complaint_screen.dart';
import '../../features/service_history/presentation/screens/add_service_screen.dart';
import '../../features/self_inspection/presentation/screens/self_inspection_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_model_manager_screen.dart';
import '../../features/mileage/presentation/screens/odometer_screen.dart';
import '../../features/mileage/presentation/screens/odometer_history_screen.dart';
import '../../features/settings/presentation/screens/coming_soon_screen.dart';
import '../../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/health',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HealthScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/parts',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: PartsCatalogScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HistoryScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: AccountScreen()),
            ),
          ],
        ),
      ],
    ),
    // Non-shell routes
    GoRoute(
      path: '/add-motor',
      builder: (_, __) => const AddMotorcycleScreen(),
    ),
    GoRoute(
      path: '/motor/:id/edit',
      builder: (_, state) =>
          EditMotorcycleScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/motor/:id/odometer',
      builder: (_, state) =>
          OdometerScreen(motorcycleId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/motor/:id/odometer-history',
      builder: (_, state) => OdometerHistoryScreen(
        motorcycleId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/motor/:id/inspection',
      builder: (_, state) => SelfInspectionScreen(
        motorcycleId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/motor/:id/service/add',
      builder: (_, state) => AddServiceScreen(
        motorcycleId: int.parse(state.pathParameters['id']!),
      ),
    ),

    // Placeholder routes (feature not yet implemented)
    GoRoute(
      path: '/motor/:id/reminder/add',
      builder: (_, state) => ComingSoonScreen(
        title: 'Tambah Pengingat',
        description:
            'Fitur pengingat servis berdasarkan jarak tempuh atau tanggal. Akan hadir di versi berikutnya.',
        icon: Icons.notifications_outlined,
        backRoute: '/home',
      ),
    ),
    GoRoute(
      path: '/motor/:id/reminders',
      builder: (_, state) => ComingSoonScreen(
        title: 'Daftar Pengingat',
        description:
            'Pengingat servis yang sudah dibuat. Akan hadir di versi berikutnya.',
        icon: Icons.notifications_active_outlined,
        backRoute: '/home',
      ),
    ),
    GoRoute(
      path: '/motor/:id/expense/add',
      builder: (_, state) => ComingSoonScreen(
        title: 'Catat Pengeluaran',
        description:
            'Catat pengeluaran sparepart dan biaya servis. Akan hadir di versi berikutnya.',
        icon: Icons.receipt_long_outlined,
        backRoute: '/home',
      ),
    ),
    GoRoute(
      path: '/motor/:id/oil/add',
      builder: (_, state) => ComingSoonScreen(
        title: 'Catat Ganti Oli',
        description:
            'Catat penggantian oli mesin dengan cepat. Akan hadir di versi berikutnya.',
        icon: Icons.opacity_outlined,
        backRoute: '/home',
      ),
    ),

    // AI routes
    GoRoute(
      path: '/ai-recommendation',
      builder: (_, __) => const AiAssistantScreen(),
    ),
    GoRoute(path: '/ai-chat', builder: (_, __) => const AiAssistantScreen()),
    GoRoute(
      path: '/ai-model',
      builder: (_, __) => const AiModelManagerScreen(),
    ),

    // Budget route
    GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),

    // Placeholder: backup, restore, licenses
    GoRoute(
      path: '/backup',
      builder: (_, __) => const ComingSoonScreen(
        title: 'Backup Data',
        description:
            'Backup semua data motor ke file lokal. Fitur ini akan segera hadir.',
        icon: Icons.cloud_upload_outlined,
        backRoute: '/account',
      ),
    ),
    GoRoute(
      path: '/restore',
      builder: (_, __) => const ComingSoonScreen(
        title: 'Pulihkan Data',
        description:
            'Pulihkan data dari file backup. Fitur ini akan segera hadir.',
        icon: Icons.cloud_download_outlined,
        backRoute: '/account',
      ),
    ),
    GoRoute(
      path: '/licenses',
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Lisensi')),
        body: const Center(
          child: Text('Lisensi pihak ketiga akan ditampilkan di sini.'),
        ),
      ),
    ),

    // Complaints
    GoRoute(path: '/complaints', builder: (_, __) => const ComplaintsScreen()),
    GoRoute(
      path: '/complaints/new',
      builder: (_, __) => const NewComplaintScreen(),
    ),
    GoRoute(
      path: '/complaints/:id',
      builder: (_, state) => ComplaintDetailScreen(
        complaintId: int.parse(state.pathParameters['id']!),
      ),
    ),

    // History
    GoRoute(path: '/history/add', builder: (_, __) => const AddServiceScreen()),
  ],
);
