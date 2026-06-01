import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/price_history_model.dart';

class BackendService {
  BackendService({String? baseUrl}) : _baseUrl = baseUrl ?? dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  final String _baseUrl;

  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'content-type': 'application/json'};
    final token = await user.getIdToken();
    return {
      'content-type': 'application/json',
      'authorization': 'Bearer $token',
    };
  }

  Stream<List<ProductModel>> getUserTrackedProducts(String uid) async* {
    final url = Uri.parse('$_baseUrl/users/$uid/products');
    try {
      final headers = await _authHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        yield data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        yield <ProductModel>[];
      }
    } catch (_) {
      yield <ProductModel>[];
    }
  }

  Stream<ProductModel?> watchProduct(String productId) async* {
    final url = Uri.parse('$_baseUrl/products/$productId');
    try {
      final headers = await _authHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        yield ProductModel.fromJson(data);
      } else {
        yield null;
      }
    } catch (_) {
      yield null;
    }
  }

  Stream<List<PriceHistoryModel>> getPriceHistory(String productId, {int limit = 30}) async* {
    final url = Uri.parse('$_baseUrl/products/$productId/priceHistory?limit=$limit');
    try {
      final headers = await _authHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        yield data.map((e) => PriceHistoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        yield <PriceHistoryModel>[];
      }
    } catch (_) {
      yield <PriceHistoryModel>[];
    }
  }

  Future<void> addProductToUserList(String uid, String productId) async {
    final url = Uri.parse('$_baseUrl/users/$uid/products');
    final headers = await _authHeaders();
    await http.post(url, headers: headers, body: json.encode({'product_id': productId}));
  }

  Future<void> removeProductFromUserList(String uid, String productId) async {
    final url = Uri.parse('$_baseUrl/users/$uid/products/$productId');
    final headers = await _authHeaders();
    await http.delete(url, headers: headers);
  }

  Future<void> setAlert(Map<String, dynamic> alert) async {
    final url = Uri.parse('$_baseUrl/alerts');
    final headers = await _authHeaders();
    await http.post(url, headers: headers, body: json.encode(alert));
  }

  Future<Map<String, dynamic>?> getUserAlert(String uid, String productId) async {
    final url = Uri.parse('$_baseUrl/alerts/$uid/$productId');
    final headers = await _authHeaders();
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) return json.decode(res.body) as Map<String, dynamic>?;
    return null;
  }
}
