import 'dart:math';

import 'package:price_tracker_app/models/price_history_model.dart';

enum Recommendation { buyNow, goodDeal, fair, wait }

class AnalyticsService {
  static double getLowestPrice(List<PriceHistoryModel> history) =>
      history.isEmpty ? 0 : history.map((e) => e.price).reduce(min);

  static double getHighestPrice(List<PriceHistoryModel> history) =>
      history.isEmpty ? 0 : history.map((e) => e.price).reduce(max);

  static double getAveragePrice(List<PriceHistoryModel> history, {int days = 30}) {
    if (history.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = history.where((e) => e.timestamp.isAfter(cutoff)).toList();
    final source = filtered.isEmpty ? history : filtered;
    return source.map((e) => e.price).reduce((a, b) => a + b) / source.length;
  }

  static double getTrendSlope(List<PriceHistoryModel> history, {int points = 14}) {
    if (history.length < 2) return 0;
    final data = history.length > points ? history.sublist(history.length - points) : history;
    final n = data.length;
    final xMean = (n - 1) / 2;
    final yMean = data.map((e) => e.price).reduce((a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;
    for (var i = 0; i < n; i++) {
      final x = i - xMean;
      final y = data[i].price - yMean;
      numerator += x * y;
      denominator += x * x;
    }
    return denominator == 0 ? 0 : numerator / denominator;
  }

  static Recommendation getRecommendation(double currentPrice, double avg30d) {
    if (avg30d <= 0) return Recommendation.fair;
    final dealScore = (avg30d - currentPrice) / avg30d * 100;
    if (dealScore >= 15) return Recommendation.buyNow;
    if (dealScore >= 5) return Recommendation.goodDeal;
    if (dealScore >= -5) return Recommendation.fair;
    return Recommendation.wait;
  }
}
