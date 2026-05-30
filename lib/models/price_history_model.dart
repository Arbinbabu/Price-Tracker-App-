import 'package:cloud_firestore/cloud_firestore.dart';

class PriceHistoryModel {
  const PriceHistoryModel({
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

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      historyId: json['historyId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: json['source'] as String? ?? 'scraper',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'productId': productId,
      'price': price,
      'timestamp': Timestamp.fromDate(timestamp),
      'source': source,
    };
  }

  PriceHistoryModel copyWith({
    String? historyId,
    String? productId,
    double? price,
    DateTime? timestamp,
    String? source,
  }) {
    return PriceHistoryModel(
      historyId: historyId ?? this.historyId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }
}