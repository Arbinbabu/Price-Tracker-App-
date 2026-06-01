import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../models/price_history_model.dart';
import '../../../models/product_model.dart';
import '../../home/providers/products_provider.dart';

final productProvider = StreamProvider.family<ProductModel?, String>((ref, productId) {
  final useBackend = dotenv.env['USE_BACKEND'] == 'true';
  if (useBackend) return ref.watch(backendServiceProvider).watchProduct(productId);
  return ref.watch(firestoreServiceProvider).watchProduct(productId);
});

final priceHistoryProvider = StreamProvider.family<List<PriceHistoryModel>, String>((ref, productId) {
  final useBackend = dotenv.env['USE_BACKEND'] == 'true';
  if (useBackend) return ref.watch(backendServiceProvider).getPriceHistory(productId);
  return ref.watch(firestoreServiceProvider).getPriceHistory(productId);
});

final selectedRangeProvider = Provider<String>((ref) => '7D');