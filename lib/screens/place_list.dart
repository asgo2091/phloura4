import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/main.dart';
import 'package:phloura/print.dart';
import 'package:phloura/screens/compilation_design.dart';
import 'package:phloura/screens/note_list.dart';
import 'package:phloura/screens/place_view.dart';
import 'package:phloura/screens/vaxt_list.dart';
import 'package:phloura/screens/actionlist.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class Placelist extends StatefulWidget {
  const Placelist({super.key});

  @override
  State<Placelist> createState() => _PlaceState();
}

class _PlaceState extends State<Placelist> {
  final CrudService _crudservice = CrudService();

  @override
  initState() {
    _refreshPlaceList();
    super.initState();
  }

  bool _isLoading = true;

  String outStringp = '';
  String _fileContents = '';
  List<Map<String, dynamic>> placelist = [];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.placelisthelpfile,
    );

    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> openExternalLink(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _refreshPlaceList() async {
    final data = await _crudservice.getAllPlaces();
    setState(() {
      placelist = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/phloura_logo.jpg'),
        ),
        title: Text(AppLocalizations.of(context)!.placelistappbartitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: () async {
              await loadAsset();
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TextScreen(
                    textOut: _fileContents,
                    heading: AppLocalizations.of(
                      context,
                    )!.placelisthelpappbartitle,
                  ),
                ),
              );
            },
          ),
          menu(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: placelist.length,
              itemBuilder: (context, index) => Card(
                color: const Color.fromARGB(255, 255, 254, 253),
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  title: Text(
                    placelist[index][placeNameColumn],
                    textAlign: TextAlign.center,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            globals.placeId = placelist[index][placeIdColumn];
                            globals.origin = 'PlaceList';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlaceView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              globals.placeId = 0;
              globals.origin = "PlaceList";
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaceView()),
              );
            },
            heroTag: 1,
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              globals.origin = 'Placelist';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Print(
                    outlist: placelist,
                    dateSpan: '',
                    content: AppLocalizations.of(context)!.placelistappbartitle,
                  ),
                ),
              );
            },
            heroTag: null,
            child: Icon(Icons.print),
          ),
        ],
      ),
    );
  }

  Widget menu() {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        switch (value) {
          case '1':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );

          case '2':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Notelist()),
            );
          case '3':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Plantlist()),
            );

          case '4':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Placelist()),
            );
          case '5':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Actionlist()),
            );
          case '6':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompilationDesign(),
              ),
            );

          case '7':
            openExternalLink(AppLocalizations.of(context)!.seedshop);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: '1',
          child: Text(AppLocalizations.of(context)!.menustart),
        ),
        PopupMenuItem(
          value: '2',
          child: Text(AppLocalizations.of(context)!.menunote),
        ),
        PopupMenuItem(
          value: '3',
          child: Text(AppLocalizations.of(context)!.menuplant),
        ),
        PopupMenuItem(
          value: '4',
          child: Text(AppLocalizations.of(context)!.menuplace),
        ),
        PopupMenuItem(
          value: '5',
          child: Text(AppLocalizations.of(context)!.menuaction),
        ),
        PopupMenuItem(
          value: '6',
          child: Text(AppLocalizations.of(context)!.menucompilations),
        ),
        PopupMenuItem(
          value: '7',
          child: Text(AppLocalizations.of(context)!.seedshoptext),
        ),
      ],
    );
  }
}
