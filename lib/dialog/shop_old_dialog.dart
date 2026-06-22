import 'package:flutter/material.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'generic_dialog.dart';

Future<bool> shopOldDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: AppLocalizations.of(context)!.shopdialogappbartitle,
    content: AppLocalizations.of(context)!.shopdialogtext,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.quitbutton: false,
      AppLocalizations.of(context)!.yesbutton: true,
    },
  ).then((value) => value ?? false);
}
