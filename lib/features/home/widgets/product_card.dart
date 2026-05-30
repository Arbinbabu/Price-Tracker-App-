import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final hasDropped = product.lastScraped != null && product.currentPrice <= product.lowestPrice;
    final trendIcon = hasDropped ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final trendColor = hasDropped ? const Color(0xFF1B8A5A) : const Color(0xFFD1495B);

    return InkWell(
      onTap: () => context.go('/product/${product.productId}'),
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.white, trendColor.withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 92,
                      height: 92,
                      color: Colors.black12,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 92,
                      height: 92,
                      color: Colors.black12,
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              product.platform.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatPrice(product.currentPrice),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(trendIcon, size: 18, color: trendColor),
                          const SizedBox(width: 6),
                          Text(
                            hasDropped ? 'Price down from recent peak' : 'Trending upward',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
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
      ),
    );
  }
}