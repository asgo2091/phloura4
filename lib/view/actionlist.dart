import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'package:phloura/main.dart';
import 'package:phloura/print.dart';
import 'package:phloura/view/compilation_design.dart';
import 'package:phloura/view/note_list.dart';
import 'package:phloura/view/place_list.dart';
import 'package:phloura/view/vaxt_list.dart';
import 'package:phloura/view/actionview.dart';
import 'package:phloura/view/textscreen.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class Actionlist extends StatefulWidget {
  const Actionlist({super.key});

  @override
  State<Actionlist> createState() => _ActionlistState();
}

class _ActionlistState extends State<Actionlist> {
  final CrudService _crudservice = CrudService();

  @override
  initState() {
    super.initState();
    _refreshTaskList();
  }

  bool _isLoading = true;
  String outStringa = '';
  String _fileContents = '';
  List<Map<String, dynamic>> actionlist = [];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.actionlisthelpfile,
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

  Future<void> _refreshTaskList() async {
    final data = await _crudservice.getAllActions();
    // print(data);
    setState(() {
      actionlist = data;
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
        title: Text(AppLocalizations.of(context)!.actionlistappbartitle),
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
                        )!.actionlisthelpappbartitle,
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
              itemCount: actionlist.length,
              itemBuilder: (context, index) => Card(
                color: const Color.fromARGB(255, 255, 254, 253),
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  title: Text(
                    actionlist[index][actionTextColumn],
                    textAlign: TextAlign.center,
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            globals.actionId =
                                actionlist[index][actionIdColumn];
                            globals.origin = 'ActionList';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ActionView(),
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
              globals.actionId = 0;
              globals.origin = "TaskList";

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActionView()),
              );
            },
            heroTag: 1,
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              globals.origin = 'Tasklist';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Print(
                    outlist: actionlist,
                    dateSpan: '',
                    content: AppLocalizations.of(
                      context,
                    )!.actionlistappbartitle,
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
