import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phloura/definitions/globals.dart' as globals;

//import 'package:in_app_purchase_android/billing_client_wrappers.dart';

class IAPService extends ChangeNotifier {
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
  bool _disposed = false;
  Future<void>? _initializationFuture;

  ProductDetails? get product => _product;

  bool get isAvailable => _available;

  bool get isPremium => _premium;

  bool get purchasePending => _purchasePending;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    _checkDisposed();

    // Return existing initialization if already in progress
    if (_initializationFuture != null) {
      return _initializationFuture!;
    }

    if (_initialized) {
      return;
    }

    _initializationFuture = _performInitialization();
    return _initializationFuture!;
  }

  Future<void> _performInitialization() async {
    final sw = Stopwatch()..start();

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
    notifyListeners();
  }

  Future<void> saveUserData() async {
    _checkDisposed();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('saveUserData: no authenticated user');
      return;
    }

    final platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
        ? 'ios'
        : 'other';

    debugPrint('=== SAVE USER DATA ===');
    debugPrint('uid: ${user.uid}');
    debugPrint('platform: $platform');

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'platform': platform,
      }, SetOptions(merge: true));

      debugPrint('saveUserData: Firestore write OK');
    } catch (e, stackTrace) {
      debugPrint('=== SAVE USER DATA FAILED ===');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
    }
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
    _checkDisposed();
    if (_product == null) {
      throw Exception('Product not loaded');
    }

    final purchaseParam = PurchaseParam(productDetails: _product!);
    debugPrint('=========buyPremium===============');
    debugPrint('purchaseParam: ${purchaseParam}');
    debugPrint('=========buyPremium===============');

    _purchasePending = true;
    notifyListeners();

    try {
      debugPrint('=== START BUY ===');
      debugPrint('productId: ${purchaseParam.productDetails.id}');

      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      debugPrint('buyNonConsumable result: $result');
    } catch (e, stack) {
      debugPrint('=== BUY ERROR ===');
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');
      debugPrint('=== BUY ERROR ===');
    }

    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    ); //Skickas till Google play

    debugPrint('============END BUY=========');
  }

  Future<void> restorePurchases() async {
    _checkDisposed();
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

    final wasChanged = _premium != (data?['premium'] == true);
    _premium = data?['premium'] == true;

    if (wasChanged) {
      notifyListeners();
    }
  }

  Future<void> refreshPremiumStatus() async {
    _checkDisposed();
    await _loadPremiumStatus();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;
    await _subscription?.cancel();
    super.dispose();
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('IAPService has been disposed');
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    if (_disposed) {
      return;
    }

    for (final purchase in purchases) {
      debugPrint('==============PURCHASE STREAM UPDATE==================');
      debugPrint('status: ${purchase.status}');
      debugPrint('productID: ${purchase.productID}');
      debugPrint('purchaseID: ${purchase.purchaseID}');
      debugPrint(
        'serverVerificationData: '
        '${purchase.verificationData.serverVerificationData}',
      );
      debugPrint(
        'pendingCompletePurchase: '
        '${purchase.pendingCompletePurchase}',
      );
    }

    for (final purchase in purchases) {
      debugPrint("_onPurchaseUpdate: ${purchase.status}");
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          notifyListeners();
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
          notifyListeners();

          final message = purchase.error?.message ?? '';

          debugPrint(message);

          if (message.contains('itemAlreadyOwned')) {
            await _iap.restorePurchases();
          }

          break;
        /*              case PurchaseStatus.error:
          _purchasePending = false;

          debugPrint(purchase.error?.message ?? 'Unknown purchase error');

          break;  */

        case PurchaseStatus.canceled:
          _purchasePending = false;
          notifyListeners();
          break;
      }
    }
    debugPrint('==============PURCHASE STREAM UPDATE END==================');
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint("=== VERIFY PURCHASE START ===");
    debugPrint("user: $user");
    debugPrint("uid: ${user?.uid}");
    debugPrint("productId: ${purchase.productID}");
    debugPrint("purchaseId: ${purchase.purchaseID}");
    debugPrint("source: ${purchase.verificationData.source}");
    debugPrint(
      "serverVerificationData: "
      "${purchase.verificationData.serverVerificationData}",
    );

    if (user == null) {
      debugPrint("VERIFY FAILED: user == null");
      return false;
    }

    try {
      final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

      final callable = functions.httpsCallable('verifyPurchase');

      debugPrint("Calling Firebase verifyPurchase...");
      debugPrint('=== FIRESTORE PREMIUM WRITE ===');

      final result = await callable.call({
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'verificationData': purchase.verificationData.serverVerificationData,
        'source': purchase.verificationData.source,
      });

      debugPrint("Firebase result: ${result.data}");

      final data = Map<String, dynamic>.from(result.data);

      debugPrint("valid = ${data['success']}");
      debugPrint("valid type = ${data['success'].runtimeType}");

      final valid = data['success'] == true;
      debugPrint('=== FIRESTORE PREMIUM WRITE END ===');

      debugPrint("VERIFY RESULT = $valid");
      debugPrint("=== VERIFY PURCHASE END ===");
      return valid;
    } catch (e, stackTrace) {
      debugPrint("_verifyPurchase ERROR: $e");
      debugPrint("_verifyPurchase STACK: $stackTrace");
      debugPrint("=== VERIFY PURCHASE FAILED ===");
      return false;
    }
  }

  Future<void> _unlockPremium() async {
    _checkDisposed();

    _premium = true;
    globals.pro = true;

    await secureStorage.write(key: 'pro', value: 'true');

    notifyListeners();
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

  ///********************************************************* */

  /*  Future<bool> consumeExistingPurchase(String purchaseToken) async {
    final billingClient = BillingClient((purchasesResult) {
      // Vi startar inte något nytt köp här.
      // Callbacken krävs bara av BillingClient-konstruktorn.
    }, null);

    try {
      debugPrint('token = ${purchaseToken}');
      // Anslut till Google Play Billing.
      final connectionResult = await billingClient.startConnection(
        onBillingServiceDisconnected: () {
          debugPrint('BillingClient disconnected');
        },
      );

      debugPrint(
        'Billing connection: '
        '${connectionResult.responseCode} '
        '${connectionResult.debugMessage}',
      );

      if (connectionResult.responseCode != BillingResponse.ok) {
        return false;
      }

      // Konsumera det befintliga köpet.
      final consumeResult = await billingClient.consumeAsync(purchaseToken);

      debugPrint(
        'Consume result: '
        '${consumeResult.responseCode} '
        '${consumeResult.debugMessage}',
      );

      return consumeResult.responseCode == BillingResponse.ok;
    } catch (e, stackTrace) {
      debugPrint('consumeExistingPurchase error: $e');
      debugPrint(stackTrace as String?);
      return false;
    }
  } */
}
