import 'package:flutter/material.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'generic_dialog.dart';

Future<void> missingDataDialog(BuildContext context, String text) {
  return showGenericDialog<bool>(
    context: context,
    title: AppLocalizations.of(context)!.missingdatadialogtitle,
    content: AppLocalizations.of(context)!.missingdatadialogcontent,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.missingdatadialogconfirm: false,
    },
  );
}
