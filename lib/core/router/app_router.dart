import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/identity/screens/identity_verification_screen.dart';
import '../../features/resume/screens/resume_analysis_screen.dart';
import '../../features/skills/screens/skill_verification_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/settings/screens/privacy_policy_screen.dart';
import '../../features/settings/screens/about_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.read(authServiceProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authServiceProvider).currentUser != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isSplash = state.uri.toString() == '/splash';
      final isForgotPassword = state.uri.toString() == '/forgot-password';
      final isResetPassword = state.uri.toString() == '/reset-password';

      // Allow splash screen to show first
      if (isSplash) {
        return null;
      }

      if (!isLoggedIn && !isLoggingIn && !isSigningUp && !isForgotPassword && !isResetPassword) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isSigningUp)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/identity',
        builder: (context, state) => const IdentityVerificationScreen(),
      ),
      GoRoute(
        path: '/resume',
        builder: (context, state) => const ResumeAnalysisScreen(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillVerificationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
