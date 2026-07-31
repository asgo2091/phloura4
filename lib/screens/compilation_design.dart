import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phloura/constants.dart';
import 'package:phloura/crud_service.dart';
import 'package:phloura/screens/compilationlist.dart';
import 'package:phloura/screens/note_list.dart';
import 'package:phloura/screens/textscreen.dart';
import 'package:phloura/l10n/app_localizations.dart';

enum SortKey { plant, place, action }

enum SortOrder { plant, place, action, none }

class RadioGroup extends InheritedWidget {
  final SortKey? selectedValue;
  final ValueChanged<SortKey?> onValueChanged;

  const RadioGroup({
    super.key,
    required this.selectedValue,
    required this.onValueChanged,
    required super.child,
  });

  static RadioGroup? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RadioGroup>();
  }

  @override
  bool updateShouldNotify(RadioGroup oldWidget) {
    return selectedValue != oldWidget.selectedValue;
  }
}

class RadioDropdownTile extends StatelessWidget {
  final String title;
  final SortKey value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onDropdownChanged;
  final String hintText;

  const RadioDropdownTile({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onDropdownChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final group = RadioGroup.of(context);
    if (group == null) return const SizedBox.shrink();

    final selected = group.selectedValue == value;
    return Builder(
      builder: (context) {
        // Use an icon instead of Radio widget to avoid deprecated
        // onChanged/groupValue APIs. The RadioGroup ancestor manages
        // selection state; we show the selection visually with an icon
        // and call the group's handler from the ListTile onTap.
        final radio = Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        );

        return ListTile(
          title: Text(title),
          leading: radio,
          onTap: () => group.onValueChanged(value),
          trailing: selected
              ? DropdownButton<String>(
                  hint: Text(hintText),
                  icon: const Visibility(
                    visible: false,
                    child: Icon(Icons.arrow_downward),
                  ),
                  onChanged: (value) {
                    if (value != null) onDropdownChanged(value);
                  },
                  items: items,
                )
              : null,
        );
      },
    );
  }
}

class CompilationDesign extends StatefulWidget {
  const CompilationDesign({super.key});

  @override
  State<CompilationDesign> createState() => _CompilationDesignState();
}

class _CompilationDesignState extends State<CompilationDesign> {
  late final CrudService _crud = CrudService();
  int? _choosenKey;
  bool showDropDowns = true;
  bool getTimespan = false;

  String _fileContents = '';
  String _keyValue = '';
  String _fromDate = '';
  String _toDate = '';
  SortOrder _sortOrder = SortOrder.none;

  List<DropdownMenuItem<String>> actionList = [];
  List<DropdownMenuItem<String>> vaxtList = [];
  List<DropdownMenuItem<String>> placeList = [];
  List<Map<String, dynamic>> _templist = [];

  Future<void> loadAsset() async {
    String fileText = await rootBundle.loadString(
      AppLocalizations.of(context)!.compilationdesignhelpfile,
    );
    setState(() {
      _fileContents = fileText;
    });
  }

  Future<void> loadActionList() async {
    _crud.getAllActions().then((listMap) {
      listMap
          .map((map) {
            return getActionDropDownWidget(map);
          })
          .forEach((dropDownItem) {
            actionList.add(dropDownItem);
          });
      setState(() {});
    });
  }

  Future<void> loadVaxtList() async {
    _crud.getAllVaxts().then((vaxtlistMap) {
      vaxtlistMap
          .map((map) {
            return getVaxtDropDownWidget(map);
          })
          .forEach((dropDownItem) {
            vaxtList.add(dropDownItem);
          });
      setState(() {});
    });
  }

  Future<void> loadPlaceList() async {
    _crud.getAllPlaces().then((placelistMap) {
      placelistMap
          .map((map) {
            return getPlaceDropDownWidget(map);
          })
          .forEach((dropDownItem) {
            placeList.add(dropDownItem);
          });
      setState(() {});
    });
  }

  Future<void> collectValues({required int key, required String value}) async {
    switch (key) {
      case 1:
        _sortOrder = SortOrder.plant;
        break;
      case 2:
        _sortOrder = SortOrder.place;
        break;
      case 3:
        _sortOrder = SortOrder.action;
        break;
      default:
        _sortOrder = SortOrder.none;
    }

    _keyValue = value;
    setState(() {});
  }

  Future<void> _getFromDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _fromDate = formattedDate;
      });
    }
  }

  Future<void> _getToDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _toDate = formattedDate;
      });
    }
  }

  Future<void> _setDefaultDate() async {
    final L = await _crud.getFirstDate();
    setState(() {
      _templist = L;
    });
    _fromDate = _templist[0][noteDate];

    final M = await _crud.getLastDate();
    setState(() {
      _templist = M;
    });
    _toDate = _templist[0][noteDate];
  }

  @override
  void initState() {
    super.initState();
    loadActionList();
    loadVaxtList();
    loadPlaceList();
    _setDefaultDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.compilationdesignappbartitle),
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
                    )!.compilationdesignhelpappbartitle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RadioGroup(
          selectedValue: _choosenKey == null
              ? null
              : SortKey.values[_choosenKey! - 1],
          onValueChanged: (value) {
            setState(() {
              _choosenKey = value == null
                  ? null
                  : SortKey.values.indexOf(value) + 1;
            });
          },
          child: Column(
            children: [
              RadioDropdownTile(
                title: AppLocalizations.of(context)!.compilationdesignvaxtkey,
                value: SortKey.plant,
                items: vaxtList,
                onDropdownChanged: (value) =>
                    collectValues(key: 1, value: value),
                hintText: AppLocalizations.of(context)!.compilationdesignchoose,
              ),
              RadioDropdownTile(
                title: AppLocalizations.of(context)!.compilationdesignplacekey,
                value: SortKey.place,
                items: placeList,
                onDropdownChanged: (value) =>
                    collectValues(key: 2, value: value),
                hintText: AppLocalizations.of(context)!.compilationdesignchoose,
              ),
              RadioDropdownTile(
                title: AppLocalizations.of(context)!.compilationdesignactionkey,
                value: SortKey.action,
                items: actionList,
                onDropdownChanged: (value) =>
                    collectValues(key: 3, value: value),
                hintText: AppLocalizations.of(context)!.compilationdesignchoose,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _getFromDate,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.compilationdesignfromdate,
                    ),
                  ),
                  TextButton(
                    onPressed: _getToDate,
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.compilationdesigntodate,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 5),
              showSearchData(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Compilationlist(
                            sortKey: _keyValue,
                            fromDate: _fromDate,
                            toDate: _toDate,
                            sortOrder: _sortOrder,
                          ),
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
                    child: Text(AppLocalizations.of(context)!.gobutton),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> getActionDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['actionText'],
      child: Text(map['actionText']),
    );
  }

  DropdownMenuItem<String> getVaxtDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['vaxtName'],
      child: Text(map['vaxtName']),
    );
  }

  DropdownMenuItem<String> getPlaceDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['placeName'],
      child: Text(map['placeName']),
    );
  }

  Widget showSearchData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '${AppLocalizations.of(context)!.compilationdesignkey} = $_keyValue',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              '${AppLocalizations.of(context)!.compilationdesigntimespan} = $_fromDate - $_toDate',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // Note: Compilationlist now accepts SortOrder directly, so the
  // string conversion helper was removed.
}
