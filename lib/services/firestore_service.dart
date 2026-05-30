import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:price_tracker_app/models/price_history_model.dart';
import 'package:price_tracker_app/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ProductModel>> trackedProductsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db.collection('users').doc(uid).snapshots().asyncExpand((userDoc) {
      final ids = List<String>.from(userDoc.data()?['trackedProducts'] ?? const []);
      if (ids.isEmpty) return Stream.value(const <ProductModel>[]);
      return _db
          .collection('products')
          .where('productId', whereIn: ids.take(10).toList())
          .snapshots()
          .map((snap) => snap.docs.map((doc) => ProductModel.fromJson(doc.data())).toList());
    });
  }

  Stream<ProductModel?> productStream(String productId) {
    return _db.collection('products').doc(productId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ProductModel.fromJson(doc.data()!);
    });
  }

  Stream<List<PriceHistoryModel>> priceHistoryStream(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('priceHistory')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => PriceHistoryModel.fromJson(doc.data())).toList());
  }

  Future<void> upsertFcmToken(String uid, String token) {
    return _db.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> setAlert({required String userId, required String productId, required double targetPrice}) {
    return _db.collection('alerts').doc('${userId}_$productId').set({
      'userId': userId,
      'productId': productId,
      'targetPrice': targetPrice,
      'isActive': true,
      'createdAt': DateTime.now(),
      'lastNotified': null,
    }, SetOptions(merge: true));
  }

  Future<void> stopTracking({required String userId, required String productId}) async {
    await _db.collection('users').doc(userId).update({
      'trackedProducts': FieldValue.arrayRemove([productId]),
    });
  }
}
