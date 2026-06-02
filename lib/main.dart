import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'package:phloura/view/textscreen.dart';
import 'package:phloura/view/note_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const PhlouraApp());
}

class PhlouraApp extends StatelessWidget {
  const PhlouraApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phloura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
      ),
      home: const Homepage(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _fileContents = '';

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.appdesignfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.yellow,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (kIsWeb == true)
                RichText(
                  text: TextSpan(
                    text: 'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                ),
              if (kIsWeb == true) //Check if webb device
                RichText(
                  text: TextSpan(
                    text:
                        'This app can only run on android devices such as phones and tablets.',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              RichText(
                text: TextSpan(
                  text: 'Phloura',
                  style: TextStyle(
                    color: Colors.black26,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
              ),
              _showLogo(),
              const SizedBox(height: 5),
              const Text('ver. 2.0.4'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Notelist()),
                  );
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.gobutton),
                //child: Text('Go'),
              ),
              const SizedBox(height: 5),
              TextButton(
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
                            )!.appdesignappbartitle,
                          ),
                        ),
                      );
                    }
                  });
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.appdesignbutton),
                //child: Text('design'),
              ),
              TextButton(
                onPressed: () {
                  /*                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShopScreen()),
                  ); */
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.shopbutton),
                //child: Text('Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showLogo() {
    if (MediaQuery.of(context).size.width >=
        MediaQuery.of(context).size.height) //tilted
    {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        alignment: Alignment.centerLeft,

        width: 140,
        height: 140,
        // color: Colors.yellow,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fitHeight, // change this line
            image: AssetImage('assets/phloura_logo.jpg'),
            scale: 0.8,
          ),
        ),
      );
    } else {
      return Image.asset('assets/phloura_logo.jpg');
    }
  }
}
