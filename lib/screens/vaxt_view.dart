import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';

import 'package:phloura/crud_service.dart';
import 'package:phloura/dialog/delete_dialog.dart';

import 'package:phloura/screens/vaxt_list.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/l10n/app_localizations.dart';

class PlantView extends StatefulWidget {
  const PlantView({super.key});

  @override
  State<PlantView> createState() => _PlantViewState();
}

class _PlantViewState extends State<PlantView> {
  late final CrudService _crud = CrudService();

  late final TextEditingController _nameController;
  late final TextEditingController _latinController;
  late final TextEditingController _textController;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();

  // String dropdownValue = placeNameList.first;
  String _fileContents = '';

  List<Map<String, dynamic>> placelist = [];
  List<String> placeNamelist = <String>[];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.plantedithelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> getPlantData() async {
    if (globals.vaxtId > 0) {
      final data = await _crud.getVaxt(globals.vaxtId);
      _nameController.text = data[0][vaxtNameColumn];
      _latinController.text = data[0][vaxtLatinColumn];
      _textController.text = data[0][vaxtTextColumn];
    }
  }

  @override
  void initState() {
    _nameController = TextEditingController();
    _latinController = TextEditingController();
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latinController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getPlantData();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.planteditappbartitle),
        backgroundColor: Colors.yellow,
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
                    )!.plantedithelpappbartitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Scrollbar(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: TextField(
                      scrollController: _scrollController,
                      controller: _nameController,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.namehint,
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        border: InputBorder.none,
                        /*                   contentPadding: const EdgeInsets.all(3.0),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)), */
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Scrollbar(
                    controller: _scrollController2,
                    child: TextField(
                      scrollController: _scrollController2,
                      controller: _latinController,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.latinhint,
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        border: InputBorder.none,
                        /*  contentPadding: const EdgeInsets.all(3.0),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)), */
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Scrollbar(
                    controller: _scrollController3,
                    child: TextField(
                      scrollController: _scrollController3,
                      controller: _textController,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Text: ',
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        border: InputBorder.none,
                        /* contentPadding: EdgeInsets.all(3.0),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)), */
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (globals.vaxtId != 0) {
                          _crud.editVaxt(
                            vaxtId: globals.vaxtId,
                            vaxtName: _nameController.text,
                            vaxtLatin: _latinController.text,
                            vaxtText: _textController.text,
                            vaxtImg: ' ',
                          );
                        } else {
                          _crud.createVaxt(
                            vaxtName: _nameController.text,
                            vaxtLatin: _latinController.text,
                            vaxtText: _textController.text,
                            vaxtImg: ' ',
                          );
                        }

                        globals.vaxtId = 0;
                        globals.noteId = 0;
                        globals.origin = 'PlantView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Plantlist(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.savebutton),
                      // style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        globals.vaxtId = 0;
                        globals.noteId = 0;
                        globals.origin = 'PlantView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Plantlist(),
                          ),
                        );
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
                      // style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final shouldDelete = await showDeleteDialog(context);
                        if (shouldDelete) {
                          _crud.deleteVaxt(globals.vaxtId);
                        }

                        Future.delayed(const Duration(milliseconds: 500));

                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Plantlist(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.deletebutton),
                      // style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlantNames {
  late final String name;
  PlantNames(this.name);
}
