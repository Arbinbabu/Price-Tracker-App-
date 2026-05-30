class AlertModel {
  AlertModel({
    required this.userId,
    required this.productId,
    required this.targetPrice,
    required this.isActive,
    required this.createdAt,
    this.lastNotified,
  });

  final String userId;
  final String productId;
  final double targetPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastNotified;

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        userId: json['userId'] as String,
        productId: json['productId'] as String,
        targetPrice: (json['targetPrice'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? true,
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        lastNotified: _parseDate(json['lastNotified']),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'productId': productId,
        'targetPrice': targetPrice,
        'isActive': isActive,
        'createdAt': createdAt,
        'lastNotified': lastNotified,
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
