import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../core/widgets/fancy_background.dart';
import '../../../services/analytics_service.dart';
import '../../../models/price_history_model.dart';
import '../providers/product_provider.dart';
import '../widgets/set_alert_bottom_sheet.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProvider(productId));
    final analytics = AnalyticsService();

    return FancyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Product Details')),
        body: historyAsync.when(
          data: (history) {
            final currentPrice = history.isNotEmpty ? history.first.price : 0.0;
            final lowestPrice = analytics.getLowestPrice(history);
            final highestPrice = analytics.getHighestPrice(history);
            final averagePrice = analytics.getAveragePrice(history);
            final recommendation = analytics.getRecommendation(currentPrice, averagePrice);

            return LayoutBuilder(
              builder: (context, constraints) {
                final wideLayout = constraints.maxWidth >= 720;
                final stats = [
                  _StatCard(label: 'Current', value: formatPrice(currentPrice)),
                  _StatCard(label: 'Min', value: formatPrice(lowestPrice)),
                  _StatCard(label: 'Max', value: formatPrice(highestPrice)),
                  _StatCard(label: 'Avg', value: formatPrice(averagePrice)),
                ];

                final recommendationColor = switch (recommendation) {
                  'BUY_NOW' => const Color(0xFF1B8A5A),
                  'GOOD_DEAL' => const Color(0xFF4CAF50),
                  'FAIR' => const Color(0xFF607D8B),
                  _ => const Color(0xFFD1495B),
                };

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(wideLayout ? 28 : 16, 8, wideLayout ? 28 : 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: LinearGradient(
                                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product #$productId', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
                                const SizedBox(height: 8),
                                Text(
                                  'Price history at a glance',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _RecommendationBadge(label: recommendation, color: recommendationColor),
                                    _ActionChip(
                                      icon: Icons.open_in_new_rounded,
                                      label: 'View on Daraz',
                                      onTap: () async {
                                        final uri = Uri.parse('https://www.daraz.com.np');
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (wideLayout)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _SectionCard(
                                    title: 'Price trend',
                                    child: SizedBox(height: 340, child: _PriceChart(history: history)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      _SectionCard(
                                        title: 'Key stats',
                                        child: GridView.count(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.35,
                                          children: stats,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _SectionCard(
                                        title: 'Actions',
                                        child: Column(
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) => SetAlertBottomSheet(
                                                  productId: productId,
                                                  currentPrice: currentPrice,
                                                  lowestPrice: lowestPrice,
                                                ),
                                              ),
                                              icon: const Icon(Icons.notifications_active_outlined),
                                              label: const Text('Set Price Alert'),
                                            ),
                                            const SizedBox(height: 10),
                                            FilledButton.tonalIcon(
                                              onPressed: () {},
                                              icon: const Icon(Icons.bookmark_add_outlined),
                                              label: const Text('Stop Tracking'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _SectionCard(
                              title: 'Price trend',
                              child: SizedBox(height: 280, child: _PriceChart(history: history)),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Key stats',
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.15,
                                children: stats,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Actions',
                              child: Column(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => SetAlertBottomSheet(
                                        productId: productId,
                                        currentPrice: currentPrice,
                                        lowestPrice: lowestPrice,
                                      ),
                                    ),
                                    icon: const Icon(Icons.notifications_active_outlined),
                                    label: const Text('Set Price Alert'),
                                  ),
                                  const SizedBox(height: 10),
                                  FilledButton.tonalIcon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.bookmark_add_outlined),
                                    label: const Text('Stop Tracking'),
                                  ),
                                ],
                              ),
                            ),
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
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _RecommendationBadge extends StatelessWidget {
  const _RecommendationBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
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

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}