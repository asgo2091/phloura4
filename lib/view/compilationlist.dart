import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/l10n/app_localizations.dart';
import 'package:phloura/main.dart';
import 'package:phloura/print.dart';
import 'package:phloura/view/actionlist.dart';
import 'package:phloura/view/compilation_design.dart';
import 'package:phloura/view/note_list.dart';
import 'package:phloura/view/place_list.dart';
import 'package:phloura/view/textscreen.dart';
import 'package:phloura/view/vaxt_list.dart';

class Compilationlist extends StatefulWidget {
  const Compilationlist({
    super.key,
    required this.sortKey,
    required this.fromDate,
    required this.toDate,
    required this.sortOrder,
  });

  final String sortKey;
  final String fromDate;
  final String toDate;
  final SortOrder sortOrder;

  @override
  State<Compilationlist> createState() => _CompilationlistState();
}

class _CompilationlistState extends State<Compilationlist> {
  final CrudService _crud = CrudService();

  @override
  initState() {
    setOrder();
    refreshShowList();
    super.initState();
  }

  bool actionOrder = false;
  bool placeOrder = false;
  bool vaxtOrder = false;

  String _fileContents = '';
  String dateSpan = '';
  String outStringC = '';
  String sortKey = '';

  List<Map<String, dynamic>> notelist = [];
  final List<Map<String, dynamic>> _showlist = [];
  List<Map<String, dynamic>> templist = [];

  List<Map<String, dynamic>> datelist = [];
  List<Map<String, dynamic>> _actionlist = [];
  List<Map<String, dynamic>> _placelist = [];
  List<Map<String, dynamic>> _vaxtlist = [];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.compilationlisthelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> setOrder() async {
    switch (widget.sortOrder) {
      case SortOrder.action:
        actionOrder = true;
      case SortOrder.plant:
        vaxtOrder = true;
      case SortOrder.place:
        placeOrder = true;
      case SortOrder.none:
        // No order to set
        break;
    }
  }

  void refreshShowList() async {
    dateSpan = '${widget.fromDate} - ${widget.toDate}';

    final N = await _crud.noteListPart(widget.fromDate, widget.toDate);
    setState(() {
      templist = N;
    });

    for (int i = 0; i < templist.length; i++) {
      String action = '';
      String vaxt = '';
      String place = '';
      int dataid = 0;
      String datadate = '';

      dataid = templist[i][noteId];
      datadate = templist[i][noteDate];

      _actionlist = await _crud.getAction(templist[i][noteAction]);
      if (_actionlist.isNotEmpty) {
        action = _actionlist[0][actionTextColumn];
      } else {
        action = ' ';
      }

      _vaxtlist = await _crud.getVaxt(templist[i][noteVaxt]);
      if (_vaxtlist.isNotEmpty) {
        vaxt = _vaxtlist[0][vaxtNameColumn];
      } else {
        vaxt = ' ';
      }

      _placelist = await _crud.getPlace(templist[i][notePlace]);
      if (_placelist.isNotEmpty) {
        place = _placelist[0][placeNameColumn];
      } else {
        place = ' ';
      }

      if ((vaxt.compareTo(widget.sortKey) == 0) && (vaxtOrder)) {
        _showlist.add({
          'id': dataid,
          'date': datadate,
          'action': action,
          'vaxt': vaxt,
          'place': place,
        });
      } else {
        if ((place.compareTo(widget.sortKey) == 0) && (placeOrder)) {
          _showlist.add({
            'id': dataid,
            'date': datadate,
            'action': action,
            'vaxt': vaxt,
            'place': place,
          });
        } else {
          if ((action.compareTo(widget.sortKey) == 0) && (actionOrder)) {
            _showlist.add({
              'id': dataid,
              'date': datadate,
              'action': action,
              'vaxt': vaxt,
              'place': place,
            });
          }
        }
      }
      setState(() {});
    }

    if (_showlist.isEmpty) {
      showDialog<String>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.missingindatadialogtitle),
          content: Text(
            AppLocalizations.of(context)!.missingindatadialogcontent,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // ignore: strict_top_level_inference
  _refreshOutData() async {
    if (actionOrder) {
      for (int i = 0; i < _showlist.length; i++) {
        outStringC =
            '$outStringC${_showlist[i]['date']} ${_showlist[i]['vaxt']} ${_showlist[i]['place']} \n';
      }
    } else {
      if (placeOrder) {
        for (int i = 0; i < _showlist.length; i++) {
          outStringC =
              '$outStringC${_showlist[i]['date']} ${_showlist[i]['action']} ${_showlist[i]['vaxt']} \n';
        }
      } else {
        if (vaxtOrder) {
          for (int i = 0; i < _showlist.length; i++) {
            outStringC =
                '$outStringC${_showlist[i]['date']} ${_showlist[i]['action']} ${_showlist[i]['place']} \n';
          }
        } else {
          outStringC = '';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_showlist);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/phloura_logo.jpg'),
        ),
        title: Column(
          children: [
            Text(AppLocalizations.of(context)!.compilationlistappbartitle),
            Text('${widget.sortKey} $dateSpan', style: TextStyle(fontSize: 12)),
          ],
        ),
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
                        )!.compilationlisthelpappbartitle,
                      ),
                    ),
                  );
                }
              });
            },
          ),
          PopupMenuButton<String>(
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
            ],
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[_actionList(), _placeList(), _vaxtList()],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () {
          globals.origin = 'Compilationlist';
          _refreshOutData();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Print(
                outlist: _showlist,
                dateSpan: dateSpan,
                content: widget.sortKey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _actionList() {
    if (!actionOrder) {
      return SizedBox();
    } else {
      return ListView.builder(
        itemCount: _showlist.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => Card(
          color: const Color.fromARGB(255, 255, 254, 253),
          margin: const EdgeInsets.all(1),
          // ignore: sort_child_properties_last
          child: ListTile(
            title: Text(_showlist[index]['date'], textAlign: TextAlign.center),
            subtitle: Column(
              children: [
                Text(
                  _showlist[index]['vaxt'] +
                      // ignore: prefer_interpolation_to_compose_strings
                      ' ' +
                      _showlist[index]['place'],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _placeList() {
    if (!placeOrder) {
      return SizedBox();
    } else {
      return ListView.builder(
        itemCount: _showlist.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => Card(
          color: const Color.fromARGB(255, 255, 254, 253),
          margin: const EdgeInsets.all(1),
          // ignore: sort_child_properties_last
          child: ListTile(
            title: Text(_showlist[index]['date'], textAlign: TextAlign.center),
            subtitle: Column(
              children: [
                Text(
                  _showlist[index]['action'] +
                      // ignore: prefer_interpolation_to_compose_strings
                      ' ' +
                      _showlist[index]['vaxt'],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _vaxtList() {
    if (!vaxtOrder) {
      return SizedBox();
    } else {
      return ListView.builder(
        itemCount: _showlist.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => Card(
          color: const Color.fromARGB(255, 255, 254, 253),
          margin: const EdgeInsets.all(1),
          // ignore: sort_child_properties_last
          child: ListTile(
            title: Text(_showlist[index]['date'], textAlign: TextAlign.center),
            subtitle: Column(
              children: [
                Text(
                  _showlist[index]['action'] +
                      // ignore: prefer_interpolation_to_compose_strings
                      ' ' +
                      _showlist[index]['place'],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
