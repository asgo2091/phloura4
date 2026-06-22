import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('sv')
  ];

  /// No description provided for @notelistappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notelistappbartitle;

  /// No description provided for @noteeditappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Register/edit note'**
  String get noteeditappbartitle;

  /// No description provided for @notewithplantsappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Notes with plants'**
  String get notewithplantsappbartitle;

  /// No description provided for @noteedithelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/NoteEditHelpen.txt'**
  String get noteedithelpfile;

  /// No description provided for @noteedithelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help edit note'**
  String get noteedithelpappbartitle;

  /// No description provided for @notelisthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/NoteListHelpen.txt'**
  String get notelisthelpfile;

  /// No description provided for @notelisthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help notes list'**
  String get notelisthelpappbartitle;

  /// No description provided for @notewithplanthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/NoteWithPlantsHelpen.txt'**
  String get notewithplanthelpfile;

  /// No description provided for @notewithplanthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help notes with plants'**
  String get notewithplanthelpappbartitle;

  /// No description provided for @noteedithintdate.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get noteedithintdate;

  /// No description provided for @noteedithintaction.
  ///
  /// In en, this message translates to:
  /// **'Action: '**
  String get noteedithintaction;

  /// No description provided for @noteedithintplace.
  ///
  /// In en, this message translates to:
  /// **'Place: '**
  String get noteedithintplace;

  /// No description provided for @noteedithintplant.
  ///
  /// In en, this message translates to:
  /// **'Plant: '**
  String get noteedithintplant;

  /// No description provided for @placelistappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get placelistappbartitle;

  /// No description provided for @placelisthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help place list'**
  String get placelisthelpappbartitle;

  /// No description provided for @placeedithelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlaceEditHelpen.txt'**
  String get placeedithelpfile;

  /// No description provided for @placeedithelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help edit place'**
  String get placeedithelpappbartitle;

  /// No description provided for @placelisthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlaceListHelpen.txt'**
  String get placelisthelpfile;

  /// No description provided for @placewithplantshelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlaceWithPlantsHelpen.txt'**
  String get placewithplantshelpfile;

  /// No description provided for @placewithplantshelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help place with plants'**
  String get placewithplantshelpappbartitle;

  /// No description provided for @placestoaddappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Places to add'**
  String get placestoaddappbartitle;

  /// No description provided for @placeeditappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Register/edit place'**
  String get placeeditappbartitle;

  /// No description provided for @placeviewhint.
  ///
  /// In en, this message translates to:
  /// **'Place: '**
  String get placeviewhint;

  /// No description provided for @compilationdesignappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Compilation design'**
  String get compilationdesignappbartitle;

  /// No description provided for @compilationdesignhelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/CompilationdesignHelpen.txt'**
  String get compilationdesignhelpfile;

  /// No description provided for @compilationdesignhelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help compilation design'**
  String get compilationdesignhelpappbartitle;

  /// No description provided for @compilationdesigndatenotset.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get compilationdesigndatenotset;

  /// No description provided for @compilationdesignvaxtkey.
  ///
  /// In en, this message translates to:
  /// **'A plant as key'**
  String get compilationdesignvaxtkey;

  /// No description provided for @compilationdesignplacekey.
  ///
  /// In en, this message translates to:
  /// **'A place as key'**
  String get compilationdesignplacekey;

  /// No description provided for @compilationdesignactionkey.
  ///
  /// In en, this message translates to:
  /// **'An action as key'**
  String get compilationdesignactionkey;

  /// No description provided for @compilationdesigntimekey.
  ///
  /// In en, this message translates to:
  /// **'Date as key'**
  String get compilationdesigntimekey;

  /// No description provided for @compilationdesignchoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get compilationdesignchoose;

  /// No description provided for @compilationdesignfromdate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get compilationdesignfromdate;

  /// No description provided for @compilationdesigntodate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get compilationdesigntodate;

  /// No description provided for @compilationdesignkey.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get compilationdesignkey;

  /// No description provided for @compilationdesigntimespan.
  ///
  /// In en, this message translates to:
  /// **'Time span'**
  String get compilationdesigntimespan;

  /// No description provided for @compilationdesignkeynameplant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get compilationdesignkeynameplant;

  /// No description provided for @compilationdesignkeynameplace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get compilationdesignkeynameplace;

  /// No description provided for @compilationdesignkeynameaction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get compilationdesignkeynameaction;

  /// No description provided for @compilationlisthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/CompilationListHelpen.txt'**
  String get compilationlisthelpfile;

  /// No description provided for @compilationlistappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Compilation list'**
  String get compilationlistappbartitle;

  /// No description provided for @compilationlisthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help compilation list'**
  String get compilationlisthelpappbartitle;

  /// No description provided for @plantlistappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get plantlistappbartitle;

  /// No description provided for @plantwitheventsappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Plant with events'**
  String get plantwitheventsappbartitle;

  /// No description provided for @plantstoaddappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Plants to add'**
  String get plantstoaddappbartitle;

  /// No description provided for @planteditappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Register/edit plant'**
  String get planteditappbartitle;

  /// No description provided for @plantedithelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlantEditHelpen.txt'**
  String get plantedithelpfile;

  /// No description provided for @plantedithelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help edit plant'**
  String get plantedithelpappbartitle;

  /// No description provided for @plantlisthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help plant list'**
  String get plantlisthelpappbartitle;

  /// No description provided for @plantlisthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlantListHelpen.txt'**
  String get plantlisthelpfile;

  /// No description provided for @plantwitheventhelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/PlantsWithEventsHelpen.txt'**
  String get plantwitheventhelpfile;

  /// No description provided for @plantwitheventhelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help plants with events'**
  String get plantwitheventhelpappbartitle;

  /// No description provided for @actionleditappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Register/edit action'**
  String get actionleditappbartitle;

  /// No description provided for @actionedithelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/actionedithelpen.txt'**
  String get actionedithelpfile;

  /// No description provided for @actionlisthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/actionlisthelpen.txt'**
  String get actionlisthelpfile;

  /// No description provided for @actionlistappbartitle.
  ///
  /// In en, this message translates to:
  /// **'List actions'**
  String get actionlistappbartitle;

  /// No description provided for @actionlisthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help list action'**
  String get actionlisthelpappbartitle;

  /// No description provided for @actioneditappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Register/edit action'**
  String get actioneditappbartitle;

  /// No description provided for @actionedithelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help edit action'**
  String get actionedithelpappbartitle;

  /// No description provided for @actionviewhint.
  ///
  /// In en, this message translates to:
  /// **'Action :'**
  String get actionviewhint;

  /// No description provided for @addplacelist.
  ///
  /// In en, this message translates to:
  /// **'Places to add'**
  String get addplacelist;

  /// No description provided for @addplantlist.
  ///
  /// In en, this message translates to:
  /// **'Plants to add'**
  String get addplantlist;

  /// No description provided for @addplacehelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/AddPlaceHelpen.txt'**
  String get addplacehelpfile;

  /// No description provided for @addplacehelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help places to add'**
  String get addplacehelpappbartitle;

  /// No description provided for @addplanthelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/AddPlantHelpen.txt'**
  String get addplanthelpfile;

  /// No description provided for @addplanthelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help plants to add'**
  String get addplanthelpappbartitle;

  /// No description provided for @menustart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get menustart;

  /// No description provided for @menunote.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get menunote;

  /// No description provided for @menuplant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get menuplant;

  /// No description provided for @menuplace.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get menuplace;

  /// No description provided for @menuaction.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get menuaction;

  /// No description provided for @menucompilations.
  ///
  /// In en, this message translates to:
  /// **'Compilations'**
  String get menucompilations;

  /// No description provided for @addplantbutton.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addplantbutton;

  /// No description provided for @addplacebutton.
  ///
  /// In en, this message translates to:
  /// **'Add place'**
  String get addplacebutton;

  /// No description provided for @buyappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Get pro version'**
  String get buyappbartitle;

  /// No description provided for @latinhint.
  ///
  /// In en, this message translates to:
  /// **'Latin name: '**
  String get latinhint;

  /// No description provided for @namehint.
  ///
  /// In en, this message translates to:
  /// **'Name: '**
  String get namehint;

  /// No description provided for @datehint.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get datehint;

  /// No description provided for @savebutton.
  ///
  /// In en, this message translates to:
  /// **'Save/OK'**
  String get savebutton;

  /// No description provided for @quitbutton.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quitbutton;

  /// No description provided for @yesbutton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesbutton;

  /// No description provided for @deletebutton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletebutton;

  /// No description provided for @gobutton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get gobutton;

  /// No description provided for @shopbutton.
  ///
  /// In en, this message translates to:
  /// **'Get full version'**
  String get shopbutton;

  /// No description provided for @appdesignbutton.
  ///
  /// In en, this message translates to:
  /// **'About the program'**
  String get appdesignbutton;

  /// No description provided for @appdesignfile.
  ///
  /// In en, this message translates to:
  /// **'assets/Appdesignen.txt'**
  String get appdesignfile;

  /// No description provided for @appdesignappbartitle.
  ///
  /// In en, this message translates to:
  /// **'App design'**
  String get appdesignappbartitle;

  /// No description provided for @buyhelpfile.
  ///
  /// In en, this message translates to:
  /// **'assets/BuyHelpen.txt'**
  String get buyhelpfile;

  /// No description provided for @buyhelpappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Help buying license'**
  String get buyhelpappbartitle;

  /// No description provided for @connecttext.
  ///
  /// In en, this message translates to:
  /// **'You can use the app for 100 days without restrictions. After that, you must purchase a license to continue.'**
  String get connecttext;

  /// No description provided for @shopdialogappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get shopdialogappbartitle;

  /// No description provided for @shopdialogtext.
  ///
  /// In en, this message translates to:
  /// **'Test time for the app has expired. Do you want to by the app?'**
  String get shopdialogtext;

  /// No description provided for @shopconnectiontext.
  ///
  /// In en, this message translates to:
  /// **'This will connect you to a site where you can purchase a license for the pro version'**
  String get shopconnectiontext;

  /// No description provided for @deletedialogtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletedialogtitle;

  /// No description provided for @deletedialogcontent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deletedialogcontent;

  /// No description provided for @deletedialogyes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get deletedialogyes;

  /// No description provided for @deletedialogno.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deletedialogno;

  /// No description provided for @missingdatedialogtitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get missingdatedialogtitle;

  /// No description provided for @missingdatedialogcontent.
  ///
  /// In en, this message translates to:
  /// **'No date set'**
  String get missingdatedialogcontent;

  /// No description provided for @missingdatedialogconfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get missingdatedialogconfirm;

  /// No description provided for @missingdatadialogtitle.
  ///
  /// In en, this message translates to:
  /// **'Input error'**
  String get missingdatadialogtitle;

  /// No description provided for @missingdatadialogcontent.
  ///
  /// In en, this message translates to:
  /// **'Data missing'**
  String get missingdatadialogcontent;

  /// No description provided for @missingdatadialogconfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get missingdatadialogconfirm;

  /// No description provided for @missingindatadialogtitle.
  ///
  /// In en, this message translates to:
  /// **'Search result'**
  String get missingindatadialogtitle;

  /// No description provided for @missingindatadialogcontent.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get missingindatadialogcontent;

  /// No description provided for @proboughttitle.
  ///
  /// In en, this message translates to:
  /// **'Full version'**
  String get proboughttitle;

  /// No description provided for @proboughtcontent.
  ///
  /// In en, this message translates to:
  /// **'You already got the full version'**
  String get proboughtcontent;

  /// No description provided for @proboughtconfirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get proboughtconfirm;

  /// No description provided for @keynameaction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get keynameaction;

  /// No description provided for @keynameplant.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get keynameplant;

  /// No description provided for @keynameplace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get keynameplace;

  /// No description provided for @keynamedate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get keynamedate;

  /// No description provided for @keynameempty.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get keynameempty;

  /// No description provided for @printappbartitle.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printappbartitle;

  /// No description provided for @printprinted.
  ///
  /// In en, this message translates to:
  /// **'Printed'**
  String get printprinted;

  /// No description provided for @printadd.
  ///
  /// In en, this message translates to:
  /// **'A diary for your crops'**
  String get printadd;

  /// No description provided for @seedshop.
  ///
  /// In en, this message translates to:
  /// **''**
  String get seedshop;

  /// No description provided for @seedshoptext.
  ///
  /// In en, this message translates to:
  /// **'Buy seeds'**
  String get seedshoptext;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'sv': return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
