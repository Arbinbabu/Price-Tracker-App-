import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:price_tracker_app/features/auth/providers/auth_provider.dart';
import 'package:price_tracker_app/services/notification_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      await NotificationService.syncTokenForCurrentUser();
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      await NotificationService.syncTokenForCurrentUser();
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _login, child: const Text('Login')),
            TextButton(onPressed: () => context.go('/register'), child: const Text('Create account')),
            OutlinedButton(
              onPressed: _loading ? null : _googleSignIn,
              child: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
