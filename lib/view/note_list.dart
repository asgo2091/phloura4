import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/dialog/delete_dialog.dart';
import 'package:phloura/dialog/shop_old_dialog.dart';
import 'package:phloura/main.dart';
import 'package:phloura/print.dart';
//import 'package:phloura/shop.dart';
import 'package:phloura/view/compilation_design.dart';
import 'package:phloura/view/note_view.dart';
import 'package:phloura/view/place_list.dart';
import 'package:phloura/view/vaxt_list.dart';
import 'package:phloura/view/actionlist.dart';
import 'package:phloura/view/textscreen.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class Notelist extends StatefulWidget {
  const Notelist({super.key});

  @override
  State<Notelist> createState() => _NotelistState();
}

class _NotelistState extends State<Notelist> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late final CrudService _crudservice = CrudService();

  @override
  initState() {
    super.initState();
    _checkPaid();
    _checkAge();
    _refreshNoteList();
  }

  bool _isLoading = true;

  String savedTime = '';
  String _fileContents = '';

  List<Map<String, dynamic>> notelist = [];
  List<Map<String, dynamic>> showlist = [];
  List<Map<String, dynamic>> _actionlist = [];
  List<Map<String, dynamic>> _placelist = [];
  List<Map<String, dynamic>> _vaxtlist = [];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.notelisthelpfile,
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

  Future<void> _refreshNoteList() async {
    final data = await _crudservice.getAllNotes();
    for (int i = 0; i < data.length; i++) {
      String action = '';
      String vaxt = '';
      String place = '';
      int dataid = 0;
      String datadate = '';

      dataid = data[i][noteId];
      datadate = data[i][noteDate];

      _actionlist = await _crudservice.getAction(data[i][noteAction]);
      if (_actionlist.isNotEmpty) {
        action = _actionlist[0][actionTextColumn];
      } else {
        action = ' ';
      }

      //print('_actionlist');
      //print(_actionlist);

      _vaxtlist = await _crudservice.getVaxt(data[i][noteVaxt]);
      if (_vaxtlist.isNotEmpty) {
        vaxt = _vaxtlist[0][vaxtNameColumn];
      } else {
        vaxt = ' ';
      }

      _placelist = await _crudservice.getPlace(data[i][notePlace]);
      if (_placelist.isNotEmpty) {
        place = _placelist[0][placeNameColumn];
      } else {
        place = ' ';
      }

      showlist.add({
        'id': dataid,
        'date': datadate,
        'action': action,
        'vaxt': vaxt,
        'place': place,
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  //*********************************************** */
  Future<void> _checkPaid() async {
    // globals.pro = true;
    final answer = await secureStorage.read(key: 'pro');
    //print(answer);
    if (answer == 'true') {
      globals.pro = true;
    } else {
      globals.pro = false;
    }
  }

  Future<void> _checkAge() async {
    if (globals.pro == false) {
      var startDate = await secureStorage.read(key: 'startdate');
      // print('Startdate');
      // print(startDate);

      if (startDate == null) {
        secureStorage.write(key: 'startdate', value: DateTime.now().toString());
        startDate = DateTime.now().toString();
      } else {
        DateTime firstDate = DateTime.parse(startDate);
        DateTime dateTimeNow = DateTime.now();
        //print('dateTimeNow');
        // print(dateTimeNow);
        int differenceInDays = dateTimeNow.difference(firstDate).inDays;
        //differenceInDays = 101;
        //print('diffdays');
        //print(differenceInDays);

        if (differenceInDays >= 100) {
          // ignore: use_build_context_synchronously
          final timeoutDialog = shopOldDialog(context);
          if (await timeoutDialog) {
            /* Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const ShopScreen()),
            ); */
          } else {
            Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
          }
        }
      }
    }
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
        title: Text(AppLocalizations.of(context)!.notelistappbartitle),
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
                        )!.notelisthelpappbartitle,
                      ),
                    ),
                  );
                }
              });
            },
          ),
          menu(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: showlist.length,
              itemBuilder: (context, index) => Card(
                color: const Color.fromARGB(255, 255, 254, 253),
                margin: const EdgeInsets.all(1),
                // ignore: sort_child_properties_last
                child: ListTile(
                  title: Text(
                    showlist[index]['date'],
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Column(
                    children: [
                      Text(
                        showlist[index]['action'] +
                            // ignore: prefer_interpolation_to_compose_strings
                            ' ' +
                            showlist[index]['vaxt'] +
                            // ignore: prefer_interpolation_to_compose_strings
                            ' ' +
                            showlist[index]['place'],
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            globals.noteId = 0;
                            final shouldDelete = await showDeleteDialog(
                              context,
                            );
                            if (shouldDelete) {
                              _crudservice.deleteNote(showlist[index]['id']);
                            }
                            Future.delayed(const Duration(milliseconds: 500));
                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Notelist(),
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
              globals.noteId = 0;
              globals.actionId = 0;
              globals.vaxtId = 0;
              globals.placeId = 0;
              globals.origin = "NoteList";

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteView()),
              );
            },
            heroTag: 1,
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              globals.origin = 'NoteList';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Print(
                    outlist: showlist,
                    dateSpan: '',
                    content: AppLocalizations.of(context)!.notelistappbartitle,
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
