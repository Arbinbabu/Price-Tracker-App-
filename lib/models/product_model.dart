class ProductModel {
  ProductModel({
    required this.productId,
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.platform,
    required this.currentPrice,
    required this.highestPrice,
    required this.lowestPrice,
    this.lastScraped,
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

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        imageUrl: json['imageUrl'] as String? ?? '',
        platform: json['platform'] as String? ?? 'daraz',
        currentPrice: (json['currentPrice'] as num).toDouble(),
        highestPrice: (json['highestPrice'] as num).toDouble(),
        lowestPrice: (json['lowestPrice'] as num).toDouble(),
        lastScraped: _parseDate(json['lastScraped']),
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        trackedByCount: (json['trackedByCount'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'url': url,
        'imageUrl': imageUrl,
        'platform': platform,
        'currentPrice': currentPrice,
        'highestPrice': highestPrice,
        'lowestPrice': lowestPrice,
        'lastScraped': lastScraped,
        'createdAt': createdAt,
        'trackedByCount': trackedByCount,
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
