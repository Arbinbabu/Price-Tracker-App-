import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:price_tracker_app/core/utils/price_formatter.dart';
import 'package:price_tracker_app/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final diff = product.currentPrice - product.lowestPrice;
    final pct = product.lowestPrice == 0 ? 0 : (diff / product.lowestPrice) * 100;
    final isUp = pct > 0;

    return Card(
      child: ListTile(
        onTap: () => context.push('/product/${product.productId}'),
        leading: Hero(
          tag: 'product-image-${product.productId}',
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
          ),
        ),
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(formatNpr(product.currentPrice)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: isUp ? Colors.red : Colors.green),
            Text('${pct.abs().toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
