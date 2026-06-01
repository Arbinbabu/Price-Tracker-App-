import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../../../models/product_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selectedCategory = 0;
  int _navIndex = 0;
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
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080818),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBuilder(animation: _bgController, builder: (_, __) => CustomPaint(painter: _AuroraPainter(_bgController.value)))),
          Positioned.fill(child: CustomPaint(painter: _ParticlePainter())),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: _GlassTopBar(userStream: authState, onAvatarTap: () {})),
                SliverToBoxAdapter(child: _HeaderSection(controller: _searchController, onSearch: (v) => setState(() => _query = v), selectedCategory: _selectedCategory, onCategoryChanged: (i) => setState(() => _selectedCategory = i))),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(child: _StatsRow()),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const SliverToBoxAdapter(child: _AlertsRow()),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                productsAsync.when(
                  data: (products) {
                    final filtered = products.where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase())).toList();
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) => _ProductCard3D(product: filtered[index]), childCount: filtered.length),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.86),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                  error: (e, s) => const SliverToBoxAdapter(child: Center(child: Text('Error loading products', style: TextStyle(color: Colors.white)))),
                ),
              ],
            ),
          ),

          Positioned(left: 12, right: 12, bottom: 24, child: _BottomBar(selectedIndex: _navIndex, onSelect: (i) => setState(() => _navIndex = i), onAdd: () {})),

          if (_navIndex == 1) Positioned.fill(child: AnalyticsScreen(onClose: () => setState(() => _navIndex = 0))),
        ],
      ),
    );
  }
}

// --- UI components ---
class _GlassTopBar extends StatelessWidget {
  const _GlassTopBar({required this.userStream, required this.onAvatarTap});
  final AsyncValue userStream;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.06))),
            child: Row(children: [
              _AvatarWithRing(onTap: onAvatarTap),
              const SizedBox(width: 12),
              Expanded(child: _WelcomeColumn(userStream: userStream)),
              Stack(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)), const Positioned(right: 8, top: 8, child: _NotificationPulse())])
            ]),
          ),
        ),
      ),
    );
  }
}

class _WelcomeColumn extends StatelessWidget {
  const _WelcomeColumn({required this.userStream});
  final AsyncValue userStream;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(greeting + ',', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
      const SizedBox(height: 4),
      userStream.when(
        data: (user) => Text('Welcome back, ${user?.displayName ?? 'Friend'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        loading: () => const Text('Welcome back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        error: (_, __) => const Text('Welcome back', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 6),
      Text('${now.weekday} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
    ]);
  }
}

class _AvatarWithRing extends StatefulWidget {
  const _AvatarWithRing({required this.onTap});
  final VoidCallback onTap;
  @override
  State<_AvatarWithRing> createState() => _AvatarWithRingState();
}

class _AvatarWithRingState extends State<_AvatarWithRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(width: 54, height: 54, child: AnimatedBuilder(animation: _ringController, builder: (c, _) => CustomPaint(painter: _RainbowRingPainter(_ringController.value)))),
        Container(width: 46, height: 46, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)), child: const Center(child: Icon(Icons.person, color: Colors.white70))),
      ]),
    );
  }
}

class _RainbowRingPainter extends CustomPainter {
  _RainbowRingPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3;
    final gradient = SweepGradient(colors: [Colors.purple, Colors.blue, Colors.cyan, Colors.pink, Colors.purple], transform: GradientRotation(progress * 2 * pi));
    paint.shader = gradient.createShader(rect);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _NotificationPulse extends StatefulWidget {
  const _NotificationPulse();
  @override
  State<_NotificationPulse> createState() => _NotificationPulseState();
}

class _NotificationPulseState extends State<_NotificationPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.36), blurRadius: 10)]), child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10))),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(child: _StatsCard(title: 'Portfolio Value', value: 12482, icon: Icons.pie_chart, gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)]))),
        const SizedBox(width: 12),
        Expanded(child: _StatsCard(title: 'Products', value: 42, icon: Icons.shopping_bag, gradient: const LinearGradient(colors: [Color(0xFFFF7A18), Color(0xFFFFD700)]))),
        const SizedBox(width: 12),
        Expanded(child: _StatsCard(title: 'Price Drops', value: 7, icon: Icons.trending_down, gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]), highlight: true)),
      ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.value, required this.icon, required this.gradient, this.highlight = false});
  final String title;
  final num value;
  final IconData icon;
  final Gradient gradient;
  final bool highlight;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.03))),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12)]), child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.white70)), const SizedBox(height: 6), AnimatedCounter(value: value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900))])),
            if (highlight) const SizedBox(width: 6)
          ]),
        ),
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({required this.value, this.duration = const Duration(milliseconds: 900), this.style, super.key});
  final num value;
  final Duration duration;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(tween: Tween(begin: 0, end: value), duration: duration, builder: (context, val, child) => Text(val is double ? val.toStringAsFixed(0) : val.toString(), style: style));
  }
}

class _HeaderSection extends StatefulWidget {
  const _HeaderSection({required this.controller, required this.onSearch, required this.selectedCategory, required this.onCategoryChanged, super.key});
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final int selectedCategory;
  final ValueChanged<int> onCategoryChanged;
  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NeonSearchBar(controller: widget.controller, onChanged: widget.onSearch),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final selected = index == widget.selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onCategoryChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: selected ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFFF6BCE)]) : null,
                      color: selected ? null : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: selected ? [BoxShadow(color: Colors.purple.withOpacity(0.12), blurRadius: 18, spreadRadius: 2)] : null,
                    ),
                    child: Center(child: Text(_categories[index], style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : Colors.white70))),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

const _categories = ['All', 'Electronics', 'Fashion', 'Food', 'Travel', 'Gaming', 'Sports'];

class NeonSearchBar extends StatefulWidget {
  const NeonSearchBar({required this.controller, required this.onChanged, super.key});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  State<NeonSearchBar> createState() => _NeonSearchBarState();
}

class _NeonSearchBarState extends State<NeonSearchBar> {
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: _focus ? Colors.cyan.withOpacity(0.9) : Colors.white.withOpacity(0.04), width: _focus ? 2 : 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Row(children: [
        Icon(Icons.search, color: Colors.cyan.shade200),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: widget.controller, onChanged: widget.onChanged, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search products', hintStyle: TextStyle(color: Colors.white54)), onTap: () => setState(() => _focus = true), onEditingComplete: () => setState(() => _focus = false))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.mic, color: Colors.white70))
      ]),
    );
  }
}

class _AlertsRow extends StatelessWidget {
  const _AlertsRow({super.key});
  @override
  Widget build(BuildContext context) {
    final sample = List.generate(6, (i) => {'title': 'Price drop', 'price': (20 - i).toString()});
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (c, i) => _AlertCard(title: sample[i]['title']!, price: sample[i]['price']!),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: sample.length,
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.title, required this.price, super.key});
  final String title;
  final String price;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.04))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: Colors.white70)), const Spacer(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\u007f $price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_alert), label: const Text('Set'), style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan))])]),
        ),
      ),
    );
  }
}

class _ProductCard3D extends StatelessWidget {
  const _ProductCard3D({required this.product, super.key});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => _ProductDetailSheet(product: product)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.04))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black.withOpacity(0.12)), child: product.imageUrl.isNotEmpty ? Image.network(product.imageUrl, fit: BoxFit.cover) : const Icon(Icons.image, color: Colors.white54))),
              const SizedBox(height: 8),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(children: [Text('\u007f ${product.currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), const Spacer(), const _PriceChangeBadge(change: -12.4)]),
              const SizedBox(height: 6),
              Row(children: [IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: Colors.white70)), Text(product.lastScraped != null ? 'Updated ${product.lastScraped!.hour}:${product.lastScraped!.minute.toString().padLeft(2, '0')}' : 'Updated: -', style: const TextStyle(color: Colors.white54))])
            ]),
          ),
        ),
      ),
    );
  }
}

class _PriceChangeBadge extends StatelessWidget {
  const _PriceChangeBadge({required this.change, super.key});
  final double change;
  @override
  Widget build(BuildContext context) {
    final up = change > 0;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: up ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: up ? Colors.red.withOpacity(0.28) : Colors.green.withOpacity(0.28))), child: Text('${up ? '+' : ''}${change.toStringAsFixed(1)}%', style: TextStyle(color: up ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.w800)));
  }
}

class _ProductDetailSheet extends StatelessWidget {
  const _ProductDetailSheet({required this.product, super.key});
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.85)]), borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 12), const Text('Full price history and sparkline would appear here', style: TextStyle(color: Colors.white70)), const SizedBox(height: 12), ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add_alert), label: const Text('Set price alert'))]));
  }
}

class _BottomBar extends StatefulWidget {
  const _BottomBar({required this.selectedIndex, required this.onSelect, required this.onAdd, super.key});
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(18)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _NavIcon(icon: Icons.home, index: 0, selected: widget.selectedIndex == 0, onTap: () => widget.onSelect(0)),
                _NavIcon(icon: Icons.bar_chart, index: 1, selected: widget.selectedIndex == 1, onTap: () => widget.onSelect(1)),
                GestureDetector(
                  onTap: widget.onAdd,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: AnimatedBuilder(
                      animation: _fabController,
                      builder: (c, _) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.withOpacity(0.9), Colors.cyan.withOpacity(0.9)],
                            transform: GradientRotation(_fabController.value * 2 * pi),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.32), blurRadius: 24, offset: const Offset(0, 12))
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
                _NavIcon(icon: Icons.bookmark_border, index: 3, selected: widget.selectedIndex == 3, onTap: () => widget.onSelect(3)),
                _NavIcon(icon: Icons.settings_outlined, index: 4, selected: widget.selectedIndex == 4, onTap: () => widget.onSelect(4)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.index, required this.selected, required this.onTap, super.key});
  final IconData icon;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onTap, icon: Icon(icon, color: selected ? Colors.cyanAccent : Colors.white70));
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({required this.onClose, super.key});
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white))],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.04),
                        child: const Center(child: Text('Line chart placeholder', style: TextStyle(color: Colors.white70))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 140,
                              color: Colors.white.withOpacity(0.04),
                              child: const Center(child: Text('Bar chart placeholder', style: TextStyle(color: Colors.white70))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 140,
                              color: Colors.white.withOpacity(0.04),
                              child: const Center(child: Text('Prediction', style: TextStyle(color: Colors.white70))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.progress);
  final double progress;
  final Random _rnd = Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF080818);
    canvas.drawRect(Offset.zero & size, bg);

    final colors = [const Color(0xFF7C3AED), const Color(0xFF2563EB), const Color(0xFF06B6D4)];
    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.18) % 1.0;
      final x = size.width * (0.2 + i * 0.25) + sin(t * 2 * pi) * 40;
      final y = size.height * (0.35 + i * 0.12) + cos(t * 2 * pi) * 60;
      final radius = size.width * 0.5 * (0.2 + i * 0.08);
      final rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
      final gradient = RadialGradient(colors: [colors[i].withOpacity(0.14), colors[i].withOpacity(0.0)]);
      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) => old.progress != progress;
}

class _ParticlePainter extends CustomPainter {
  final Random _rnd = Random(123);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 120; i++) {
      final x = _rnd.nextDouble() * size.width;
      final y = _rnd.nextDouble() * size.height;
      final r = 0.6 + _rnd.nextDouble() * 1.6;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
