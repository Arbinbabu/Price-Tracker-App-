import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../models/price_history_model.dart';
import '../../../models/product_model.dart';
import '../../../services/analytics_service.dart';
import '../providers/product_provider.dart';
import '../widgets/set_alert_bottom_sheet.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String _selectedRange = '7D';

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final historyAsync = ref.watch(priceHistoryProvider(widget.productId));
    final analytics = AnalyticsService();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Product details'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final currentProduct = productAsync.value;
                    final history = historyAsync.value;
                    final currentPrice = history?.isNotEmpty == true
                      ? history!.first.price
                        : currentProduct?.currentPrice ?? 0;
                    final lowestPrice = history?.isNotEmpty == true
                      ? analytics.getLowestPrice(history!)
                        : currentProduct?.lowestPrice ?? 0;
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => SetAlertBottomSheet(
                        productId: widget.productId,
                        currentPrice: currentPrice,
                        lowestPrice: lowestPrice,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text('Set Alert'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  onPressed: () async {
                    final currentProduct = productAsync.value;
                    final url = currentProduct?.url.isNotEmpty == true ? currentProduct!.url : 'https://www.daraz.com.np';
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  child: const Text('View on Daraz'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: productAsync.when(
        data: (product) {
          return historyAsync.when(
            data: (history) {
              final sortedHistory = [...history]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
              final filteredHistory = _filterHistory(sortedHistory);
              final currentPrice = filteredHistory.isNotEmpty ? filteredHistory.last.price : product?.currentPrice ?? 0.0;
              final lowestPrice = analytics.getLowestPrice(filteredHistory.isNotEmpty ? filteredHistory : sortedHistory);
              final highestPrice = analytics.getHighestPrice(filteredHistory.isNotEmpty ? filteredHistory : sortedHistory);
              final averagePrice = analytics.getAveragePrice(filteredHistory.isNotEmpty ? filteredHistory : sortedHistory);
              final recommendation = analytics.getRecommendation(currentPrice, averagePrice);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final wideLayout = constraints.maxWidth >= 900;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeroHeader(product: product, currentPrice: currentPrice, recommendation: recommendation),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _RangePill(label: '7D', selected: _selectedRange == '7D', onTap: () => setState(() => _selectedRange = '7D')),
                                _RangePill(label: '1M', selected: _selectedRange == '1M', onTap: () => setState(() => _selectedRange = '1M')),
                                _RangePill(label: '3M', selected: _selectedRange == '3M', onTap: () => setState(() => _selectedRange = '3M')),
                                _RangePill(label: 'ALL', selected: _selectedRange == 'ALL', onTap: () => setState(() => _selectedRange = 'ALL')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (wideLayout)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 7, child: _ChartSection(history: filteredHistory.isEmpty ? sortedHistory : filteredHistory)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      children: [
                                        _StatsGrid(
                                          currentPrice: currentPrice,
                                          lowestPrice: lowestPrice,
                                          highestPrice: highestPrice,
                                          averagePrice: averagePrice,
                                        ),
                                        const SizedBox(height: 16),
                                        _RecommendationBanner(recommendation: recommendation, currentPrice: currentPrice, averagePrice: averagePrice),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _ChartSection(history: filteredHistory.isEmpty ? sortedHistory : filteredHistory),
                              const SizedBox(height: 16),
                              _StatsGrid(
                                currentPrice: currentPrice,
                                lowestPrice: lowestPrice,
                                highestPrice: highestPrice,
                                averagePrice: averagePrice,
                              ),
                              const SizedBox(height: 16),
                              _RecommendationBanner(recommendation: recommendation, currentPrice: currentPrice, averagePrice: averagePrice),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  List<PriceHistoryModel> _filterHistory(List<PriceHistoryModel> history) {
    if (_selectedRange == 'ALL') return history;
    final now = DateTime.now();
    final cutoff = switch (_selectedRange) {
      '7D' => now.subtract(const Duration(days: 7)),
      '1M' => now.subtract(const Duration(days: 30)),
      '3M' => now.subtract(const Duration(days: 90)),
      _ => now.subtract(const Duration(days: 7)),
    };
    return history.where((item) => item.timestamp.isAfter(cutoff)).toList();
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.product, required this.currentPrice, required this.recommendation});

  final ProductModel? product;
  final double currentPrice;
  final String recommendation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = product?.imageUrl ?? '';
    final heroTag = 'product-${product?.productId ?? 'placeholder'}';

    final recommendationStyle = _recommendationStyle(recommendation);

    return Container(
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 16))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Hero(
                tag: heroTag,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: const Color(0xFFE8EEF7),
                    highlightColor: Colors.white,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_outlined, size: 64),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF00B4D8)]),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.18), Colors.black.withValues(alpha: 0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Badge(text: product?.platform.toUpperCase() ?? 'DARAZ'),
                      _Badge(text: recommendationStyle.label),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product?.name ?? 'Product details',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(currentPrice),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Text(
                        recommendationStyle.subtitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
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
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.currentPrice, required this.lowestPrice, required this.highestPrice, required this.averagePrice});

  final double currentPrice;
  final double lowestPrice;
  final double highestPrice;
  final double averagePrice;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _GradientStatCard(label: 'Current', value: formatPrice(currentPrice), colors: const [Color(0xFF1F4E79), Color(0xFF00B4D8)]),
        _GradientStatCard(label: 'Lowest', value: formatPrice(lowestPrice), colors: const [Color(0xFF06D6A0), Color(0xFF3DDC97)]),
        _GradientStatCard(label: 'Highest', value: formatPrice(highestPrice), colors: const [Color(0xFFEF233C), Color(0xFFFF6B6B)]),
        _GradientStatCard(label: 'Average', value: formatPrice(averagePrice), colors: const [Color(0xFFFFB703), Color(0xFFFFC93C)]),
      ],
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({required this.label, required this.value, required this.colors});

  final String label;
  final String value;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [colors.first.withValues(alpha: 0.18), Colors.white]),
        border: Border.all(color: colors.first.withValues(alpha: 0.18)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _RecommendationBanner extends StatelessWidget {
  const _RecommendationBanner({required this.recommendation, required this.currentPrice, required this.averagePrice});

  final String recommendation;
  final double currentPrice;
  final double averagePrice;

  @override
  Widget build(BuildContext context) {
    final style = _recommendationStyle(recommendation);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: style.colors),
        boxShadow: [BoxShadow(color: style.colors.last.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(style.icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(style.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  style.description(currentPrice, averagePrice),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({required this.history});

  final List<PriceHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Price history', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('${history.length} points', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 320, child: _PriceChart(history: history)),
          ],
        ),
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({required this.history});

  final List<PriceHistoryModel> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('No chart data yet'));
    }

    final spots = history.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.price)).toList();
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.08;
    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.92;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFFE6EEF7), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.white,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final item = history[spot.x.toInt()];
                return LineTooltipItem(
                  '${formatPrice(item.price)}\n',
                  Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF1F4E79), fontWeight: FontWeight.w800) ??
                      const TextStyle(color: Color(0xFF1F4E79), fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(
                      text: _formatDate(item.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF00B4D8)]),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [const Color(0xFF1F4E79).withValues(alpha: 0.28), const Color(0xFF00B4D8).withValues(alpha: 0.02)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF1F4E79),
      labelStyle: TextStyle(color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}

_RecommendationStyle _recommendationStyle(String recommendation) {
  return switch (recommendation) {
    'BUY_NOW' => const _RecommendationStyle(
        label: 'BUY NOW',
        subtitle: 'Excellent discount',
        icon: Icons.shopping_cart_checkout_rounded,
        colors: [Color(0xFF06D6A0), Color(0xFF3DDC97)],
      ),
    'GOOD_DEAL' => const _RecommendationStyle(
        label: 'GOOD DEAL',
        subtitle: 'Worth considering',
        icon: Icons.thumb_up_alt_rounded,
        colors: [Color(0xFF00B4D8), Color(0xFF1F4E79)],
      ),
    'WAIT' => const _RecommendationStyle(
        label: 'WAIT',
        subtitle: 'Price may dip further',
        icon: Icons.schedule_rounded,
        colors: [Color(0xFFFFB703), Color(0xFFFF8F00)],
      ),
    _ => const _RecommendationStyle(
        label: 'FAIR PRICE',
        subtitle: 'Steady market value',
        icon: Icons.remove_circle_outline_rounded,
        colors: [Color(0xFF6C757D), Color(0xFFADB5BD)],
      ),
  };
}

class _RecommendationStyle {
  const _RecommendationStyle({required this.label, required this.subtitle, required this.icon, required this.colors});

  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  String description(double currentPrice, double averagePrice) {
    return switch (label) {
      'BUY NOW' => 'Current price is well below the recent average.',
      'GOOD DEAL' => 'The product is sitting in a healthy price band.',
      'WAIT' => 'The trend suggests waiting for a better drop.',
      _ => 'The price is close to the current market average.',
    };
  }
}