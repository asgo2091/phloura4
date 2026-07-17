import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/l10n/app_localizations.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/services/iap_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  String _fileContents = '';

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.buyhelpfile,
    );

    setState(() {
      _fileContents = fileText;
    });
  }

  @override
  initState() {
    IAPService.instance.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(AppLocalizations.of(context)!.buyappbartitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: () {
              loadAsset();
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextScreen(
                        textOut: _fileContents,
                        heading: AppLocalizations.of(
                          context,
                        )!.buyhelpappbartitle,
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.shopconnectiontext),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  proceedWithIAP();
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.gobutton),
                // style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),

                child: Text(AppLocalizations.of(context)!.quitbutton),
                // style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> proceedWithIAP() async {
    if (!IAPService.instance.isAvailable) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('In-App Purchase is not available on this device.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await IAPService.instance.buyPremium();

      // Don't show success here.
      // The purchase may still be pending.
    } catch (error) {
      if (error.toString().contains('itemAlreadyOwned')) {
        _addNewItem('pro', 'true');
        globals.pro = true;
        //Closes dialog
      } else {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /*  Future<void> proceedWithIAP(String packageID) async {
    if (await _iapService.isIAPAvailable()) {
      _iapService.buyProduct(
        packageID.toString(),
        (purchase) {
          _addNewItem('pro', 'true');
          globals.pro = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Top-up of \$$packageID  was successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // _next(selectedAmountAsDouble);
        },
        (error) {
          // Handle error
          if (error == 'BillingResponse.itemAlreadyOwned') {
            _addNewItem('pro', 'true');
            globals.pro = true;
            Future.delayed(const Duration(milliseconds: 500));

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } else {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: In App Purchase not available on this device',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } */

  Future<void> _addNewItem(String key, String value) async {
    await secureStorage.write(key: key, value: value);
  }
}
