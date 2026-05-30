import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:price_tracker_app/features/home/providers/products_provider.dart';
import 'package:price_tracker_app/features/home/widgets/product_card.dart';
import 'package:price_tracker_app/features/home/widgets/shimmer_product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(trackedProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracked Products'),
        actions: [
          IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_outlined)),
          IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trackedProductsProvider);
        },
        child: products.when(
          loading: () => ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => const ShimmerProductCard(),
          ),
          error: (err, _) => ListView(children: [Center(child: Text('Error: $err'))]),
          data: (items) {
            if (items.isEmpty) {
              return const ListView(
                children: [
                  SizedBox(height: 120),
                  Center(child: Text('No products tracked yet. Add your first Daraz product!')),
                ],
              );
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) => ProductCard(product: items[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
