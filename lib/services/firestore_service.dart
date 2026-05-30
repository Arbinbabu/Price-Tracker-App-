import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_model.dart';
import '../models/price_history_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ProductModel>> getUserTrackedProducts(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().asyncMap((userDoc) async {
      final trackedIds = List<String>.from(userDoc.data()?['trackedProducts'] as List? ?? const []);
      if (trackedIds.isEmpty) {
        return <ProductModel>[];
      }

      final snapshots = await Future.wait(
        trackedIds.map((productId) => _firestore.collection('products').doc(productId).get()),
      );

      return snapshots
          .where((snapshot) => snapshot.exists && snapshot.data() != null)
          .map((snapshot) {
        final data = Map<String, dynamic>.from(snapshot.data()!);
        data['productId'] ??= snapshot.id;
        return ProductModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> addProductToUserList(String uid, String productId) async {
    await _firestore.collection('users').doc(uid).set(
      {'trackedProducts': FieldValue.arrayUnion([productId])},
      SetOptions(merge: true),
    );
  }

  Future<void> removeProductFromUserList(String uid, String productId) async {
    await _firestore.collection('users').doc(uid).set(
      {'trackedProducts': FieldValue.arrayRemove([productId])},
      SetOptions(merge: true),
    );
  }

  Stream<List<PriceHistoryModel>> getPriceHistory(String productId, {int limit = 30}) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('priceHistory')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PriceHistoryModel.fromJson(doc.data())).toList());
  }

  Future<void> setAlert(AlertModel alert) async {
    final id = '${alert.userId}_${alert.productId}';
    await _firestore.collection('alerts').doc(id).set(alert.toJson());
  }

  Future<AlertModel?> getUserAlert(String uid, String productId) async {
    final doc = await _firestore.collection('alerts').doc('${uid}_$productId').get();
    final data = doc.data();
    return data == null ? null : AlertModel.fromJson(data);
  }
}