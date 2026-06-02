import 'package:flutter/material.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'generic_dialog.dart';

Future<void> missingDateDialog(
  BuildContext context,
  //String missingdatadialogcontent,
) {
  return showGenericDialog<bool>(
    context: context,
    title: AppLocalizations.of(context)!.missingdatedialogtitle,
    content: AppLocalizations.of(context)!.missingdatedialogcontent,
    optionsBuilder: () => {AppLocalizations.of(context)!.quitbutton: true},
  ).then((value) => value ?? false);
}
