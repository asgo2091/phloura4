import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'package:phloura/dialog/delete_dialog.dart';
import 'package:phloura/screens/actionlist.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/definitions/globals.dart' as globals;

class ActionView extends StatefulWidget {
  const ActionView({super.key});

  @override
  State<ActionView> createState() => _ActionViewState();
}

class _ActionViewState extends State<ActionView> {
  late final CrudService _crud = CrudService();

  late final TextEditingController _nameController;

  String _fileContents = '';

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.actionedithelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> _geActionData() async {
    if (globals.actionId > 0) {
      final data = await _crud.getAction(globals.actionId);
      _nameController.text = data[0][actionTextColumn];
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
    _geActionData();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.actioneditappbartitle),
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
                    )!.actionedithelpappbartitle,
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
                      hintText: AppLocalizations.of(context)!.actionviewhint,
                      hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                      border: InputBorder.none,
                      /*                  contentPadding: const EdgeInsets.all(3.0),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)), */
                    ),
                  ),
                ),

                /************************************************* */
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (globals.actionId != 0) {
                          _crud.editAction(
                            actionId: globals.actionId,
                            actionText: _nameController.text,
                          );
                        } else {
                          _crud.createAction(actionText: _nameController.text);
                        }

                        globals.placeId = 0;
                        globals.noteId = 0;
                        globals.origin = 'ActionView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Actionlist(),
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
                        globals.origin = 'ActionView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Actionlist(),
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
                          _crud.deleteAction(globals.actionId);
                        }

                        Future.delayed(const Duration(milliseconds: 500));

                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Actionlist(),
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
