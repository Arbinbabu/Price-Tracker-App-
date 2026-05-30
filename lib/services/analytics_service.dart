import '../models/price_history_model.dart';

class AnalyticsService {
  double getLowestPrice(List<PriceHistoryModel> history) {
    if (history.isEmpty) return 0;
    return history.map((item) => item.price).reduce((a, b) => a < b ? a : b);
  }

  double getHighestPrice(List<PriceHistoryModel> history) {
    if (history.isEmpty) return 0;
    return history.map((item) => item.price).reduce((a, b) => a > b ? a : b);
  }

  double getAveragePrice(List<PriceHistoryModel> history, {int days = 30}) {
    if (history.isEmpty) return 0;
    final threshold = DateTime.now().subtract(Duration(days: days));
    final filtered = history.where((item) => item.timestamp.isAfter(threshold)).toList();
    final values = filtered.isEmpty ? history : filtered;
    final total = values.fold<double>(0, (sum, item) => sum + item.price);
    return total / values.length;
  }

  double getTrendSlope(List<PriceHistoryModel> history, {int points = 14}) {
    if (history.length < 2) return 0;
    final data = history.take(points).toList().reversed.toList();
    final n = data.length.toDouble();
    final sumX = data.asMap().keys.fold<double>(0, (sum, value) => sum + value);
    final sumY = data.fold<double>(0, (sum, item) => sum + item.price);
    final sumXY = data.asMap().entries.fold<double>(0, (sum, entry) => sum + (entry.key * entry.value.price));
    final sumXX = data.asMap().keys.fold<double>(0, (sum, value) => sum + value * value);
    final denominator = (n * sumXX) - (sumX * sumX);
    if (denominator == 0) return 0;
    return ((n * sumXY) - (sumX * sumY)) / denominator;
  }

  String getRecommendation(double currentPrice, double avg30d) {
    if (avg30d <= 0) return 'FAIR';
    final dealScore = ((avg30d - currentPrice) / avg30d) * 100;

    if (dealScore >= 15) return 'BUY_NOW';
    if (dealScore >= 5) return 'GOOD_DEAL';
    if (dealScore >= -5) return 'FAIR';
    return 'WAIT';
  }
}