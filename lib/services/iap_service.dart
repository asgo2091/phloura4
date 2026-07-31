import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phloura/definitions/globals.dart' as globals;

class IAPService {
  IAPService._();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  static final IAPService instance = IAPService._();

  static const String productId = 'phloura_pro';

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ProductDetails? _product;

  bool _available = false;
  bool _initialized = false;
  bool _premium = false;
  bool _purchasePending = false;

  ProductDetails? get product => _product;

  bool get isAvailable => _available;

  bool get isPremium => _premium;

  bool get purchasePending => _purchasePending;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    final sw = Stopwatch()..start();
    if (_initialized) {
      return;
    }

    debugPrint("initialize()");

    _available = await _iap.isAvailable();
    debugPrint("isAvailable: ${sw.elapsedMilliseconds} ms");

    if (!_available) {
      throw Exception('Store unavailable');
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint(error.toString());
      },
    );

    await _loadProducts();
    debugPrint("_loadProducts: ${sw.elapsedMilliseconds} ms");

    await _loadPremiumStatus();
    debugPrint("_loadPremiumStatus: ${sw.elapsedMilliseconds} ms");

    _initialized = true;
    debugPrint("initialize finished: ${sw.elapsedMilliseconds} ms");
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({productId});

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      throw Exception('Product not found.');
    }

    _product = response.productDetails.first;
  }

  Future<void> buyPremium() async {
    if (_product == null) {
      throw Exception('Product not loaded');
    }

    final purchaseParam = PurchaseParam(productDetails: _product!);

    _purchasePending = true;

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> _loadPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _premium = false;
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      _premium = false;
      return;
    }

    final data = doc.data();

    _premium = data?['premium'] == true;
  }

  Future<void> refreshPremiumStatus() async {
    await _loadPremiumStatus();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchasePending = false;

          final verified = await _verifyPurchase(purchase);

          if (verified) {
            await _unlockPremium();

            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } else {
            debugPrint('Purchase verification failed.');
          }

          break;

        case PurchaseStatus.error:
          _purchasePending = false;

          final message = purchase.error?.message ?? '';

          debugPrint(message);

          if (message.contains('itemAlreadyOwned')) {
            await _iap.restorePurchases();
          }

          break;
        /*         case PurchaseStatus.error:
          _purchasePending = false;

          debugPrint(purchase.error?.message ?? 'Unknown purchase error');

          break; */

        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'verifyPurchase',
      );

      final result = await callable.call({
        'uid': user.uid,
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'verificationData': purchase.verificationData.serverVerificationData,
        'source': purchase.verificationData.source,
      });

      final data = Map<String, dynamic>.from(result.data);

      return data['valid'] == true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> _unlockPremium() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    _premium = true;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'premium': true,
      'productId': productId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await secureStorage.write(key: 'pro', value: 'true');
    globals.pro = true;
  }

  /*   Future<void> _lockPremium() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    _premium = false;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'premium': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
     await secureStorage.write(key: 'pro', value: 'false');
   globals.pro = false;
  } */
}
