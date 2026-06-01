import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedCategory = 0;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(trackedProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      extendBody: true,
      body: Stack(
        children: [
          // Animated particle + shapes background
          Positioned.fill(child: AnimatedBuilder(animation: _bgController, builder: (context, child) => CustomPaint(painter: _AnimatedBackgroundPainter(_bgController.value)))),
          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(trackedProductsProvider),
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
              displacement: 80,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _GlassTopBar(onAvatarTap: () => context.go('/profile'))),
                  SliverToBoxAdapter(child: _HeaderSection(controller: _searchController, onSearch: (v) => setState(() => _query = v), selectedCategory: _selectedCategory, onCategoryChanged: (i) => setState(() => _selectedCategory = i))),
                  SliverToBoxAdapter(child: const SizedBox(height: 12)),
                  SliverToBoxAdapter(child: _StatsSection()),
                  SliverToBoxAdapter(child: const SizedBox(height: 12)),
                  productsAsync.when(
                    data: (products) {
                      final filtered = products.where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase())).toList();
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        sliver: SliverList.separated(
                          itemBuilder: (context, index) => _GlassProductWrapper(child: ProductCard(product: filtered[index])),
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemCount: filtered.length,
                        ),
                      );
                    },
                    loading: () => SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: Colors.amber.shade400))),
                    error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error loading products', style: TextStyle(color: Colors.white)))),
                  ),
                ],
              ),
            ),
          ),
          // Bottom nav + FAB
          Positioned(left: 12, right: 12, bottom: 24, child: _BottomBar(onAdd: () => context.go('/add-product'))),
        ],
      ),
    );
  }
}

class _GlassTopBar extends StatelessWidget {
  const _GlassTopBar({required this.onAvatarTap});

  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFFFFD97A), Color(0xFFFF7A18)]),
                    boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.22), blurRadius: 18, spreadRadius: 2)],
                  ),
                  child: InkWell(
                    onTap: onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: const CircleAvatar(backgroundColor: Colors.transparent, child: Icon(Icons.person, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _GradientWelcome()),
                Stack(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                    Positioned(right: 8, top: 8, child: _NotificationBadge(count: 3)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        const SizedBox(height: 2),
        GradientText(text: 'Welcome back, Alex', gradient: const LinearGradient(colors: [Color(0xFFFFD97A), Color(0xFFFF7A18)]), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText({required this.text, required this.gradient, this.style});

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: (style ?? const TextStyle()).copyWith(color: Colors.white)),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 8)]),
      child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.controller, required this.onSearch, required this.selectedCategory, required this.onCategoryChanged, super.key});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final int selectedCategory;
  final ValueChanged<int> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          NeonSearchBar(controller: controller, onChanged: onSearch),
          const SizedBox(height: 12),
          // Category chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final selected = index == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index], style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.black : Colors.white70)),
                    selected: selected,
                    onSelected: (_) => onCategoryChanged(index),
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.white.withValues(alpha: 0.04),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const _categories = ['All', 'Electronics', 'Home', 'Fashion', 'Groceries', 'Beauty'];

class NeonSearchBar extends StatelessWidget {
  const NeonSearchBar({required this.controller, required this.onChanged, super.key});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search products', hintStyle: TextStyle(color: Colors.white54)),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(onPressed: () => controller.clear(), icon: const Icon(Icons.close, color: Colors.white70))
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Portfolio value', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(' 12,482', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                  ]),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('24h change', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.trending_up, color: Colors.greenAccent.shade400),
                      const SizedBox(width: 6),
                      Text('+3.8%', style: TextStyle(color: Colors.greenAccent.shade400, fontWeight: FontWeight.w900)),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassProductWrapper extends StatelessWidget {
  const _GlassProductWrapper({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 10))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(18)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.home, color: Colors.white)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.bar_chart, color: Colors.white70)),
                  GestureDetector(onTap: onAdd, child: _AddButton()),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.white70)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.white70)),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD97A), Color(0xFFFF7A18)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.32), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: const Icon(Icons.add, color: Colors.black, size: 28),
    );
  }
}

class _AnimatedBackgroundPainter extends CustomPainter {
  _AnimatedBackgroundPainter(this.progress);
  final double progress;
  final Random _rnd = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(size.width, size.height), [const Color(0xFF05050A), const Color(0xFF0A0A0F)]);
    canvas.drawRect(Offset.zero & size, bg);

    // floating shapes
    for (int i = 0; i < 6; i++) {
      final t = (progress + i / 6) % 1.0;
      final x = size.width * (i / 6) + sin((t + i) * 2 * pi) * 24;
      final y = size.height * (0.12 + (i % 3) * 0.08) + cos((t + i) * 2 * pi) * 18;
      final rect = Rect.fromCenter(center: Offset(x, y), width: 90 + i * 6, height: 60 + i * 4);
      final r = RRect.fromRectAndRadius(rect, Radius.circular(20 + i.toDouble()));
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.02 + (i % 2 == 0 ? 0.04 : 0.01));
      canvas.drawRRect(r, paint);
    }

    // glowing particles (increased count for denser effect)
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (int i = 0; i < 80; i++) {
      final px = (_rnd.nextDouble() * size.width + progress * 40 * (i % 7)) % size.width;
      final py = (_rnd.nextDouble() * size.height + progress * 30 * (i % 5)) % size.height;
      canvas.drawCircle(Offset(px, py), 0.8 + (_rnd.nextDouble() * 2.2), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedBackgroundPainter oldDelegate) => oldDelegate.progress != progress;
}
