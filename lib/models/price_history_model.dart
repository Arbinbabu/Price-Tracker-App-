class PriceHistoryModel {
  PriceHistoryModel({
    required this.historyId,
    required this.productId,
    required this.price,
    required this.timestamp,
    required this.source,
  });

  final String historyId;
  final String productId;
  final double price;
  final DateTime timestamp;
  final String source;

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) => PriceHistoryModel(
        historyId: json['historyId'] as String,
        productId: json['productId'] as String,
        price: (json['price'] as num).toDouble(),
        timestamp: _parseDate(json['timestamp']) ?? DateTime.now(),
        source: json['source'] as String? ?? 'scraper',
      );

  Map<String, dynamic> toJson() => {
        'historyId': historyId,
        'productId': productId,
        'price': price,
        'timestamp': timestamp,
        'source': source,
      };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  final dynamic ts = value;
  try {
    return ts.toDate() as DateTime;
  } catch (_) {
    return null;
  }
}
