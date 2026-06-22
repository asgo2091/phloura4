import 'package:flutter/material.dart';
import 'package:phloura/l10n/app_localizations.dart';
import 'generic_dialog.dart';

Future<void> proalreadyBought(BuildContext context, String text) {
  return showGenericDialog<bool>(
    context: context,
    title: AppLocalizations.of(context)!.proboughttitle,
    content: AppLocalizations.of(context)!.proboughtcontent,
    optionsBuilder: () => {
      AppLocalizations.of(context)!.proboughtconfirm: false,
    },
  );
}
