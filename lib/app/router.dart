import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:price_tracker_app/features/alerts/screens/notifications_screen.dart';
import 'package:price_tracker_app/features/auth/screens/login_screen.dart';
import 'package:price_tracker_app/features/auth/screens/register_screen.dart';
import 'package:price_tracker_app/features/home/screens/home_screen.dart';
import 'package:price_tracker_app/features/product/screens/add_product_screen.dart';
import 'package:price_tracker_app/features/product/screens/product_detail_screen.dart';
import 'package:price_tracker_app/features/settings/screens/settings_screen.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AuthRefreshNotifier(),
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    if (user == null && !isAuthRoute) return '/login';
    if (user != null && isAuthRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/add-product', builder: (_, __) => const AddProductScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
