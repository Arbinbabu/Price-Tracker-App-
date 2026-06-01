import 'package:flutter/material.dart';

class PriceBadge extends StatelessWidget {
  const PriceBadge({super.key, required this.percentChange});

  final double percentChange;

  @override
  Widget build(BuildContext context) {
    final isDrop = percentChange <= 0;
    final color = isDrop ? const Color(0xFF06D6A0) : const Color(0xFFEF233C);
    final icon = isDrop ? Icons.south_rounded : Icons.north_rounded;
    final sign = percentChange == 0 ? '' : percentChange.isNegative ? '-' : '+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$sign${percentChange.abs().toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}