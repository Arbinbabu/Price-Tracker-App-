import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  const ProductModel({
    required this.productId,
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.platform,
    required this.currentPrice,
    required this.highestPrice,
    required this.lowestPrice,
    required this.lastScraped,
    required this.createdAt,
    required this.trackedByCount,
  });

  final String productId;
  final String name;
  final String url;
  final String imageUrl;
  final String platform;
  final double currentPrice;
  final double highestPrice;
  final double lowestPrice;
  final DateTime? lastScraped;
  final DateTime createdAt;
  final int trackedByCount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      platform: json['platform'] as String? ?? 'daraz',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      highestPrice: (json['highestPrice'] as num?)?.toDouble() ?? 0,
      lowestPrice: (json['lowestPrice'] as num?)?.toDouble() ?? 0,
      lastScraped: (json['lastScraped'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trackedByCount: (json['trackedByCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'url': url,
      'imageUrl': imageUrl,
      'platform': platform,
      'currentPrice': currentPrice,
      'highestPrice': highestPrice,
      'lowestPrice': lowestPrice,
      'lastScraped': lastScraped == null ? null : Timestamp.fromDate(lastScraped!),
      'createdAt': Timestamp.fromDate(createdAt),
      'trackedByCount': trackedByCount,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? name,
    String? url,
    String? imageUrl,
    String? platform,
    double? currentPrice,
    double? highestPrice,
    double? lowestPrice,
    DateTime? lastScraped,
    DateTime? createdAt,
    int? trackedByCount,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      platform: platform ?? this.platform,
      currentPrice: currentPrice ?? this.currentPrice,
      highestPrice: highestPrice ?? this.highestPrice,
      lowestPrice: lowestPrice ?? this.lowestPrice,
      lastScraped: lastScraped ?? this.lastScraped,
      createdAt: createdAt ?? this.createdAt,
      trackedByCount: trackedByCount ?? this.trackedByCount,
    );
  }
}