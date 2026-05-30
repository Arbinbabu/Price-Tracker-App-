import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:price_tracker_app/core/utils/price_formatter.dart';
import 'package:price_tracker_app/features/home/providers/products_provider.dart';
import 'package:price_tracker_app/features/product/providers/product_provider.dart';
import 'package:price_tracker_app/features/product/widgets/price_chart.dart';
import 'package:price_tracker_app/features/product/widgets/recommendation_badge.dart';
import 'package:price_tracker_app/models/price_history_model.dart';
import 'package:price_tracker_app/services/analytics_service.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _range = '1M';

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(selectedProductProvider(widget.productId));
    final historyAsync = ref.watch(productHistoryProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (product) {
          if (product == null) return const Center(child: Text('Product not found'));

          return historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (history) {
              final filtered = _filterHistory(history, _range);
              final avg30d = AnalyticsService.getAveragePrice(history);
              final recommendation = AnalyticsService.getRecommendation(product.currentPrice, avg30d);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product-image-${product.productId}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(imageUrl: product.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip(label: 'Current', value: formatNpr(product.currentPrice)),
                        _StatChip(label: 'Lowest Ever', value: formatNpr(AnalyticsService.getLowestPrice(history))),
                        _StatChip(label: 'Highest Ever', value: formatNpr(AnalyticsService.getHighestPrice(history))),
                        _StatChip(label: '30D Avg', value: formatNpr(avg30d)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RecommendationBadge(recommendation: recommendation),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '7D', label: Text('7D')),
                        ButtonSegment(value: '1M', label: Text('1M')),
                        ButtonSegment(value: '3M', label: Text('3M')),
                        ButtonSegment(value: 'ALL', label: Text('ALL')),
                      ],
                      selected: {_range},
                      onSelectionChanged: (v) => setState(() => _range = v.first),
                    ),
                    const SizedBox(height: 12),
                    PriceChart(history: filtered, avgLine: avg30d),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showAlertBottomSheet(context, product.currentPrice),
                      child: const Text('Set Price Alert'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => launchUrl(Uri.parse(product.url), mode: LaunchMode.externalApplication),
                      child: const Text('View on Daraz'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _confirmStopTracking(context),
                      child: const Text('Stop Tracking'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<PriceHistoryModel> _filterHistory(List<PriceHistoryModel> history, String range) {
    if (range == 'ALL') return history;
    final now = DateTime.now();
    final duration = switch (range) {
      '7D' => const Duration(days: 7),
      '1M' => const Duration(days: 30),
      '3M' => const Duration(days: 90),
      _ => const Duration(days: 30),
    };
    final cutoff = now.subtract(duration);
    return history.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  Future<void> _showAlertBottomSheet(BuildContext context, double currentPrice) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    double target = currentPrice;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Set target: ${formatNpr(target)}'),
                Slider(
                  min: currentPrice * 0.5,
                  max: currentPrice * 1.2,
                  value: target,
                  onChanged: (v) => setModalState(() => target = v),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(firestoreServiceProvider).setAlert(
                          userId: uid,
                          productId: widget.productId,
                          targetPrice: target,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Alert'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmStopTracking(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Stop Tracking?'),
            content: const Text('This product will be removed from your tracked list.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Stop')),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await ref.read(firestoreServiceProvider).stopTracking(userId: uid, productId: widget.productId);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
