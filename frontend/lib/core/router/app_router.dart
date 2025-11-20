import 'package:go_router/go_router.dart';
import 'package:recycling_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:recycling_platform/features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
