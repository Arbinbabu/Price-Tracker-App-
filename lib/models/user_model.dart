class UserModel {
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.trackedProducts,
    this.fcmToken,
  });

  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final List<String> trackedProducts;
  final String? fcmToken;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        trackedProducts: List<String>.from(json['trackedProducts'] ?? const []),
        fcmToken: json['fcmToken'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': createdAt,
        'trackedProducts': trackedProducts,
        'fcmToken': fcmToken,
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
