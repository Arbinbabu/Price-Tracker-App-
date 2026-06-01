import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/widgets/gradient_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _urlController = TextEditingController();
  bool _loading = false;

  final List<String> _recentSearches = const [
    'https://www.daraz.com.np/products/abc',
    'Smartwatch Nepal',
    'Wireless headphones',
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() {
      _urlController.text = text;
      _urlController.selection = TextSelection.collapsed(offset: text.length);
    });
  }

  Future<void> _search() async {
    if (_urlController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product search UI ready. Hook this to your scraper flow.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add product'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF00B4D8)]),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 14))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.link_rounded, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Track a new product',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Paste a Daraz link and let Price Tracker follow every price change.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _urlController,
                            minLines: 2,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Paste product URL',
                              hintText: 'https://www.daraz.com.np/products/...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: IconButton(
                                onPressed: _pasteFromClipboard,
                                icon: const Icon(Icons.content_paste_rounded),
                                tooltip: 'Paste from clipboard',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            onPressed: _loading ? null : _search,
                            isLoading: _loading,
                            loadingLabel: 'Searching',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_loading)
                                  CircularPercentIndicator(
                                    radius: 10,
                                    lineWidth: 2.5,
                                    percent: 1,
                                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                                    progressColor: Colors.white,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    animation: true,
                                  )
                                else
                                  const Icon(Icons.travel_explore_rounded, size: 18, color: Colors.white),
                                const SizedBox(width: 10),
                                const Text('Search product'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Recent searches',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _recentSearches
                                .map(
                                  (value) => ActionChip(
                                    label: Text(value),
                                    onPressed: () => setState(() => _urlController.text = value),
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                                    side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.15)),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'How it works',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 14),
                          _StepCard(
                            number: '1',
                            icon: Icons.link_rounded,
                            title: 'Paste the link',
                            description: 'Add a Daraz product URL or search phrase.',
                          ),
                          const SizedBox(height: 12),
                          _StepCard(
                            number: '2',
                            icon: Icons.auto_graph_rounded,
                            title: 'Review product data',
                            description: 'See title, image, and current pricing before tracking.',
                          ),
                          const SizedBox(height: 12),
                          _StepCard(
                            number: '3',
                            icon: Icons.notifications_active_rounded,
                            title: 'Set price alerts',
                            description: 'Create alerts and get notified on important drops.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.icon, required this.title, required this.description});

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF00B4D8)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}