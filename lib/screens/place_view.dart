import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/crud_service.dart';
import 'package:phloura/dialog/delete_dialog.dart';
import 'package:phloura/screens/place_list.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/l10n/app_localizations.dart';

class PlaceView extends StatefulWidget {
  const PlaceView({super.key});

  @override
  State<PlaceView> createState() => _PlaceViewState();
}

class _PlaceViewState extends State<PlaceView> {
  late final CrudService _crud = CrudService();

  late final TextEditingController _nameController;

  String _fileContents = '';

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.placeedithelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> getPlaceData() async {
    if (globals.placeId > 0) {
      final data = await _crud.getPlace(globals.placeId);
      _nameController.text = data[0][placeNameColumn];
    }
  }

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getPlaceData();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.placeeditappbartitle),
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
                    )!.placeedithelpappbartitle,
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
                /********************************************** */
                SizedBox(
                  child: TextField(
                    controller: _nameController,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.name,

                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.placeviewhint,
                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                      border: InputBorder.none,

                      /*  contentPadding: const EdgeInsets.all(3.0),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)) */
                    ),
                  ),
                ),

                /************************************************* */
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (globals.placeId != 0) {
                          _crud.editPlace(
                            placeId: globals.placeId,
                            placeName: _nameController.text,
                          );
                        } else {
                          _crud.createPlace(placeName: _nameController.text);
                        }

                        globals.placeId = 0;
                        globals.noteId = 0;
                        globals.origin = 'PlaceView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Placelist(),
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
                        globals.placeId = 0;
                        globals.noteId = 0;
                        globals.origin = 'PlaceView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Placelist(),
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
                      //    style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final shouldDelete = await showDeleteDialog(context);
                        if (shouldDelete) {
                          _crud.deletePlace(globals.placeId);
                        }

                        Future.delayed(const Duration(milliseconds: 500));

                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Placelist(),
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
                /*********************************************** */
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* class PlantPlace {
  late final String place;
  PlantPlace(this.place);

  PlantPlace.fromRow(Map<String, Object?> row);
} */
