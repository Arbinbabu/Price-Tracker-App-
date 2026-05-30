import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        child: ListTile(
          leading: Container(width: 56, height: 56, color: Colors.white),
          title: Container(height: 12, color: Colors.white),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(height: 12, width: 80, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
