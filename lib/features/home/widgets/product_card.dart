import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/price_badge.dart';
import '../../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final average = (product.lowestPrice + product.highestPrice) / 2;
    final trendIsDown = product.currentPrice <= average;
    final accentColor = trendIsDown ? const Color(0xFF06D6A0) : const Color(0xFFEF233C);
    final percentChange = average <= 0 ? 0.0 : ((product.currentPrice - average) / average) * 100;
    final lastUpdated = product.lastScraped == null ? 'Not updated yet' : _formatTimeAgo(product.lastScraped!);
    final sparkline = _buildSparkline(product);

    return Card(
      child: InkWell(
        onTap: () => context.go('/product/${product.productId}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
            gradient: LinearGradient(
              colors: [Colors.white, accentColor.withValues(alpha: 0.035)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'product-${product.productId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: const Color(0xFFE6EEF7),
                      highlightColor: const Color(0xFFF7FBFF),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFE6EEF7),
                      child: const Icon(Icons.image_outlined, color: Colors.black38),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PlatformChip(platform: product.platform),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(product.currentPrice),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        PriceBadge(percentChange: percentChange),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastUpdated,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 88,
                          height: 34,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: sparkline.length.toDouble() - 1,
                              minY: 0,
                              maxY: sparkline.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.05,
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineTouchData: const LineTouchData(enabled: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: sparkline,
                                  isCurved: true,
                                  color: accentColor,
                                  barWidth: 2.5,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [accentColor.withValues(alpha: 0.24), accentColor.withValues(alpha: 0.0)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildSparkline(ProductModel product) {
    final low = product.lowestPrice <= 0 ? product.currentPrice * 0.92 : product.lowestPrice;
    final high = product.highestPrice <= 0 ? product.currentPrice * 1.08 : product.highestPrice;
    final mid = (low + high) / 2;

    return [
      FlSpot(0, low),
      FlSpot(1, mid * 0.96),
      FlSpot(2, product.currentPrice),
      FlSpot(3, mid * 1.02),
      FlSpot(4, high),
    ];
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Updated just now';
    if (difference.inHours < 1) return 'Updated ${difference.inMinutes}m ago';
    if (difference.inDays < 1) return 'Updated ${difference.inHours}h ago';
    return 'Updated ${difference.inDays}d ago';
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        platform.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}