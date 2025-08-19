import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthStateWrapper extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthStateWrapper({
    Key? key,
    required this.child,
    this.requireAuth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Show loading during initial state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isAuthenticated = AuthService.instance.isAuthenticated;

        // If auth is required but user is not authenticated
        if (requireAuth && !isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.welcome,
              (route) => false,
            );
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated but on auth screens, redirect to main app
        if (isAuthenticated && _isAuthScreen(context)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.medicationList,
              (route) => false,
            );
          });
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return child;
      },
    );
  }

  bool _isAuthScreen(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) return false;

    final routeName = route.settings.name;
    return routeName == AppRoutes.welcome ||
        routeName == AppRoutes.phoneLogin ||
        routeName == AppRoutes.otpVerification;
  }
}
