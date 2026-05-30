import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:price_tracker_app/core/constants.dart';
import 'package:price_tracker_app/features/home/providers/products_provider.dart';
import 'package:price_tracker_app/models/price_history_model.dart';
import 'package:price_tracker_app/models/product_model.dart';

final selectedProductProvider = StreamProvider.family<ProductModel?, String>(
  (ref, productId) => ref.watch(firestoreServiceProvider).productStream(productId),
);

final productHistoryProvider = StreamProvider.family<List<PriceHistoryModel>, String>(
  (ref, productId) => ref.watch(firestoreServiceProvider).priceHistoryStream(productId),
);

class AddProductController extends StateNotifier<AsyncValue<String?>> {
  AddProductController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<String> addProduct(String url) async {
    state = const AsyncLoading();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse(AppConstants.addProductFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url, 'userId': uid}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add product: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final productId = data['productId'] as String;
    state = AsyncData(productId);
    return productId;
  }
}

final addProductControllerProvider = StateNotifierProvider<AddProductController, AsyncValue<String?>>(
  (ref) => AddProductController(ref),
);
