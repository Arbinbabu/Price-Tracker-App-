import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/price_history_model.dart';
import '../../home/providers/products_provider.dart';

final priceHistoryProvider = StreamProvider.family<List<PriceHistoryModel>, String>((ref, productId) {
  return ref.watch(firestoreServiceProvider).getPriceHistory(productId);
});

final selectedRangeProvider = Provider<String>((ref) => '7D');