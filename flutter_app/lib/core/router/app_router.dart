import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/pairing/presentation/pairing_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/tasks/presentation/create_task_page.dart';
import '../../features/tasks/presentation/submit_proof_page.dart';
import '../../features/tasks/presentation/task_detail_page.dart';
import '../../features/tasks/presentation/tasks_page.dart';
import '../../features/wallet/presentation/wallet_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/pairing', builder: (_, __) => const PairingPage()),
      GoRoute(path: '/create-task', builder: (_, __) => const CreateTaskPage()),
      GoRoute(path: '/task/:id', builder: (_, state) => TaskDetailPage(taskId: state.pathParameters['id']!)),
      GoRoute(path: '/submit-proof/:id', builder: (_, state) => SubmitProofPage(taskId: state.pathParameters['id']!)),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/tasks', builder: (_, __) => const TasksPage())]),
          StatefulShellBranch(routes: [GoRoute(path: '/wallet', builder: (_, __) => const WalletPage())]),
        ],
      ),
    ],
  );
});

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.check_mark_circled_solid), label: '任务'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.money_yen_circle), label: '货币'),
        ],
      ),
      tabBuilder: (_, __) => navigationShell,
    );
  }
}
