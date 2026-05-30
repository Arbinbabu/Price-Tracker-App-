import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_tracker_app/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider = StreamProvider((ref) => ref.watch(authServiceProvider).authStateChanges());
