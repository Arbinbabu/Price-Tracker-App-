import 'package:flutter/material.dart';
import 'package:price_tracker_app/services/analytics_service.dart';

class RecommendationBadge extends StatelessWidget {
  const RecommendationBadge({super.key, required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final (bg, label) = switch (recommendation) {
      Recommendation.buyNow => (Colors.green, 'BUY NOW'),
      Recommendation.goodDeal => (Colors.lightGreen, 'GOOD DEAL'),
      Recommendation.fair => (Colors.grey, 'FAIR'),
      Recommendation.wait => (Colors.deepOrange, 'WAIT'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
