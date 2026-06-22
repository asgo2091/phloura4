import 'package:flutter/material.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: AppLocalizations.of(context)!.deletedialogtitle,
    content: AppLocalizations.of(context)!.deletedialogcontent,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.deletedialogno: false,
      AppLocalizations.of(context)!.deletedialogyes: true,
    },
  ).then((value) => value ?? false);
}
