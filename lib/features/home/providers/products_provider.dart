import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../models/product_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/backend_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final backendServiceProvider = Provider<BackendService>((ref) => BackendService());

final trackedProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value(const <ProductModel>[]);
  }

  final useBackend = dotenv.env['USE_BACKEND'] == 'true';
  if (useBackend) {
    return ref.watch(backendServiceProvider).getUserTrackedProducts(uid);
  }

  return ref.watch(firestoreServiceProvider).getUserTrackedProducts(uid);
});