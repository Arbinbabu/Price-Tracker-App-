import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_tracker_app/models/product_model.dart';
import 'package:price_tracker_app/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final trackedProductsProvider = StreamProvider<List<ProductModel>>(
  (ref) => ref.watch(firestoreServiceProvider).trackedProductsStream(),
);
