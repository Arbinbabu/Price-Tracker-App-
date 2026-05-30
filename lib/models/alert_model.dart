import 'package:cloud_firestore/cloud_firestore.dart';

class AlertModel {
  const AlertModel({
    required this.userId,
    required this.productId,
    required this.targetPrice,
    required this.isActive,
    required this.createdAt,
    required this.lastNotified,
  });

  final String userId;
  final String productId;
  final double targetPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastNotified;

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      targetPrice: (json['targetPrice'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastNotified: (json['lastNotified'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'targetPrice': targetPrice,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastNotified': lastNotified == null ? null : Timestamp.fromDate(lastNotified!),
    };
  }

  AlertModel copyWith({
    String? userId,
    String? productId,
    double? targetPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastNotified,
  }) {
    return AlertModel(
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      targetPrice: targetPrice ?? this.targetPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastNotified: lastNotified ?? this.lastNotified,
    );
  }
}