import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/dialog/delete_dialog.dart';
import 'package:phloura/screens/note_list.dart';
import 'package:phloura/definitions/globals.dart' as globals;
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/l10n/app_localizations.dart';

//PartyEditState 'PartyView'

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late final CrudService _crud = CrudService();
  bool isLoading = false;
  bool isOld = false;
  String action = '';
  String vaxt = '';
  String place = '';

  late List<String> fromActions = [];
  late List<String> fromPlants = [];
  late List<String> fromPlaces = [];

  late final TextEditingController noteController;
  late final TextEditingController actionController;
  late final TextEditingController plantController;
  late final TextEditingController placeController;

  String _fileContents = '';

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.noteedithelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> fetchAutoLists() async {
    final inActions = await _crud.getActions();
    final inPlaces = await _crud.getPlaces();
    final inPlants = await _crud.getPlants();
    setState(() {
      isLoading = true;
    });

    final actionData = inActions.map((e) => e["actionText"] as String).toList();
    final placeData = inPlaces.map((e) => e["placeName"] as String).toList();
    final plantData = inPlants.map((e) => e["vaxtName"] as String).toList();

    setState(() {
      isLoading = false;
      fromActions = actionData;
      fromPlaces = placeData;
      fromPlants = plantData;
    });
  }

  Future<void> getEventData() async {
    if (globals.noteId > 0) {
      final data = await _crud.getNote(globals.noteId);
      noteController.text = data[0][noteDate];
    }
  }

  @override
  void initState() {
    noteController = TextEditingController();
    actionController = TextEditingController();
    plantController = TextEditingController();
    placeController = TextEditingController();
    fetchAutoLists();
    super.initState();
  }

  @override
  void dispose() {
    noteController.dispose();
    actionController.dispose();
    plantController.dispose();
    placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getEventData();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.noteeditappbartitle),
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
                    )!.noteedithelpappbartitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // *******************************************
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _getDate(),
                _getAction(),
                _getPlant(),
                _getPlace(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (noteController.text.isEmpty) {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(
                                  context,
                                )!.missingdatedialogtitle,
                              ),
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.missingdatedialogcontent,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          if (action.isNotEmpty) {
                            if (action[0] != ' ') {
                              //Starts with empty char
                              final data = await _crud.checkOldAction(
                                actionText: action,
                              );

                              if (data.isNotEmpty) {
                                globals.actionId = data[0][actionIdColumn];
                              } else {
                                globals.actionId = await _crud.createAction(
                                  actionText: action,
                                );
                              }
                            }
                          }

                          if (vaxt.isNotEmpty) {
                            if (vaxt[0] != ' ') {
                              //Starts with empty char
                              final data1 = await _crud.checkOldVaxt(
                                vaxtName: vaxt,
                              );
                              if (data1.isNotEmpty) {
                                globals.vaxtId = data1[0][vaxtIdColumn];
                              } else {
                                globals.vaxtId = await _crud.createVaxt(
                                  vaxtName: vaxt,
                                  vaxtLatin: '',
                                  vaxtText: '',
                                  vaxtImg: '',
                                );
                              }
                            }
                          }

                          if (place.isNotEmpty) {
                            if (place[0] != ' ') {
                              //Starts with empty char
                              final data3 = await _crud.checkOldPlace(
                                placeName: place,
                              );
                              if (data3.isNotEmpty) {
                                globals.placeId = data3[0][placeIdColumn];
                              } else {
                                globals.placeId = await _crud.createPlace(
                                  placeName: place,
                                );
                              }
                            }
                          }

                          if (globals.noteId != 0) {
                            _crud.editNote(
                              noteId: globals.noteId,
                              noteDate: noteController.text,
                            );
                          } else {
                            globals.noteId = await _crud.createNote(
                              noteDate: noteController.text,
                              noteAction: globals.actionId,
                              noteVaxt: globals.vaxtId,
                              notePlace: globals.placeId,
                            );
                          }
                        }

                        globals.origin = 'DateView';

                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Notelist(),
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
                    ),

                    /**************************************** */
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        globals.noteId = 0;
                        globals.origin = 'DateView';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Notelist(),
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
                    ),

                    /************************************************** */
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final shouldDelete = await showDeleteDialog(context);
                        if (shouldDelete) {
                          _crud.deleteNote(globals.noteId);
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
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.deletebutton),
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

  Widget _getDate() {
    return TextField(
      controller: noteController,
      readOnly: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        border: InputBorder.none,
        hintText: AppLocalizations.of(context)!.noteedithintdate,
        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          noteController.text = formattedDate;
        } else {
          noteController.text = '';
        }
      },
      // ),
    );
  }

  Widget _getAction() {
    return Column(
      children: [
        Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) {
            setState(() {
              action = textEditingValue.text;
            });
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              return fromActions.where(
                (word) => word[0].toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            }
          },
          onSelected: (String selection) {
            // print(selection);
            action = selection;
          },

          fieldViewBuilder:
              (context, actionController, focusNode, onEditingComplete) {
                return TextField(
                  controller: actionController,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.noteedithintaction,
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _getPlant() {
    return Column(
      children: [
        Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) {
            setState(() {
              vaxt = textEditingValue.text;
            });
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              return fromPlants.where(
                (word) => word[0].toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            }
          },
          onSelected: (String selection) {
            // print(selection);
            vaxt = selection;
          },
          fieldViewBuilder:
              // ignore: no_leading_underscores_for_local_identifiers
              (context, plantController, focusNode, onEditingComplete) {
                return TextField(
                  controller: plantController,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.noteedithintplant,
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _getPlace() {
    return Column(
      children: [
        Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) {
            setState(() {
              place = textEditingValue.text;
            });
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              return fromPlaces.where(
                (word) => word[0].toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            }
          },
          onSelected: (String selection) {
            // print(selection);
            place = selection;
          },
          fieldViewBuilder:
              (context, placeController, focusNode, onEditingComplete) {
                return TextField(
                  controller: placeController,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.noteedithintplace,
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                  ),
                );
              },
        ),
      ],
    );
  }
}
