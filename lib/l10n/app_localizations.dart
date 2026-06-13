import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In nl, this message translates to:
  /// **'KINS Fleet Chauffeur'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In nl, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In nl, this message translates to:
  /// **'Profiel'**
  String get navProfile;

  /// No description provided for @splashChauffeur.
  ///
  /// In nl, this message translates to:
  /// **'Chauffeur'**
  String get splashChauffeur;

  /// No description provided for @loginWelcome.
  ///
  /// In nl, this message translates to:
  /// **'Welkom terug'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Log in met uw chauffeuraccount'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In nl, this message translates to:
  /// **'E-mailadres'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord'**
  String get loginPassword;

  /// No description provided for @loginForgot.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord vergeten?'**
  String get loginForgot;

  /// No description provided for @loginSubmit.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get loginSubmit;

  /// No description provided for @loginBusy.
  ///
  /// In nl, this message translates to:
  /// **'Bezig met inloggen…'**
  String get loginBusy;

  /// No description provided for @forgotTitle.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord vergeten'**
  String get forgotTitle;

  /// No description provided for @forgotResetTitle.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord resetten'**
  String get forgotResetTitle;

  /// No description provided for @forgotEmailSentTitle.
  ///
  /// In nl, this message translates to:
  /// **'E-mail verzonden'**
  String get forgotEmailSentTitle;

  /// No description provided for @forgotEmailSentBody.
  ///
  /// In nl, this message translates to:
  /// **'Controleer uw inbox voor instructies om uw wachtwoord te resetten.'**
  String get forgotEmailSentBody;

  /// No description provided for @forgotInstructions.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw e-mailadres in. U ontvangt een link om uw wachtwoord te resetten.'**
  String get forgotInstructions;

  /// No description provided for @forgotSend.
  ///
  /// In nl, this message translates to:
  /// **'Versturen'**
  String get forgotSend;

  /// No description provided for @forgotBack.
  ///
  /// In nl, this message translates to:
  /// **'Terug naar inloggen'**
  String get forgotBack;

  /// No description provided for @forgotBusy.
  ///
  /// In nl, this message translates to:
  /// **'Bezig met verzenden…'**
  String get forgotBusy;

  /// No description provided for @dashboardTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardHello.
  ///
  /// In nl, this message translates to:
  /// **'Hallo, {name}'**
  String dashboardHello(String name);

  /// No description provided for @dashboardShiftsToday.
  ///
  /// In nl, this message translates to:
  /// **'Diensten vandaag'**
  String get dashboardShiftsToday;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In nl, this message translates to:
  /// **'Snelle acties'**
  String get dashboardQuickActions;

  /// No description provided for @quickMyShifts.
  ///
  /// In nl, this message translates to:
  /// **'Mijn diensten'**
  String get quickMyShifts;

  /// No description provided for @quickPhotos.
  ///
  /// In nl, this message translates to:
  /// **'Foto\'s'**
  String get quickPhotos;

  /// No description provided for @quickHandover.
  ///
  /// In nl, this message translates to:
  /// **'Overdracht'**
  String get quickHandover;

  /// No description provided for @quickDamage.
  ///
  /// In nl, this message translates to:
  /// **'Schade melden'**
  String get quickDamage;

  /// No description provided for @profileTitle.
  ///
  /// In nl, this message translates to:
  /// **'Profiel'**
  String get profileTitle;

  /// No description provided for @profileEmail.
  ///
  /// In nl, this message translates to:
  /// **'E-mail'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In nl, this message translates to:
  /// **'Telefoon'**
  String get profilePhone;

  /// No description provided for @profileDepartment.
  ///
  /// In nl, this message translates to:
  /// **'Afdeling'**
  String get profileDepartment;

  /// No description provided for @profileStatus.
  ///
  /// In nl, this message translates to:
  /// **'Status'**
  String get profileStatus;

  /// No description provided for @profileLogout.
  ///
  /// In nl, this message translates to:
  /// **'Uitloggen'**
  String get profileLogout;

  /// No description provided for @settingsLanguage.
  ///
  /// In nl, this message translates to:
  /// **'Taal'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageNl.
  ///
  /// In nl, this message translates to:
  /// **'Nederlands'**
  String get settingsLanguageNl;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In nl, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @shiftsTitle.
  ///
  /// In nl, this message translates to:
  /// **'Mijn diensten'**
  String get shiftsTitle;

  /// No description provided for @shiftsLoading.
  ///
  /// In nl, this message translates to:
  /// **'Diensten laden…'**
  String get shiftsLoading;

  /// No description provided for @shiftsEmpty.
  ///
  /// In nl, this message translates to:
  /// **'Geen diensten ingepland'**
  String get shiftsEmpty;

  /// No description provided for @shiftsEmptySubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Er staan geen diensten voor u gepland vanaf vandaag.'**
  String get shiftsEmptySubtitle;

  /// No description provided for @shiftsUpcoming.
  ///
  /// In nl, this message translates to:
  /// **'Vandaag en komende diensten'**
  String get shiftsUpcoming;

  /// No description provided for @shiftDetailTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dienstdetails'**
  String get shiftDetailTitle;

  /// No description provided for @shiftNotFound.
  ///
  /// In nl, this message translates to:
  /// **'Dienst niet gevonden.'**
  String get shiftNotFound;

  /// No description provided for @shiftAccessDenied.
  ///
  /// In nl, this message translates to:
  /// **'U heeft geen toegang tot deze dienst.'**
  String get shiftAccessDenied;

  /// No description provided for @shiftLoadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Dienst laden mislukt. Probeer het opnieuw.'**
  String get shiftLoadFailed;

  /// No description provided for @shiftSectionService.
  ///
  /// In nl, this message translates to:
  /// **'Dienst'**
  String get shiftSectionService;

  /// No description provided for @shiftSectionBus.
  ///
  /// In nl, this message translates to:
  /// **'Bus'**
  String get shiftSectionBus;

  /// No description provided for @labelDate.
  ///
  /// In nl, this message translates to:
  /// **'Datum'**
  String get labelDate;

  /// No description provided for @labelTime.
  ///
  /// In nl, this message translates to:
  /// **'Tijd'**
  String get labelTime;

  /// No description provided for @labelDepartment.
  ///
  /// In nl, this message translates to:
  /// **'Afdeling'**
  String get labelDepartment;

  /// No description provided for @labelDriver.
  ///
  /// In nl, this message translates to:
  /// **'Chauffeur'**
  String get labelDriver;

  /// No description provided for @labelNotes.
  ///
  /// In nl, this message translates to:
  /// **'Notities'**
  String get labelNotes;

  /// No description provided for @labelBusNumber.
  ///
  /// In nl, this message translates to:
  /// **'Busnummer'**
  String get labelBusNumber;

  /// No description provided for @labelLicensePlate.
  ///
  /// In nl, this message translates to:
  /// **'Kenteken'**
  String get labelLicensePlate;

  /// No description provided for @labelBrandModel.
  ///
  /// In nl, this message translates to:
  /// **'Merk / model'**
  String get labelBrandModel;

  /// No description provided for @labelYear.
  ///
  /// In nl, this message translates to:
  /// **'Bouwjaar'**
  String get labelYear;

  /// No description provided for @labelStatus.
  ///
  /// In nl, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @busLine.
  ///
  /// In nl, this message translates to:
  /// **'Bus {number} · {plate}'**
  String busLine(String number, String plate);

  /// No description provided for @modulePhotos.
  ///
  /// In nl, this message translates to:
  /// **'Busfoto\'s'**
  String get modulePhotos;

  /// No description provided for @moduleHandovers.
  ///
  /// In nl, this message translates to:
  /// **'Overdrachten'**
  String get moduleHandovers;

  /// No description provided for @moduleDamage.
  ///
  /// In nl, this message translates to:
  /// **'Schade melden'**
  String get moduleDamage;

  /// No description provided for @moduleComingSoon.
  ///
  /// In nl, this message translates to:
  /// **'{title} komt binnenkort'**
  String moduleComingSoon(String title);

  /// No description provided for @moduleComingSoonSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Module {module} wordt na test van de vorige module gebouwd.'**
  String moduleComingSoonSubtitle(int module);

  /// No description provided for @pageNotFound.
  ///
  /// In nl, this message translates to:
  /// **'Pagina niet gevonden: {uri}'**
  String pageNotFound(String uri);

  /// No description provided for @emptyValue.
  ///
  /// In nl, this message translates to:
  /// **'—'**
  String get emptyValue;

  /// No description provided for @errorLoadShifts.
  ///
  /// In nl, this message translates to:
  /// **'Diensten laden mislukt. Controleer uw verbinding en probeer opnieuw.'**
  String get errorLoadShifts;

  /// No description provided for @errorLoadDashboard.
  ///
  /// In nl, this message translates to:
  /// **'Diensten laden mislukt. Controleer uw verbinding en probeer opnieuw.'**
  String get errorLoadDashboard;

  /// No description provided for @errorAdminApp.
  ///
  /// In nl, this message translates to:
  /// **'Dit account is voor de beheerders-app. Gebruik de KINS Fleet web-app.'**
  String get errorAdminApp;

  /// No description provided for @errorInactiveAccount.
  ///
  /// In nl, this message translates to:
  /// **'Uw account is niet actief. Neem contact op met een beheerder.'**
  String get errorInactiveAccount;

  /// No description provided for @errorMissingProfile.
  ///
  /// In nl, this message translates to:
  /// **'Geen gebruikersprofiel gevonden. Neem contact op met een beheerder.'**
  String get errorMissingProfile;

  /// No description provided for @errorMissingDriver.
  ///
  /// In nl, this message translates to:
  /// **'Chauffeurprofiel niet gevonden. Neem contact op met een beheerder.'**
  String get errorMissingDriver;

  /// No description provided for @errorMissingDriverLink.
  ///
  /// In nl, this message translates to:
  /// **'Geen chauffeur gekoppeld aan dit account. Neem contact op met een beheerder.'**
  String get errorMissingDriverLink;

  /// No description provided for @errorSignInFailed.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen mislukt. Probeer het opnieuw.'**
  String get errorSignInFailed;

  /// No description provided for @errorNetwork.
  ///
  /// In nl, this message translates to:
  /// **'Netwerkfout. Controleer uw verbinding en probeer opnieuw.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In nl, this message translates to:
  /// **'Voer een geldig e-mailadres in.'**
  String get errorInvalidEmail;

  /// No description provided for @errorUserDisabled.
  ///
  /// In nl, this message translates to:
  /// **'Dit account is uitgeschakeld. Neem contact op met een beheerder.'**
  String get errorUserDisabled;

  /// No description provided for @errorWrongCredentials.
  ///
  /// In nl, this message translates to:
  /// **'Onjuist e-mailadres of wachtwoord.'**
  String get errorWrongCredentials;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In nl, this message translates to:
  /// **'Te veel pogingen. Probeer het over een paar minuten opnieuw.'**
  String get errorTooManyRequests;

  /// No description provided for @errorMissingPassword.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw wachtwoord in.'**
  String get errorMissingPassword;

  /// No description provided for @errorGeneric.
  ///
  /// In nl, this message translates to:
  /// **'Er is iets misgegaan. Probeer het opnieuw.'**
  String get errorGeneric;

  /// No description provided for @validationEmailRequired.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw e-mailadres in.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In nl, this message translates to:
  /// **'Voer een geldig e-mailadres in.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw wachtwoord in.'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord moet minimaal 6 tekens bevatten.'**
  String get validationPasswordMinLength;

  /// No description provided for @validationRequired.
  ///
  /// In nl, this message translates to:
  /// **'{label} is verplicht.'**
  String validationRequired(String label);

  /// No description provided for @statusActive.
  ///
  /// In nl, this message translates to:
  /// **'Actief'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In nl, this message translates to:
  /// **'Inactief'**
  String get statusInactive;

  /// No description provided for @statusUnavailable.
  ///
  /// In nl, this message translates to:
  /// **'Niet beschikbaar'**
  String get statusUnavailable;

  /// No description provided for @statusAvailable.
  ///
  /// In nl, this message translates to:
  /// **'Beschikbaar'**
  String get statusAvailable;

  /// No description provided for @shiftScheduled.
  ///
  /// In nl, this message translates to:
  /// **'Ingepland'**
  String get shiftScheduled;

  /// No description provided for @shiftCompleted.
  ///
  /// In nl, this message translates to:
  /// **'Voltooid'**
  String get shiftCompleted;

  /// No description provided for @shiftCancelled.
  ///
  /// In nl, this message translates to:
  /// **'Geannuleerd'**
  String get shiftCancelled;

  /// No description provided for @damageReported.
  ///
  /// In nl, this message translates to:
  /// **'Gemeld'**
  String get damageReported;

  /// No description provided for @damageConfirmed.
  ///
  /// In nl, this message translates to:
  /// **'Bevestigd'**
  String get damageConfirmed;

  /// No description provided for @damageRepaired.
  ///
  /// In nl, this message translates to:
  /// **'Gerepareerd'**
  String get damageRepaired;

  /// No description provided for @severityLow.
  ///
  /// In nl, this message translates to:
  /// **'Laag'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In nl, this message translates to:
  /// **'Gemiddeld'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In nl, this message translates to:
  /// **'Hoog'**
  String get severityHigh;

  /// No description provided for @photosTitle.
  ///
  /// In nl, this message translates to:
  /// **'Busfoto\'s'**
  String get photosTitle;

  /// No description provided for @photosLoading.
  ///
  /// In nl, this message translates to:
  /// **'Foto\'s laden…'**
  String get photosLoading;

  /// No description provided for @photosEmpty.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen foto\'s geüpload'**
  String get photosEmpty;

  /// No description provided for @photosEmptySubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Maak een foto of kies er een uit uw galerij.'**
  String get photosEmptySubtitle;

  /// No description provided for @photosSelectBus.
  ///
  /// In nl, this message translates to:
  /// **'Bus'**
  String get photosSelectBus;

  /// No description provided for @photosSelectDate.
  ///
  /// In nl, this message translates to:
  /// **'Datum'**
  String get photosSelectDate;

  /// No description provided for @photosNotes.
  ///
  /// In nl, this message translates to:
  /// **'Notities (optioneel)'**
  String get photosNotes;

  /// No description provided for @photosTakePhoto.
  ///
  /// In nl, this message translates to:
  /// **'Camera'**
  String get photosTakePhoto;

  /// No description provided for @photosChooseGallery.
  ///
  /// In nl, this message translates to:
  /// **'Galerij'**
  String get photosChooseGallery;

  /// No description provided for @photosUploading.
  ///
  /// In nl, this message translates to:
  /// **'Uploaden… {percent}%'**
  String photosUploading(int percent);

  /// No description provided for @photosUploadSuccess.
  ///
  /// In nl, this message translates to:
  /// **'Foto succesvol geüpload.'**
  String get photosUploadSuccess;

  /// No description provided for @photosFromTodayShifts.
  ///
  /// In nl, this message translates to:
  /// **'Bussen van vandaag'**
  String get photosFromTodayShifts;

  /// No description provided for @photosAllActiveBuses.
  ///
  /// In nl, this message translates to:
  /// **'Overige actieve bussen'**
  String get photosAllActiveBuses;

  /// No description provided for @photosSelectBusHint.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer een bus'**
  String get photosSelectBusHint;

  /// No description provided for @photosMyUploads.
  ///
  /// In nl, this message translates to:
  /// **'Mijn uploads'**
  String get photosMyUploads;

  /// No description provided for @errorLoadPhotos.
  ///
  /// In nl, this message translates to:
  /// **'Foto\'s laden mislukt. Controleer uw verbinding en probeer opnieuw.'**
  String get errorLoadPhotos;

  /// No description provided for @errorImageKitNotConfigured.
  ///
  /// In nl, this message translates to:
  /// **'ImageKit is niet geconfigureerd. Voeg IMAGEKIT-sleutels toe aan .env.json.'**
  String get errorImageKitNotConfigured;

  /// No description provided for @errorPhotoFileTooLarge.
  ///
  /// In nl, this message translates to:
  /// **'Bestand is te groot. Maximum is 10 MB.'**
  String get errorPhotoFileTooLarge;

  /// No description provided for @errorPhotoInvalidType.
  ///
  /// In nl, this message translates to:
  /// **'Alleen JPG, PNG, WEBP en HEIC-afbeeldingen zijn toegestaan.'**
  String get errorPhotoInvalidType;

  /// No description provided for @errorPhotoUploadFailed.
  ///
  /// In nl, this message translates to:
  /// **'Upload mislukt. Probeer het opnieuw.'**
  String get errorPhotoUploadFailed;

  /// No description provided for @errorPhotoSaveFailed.
  ///
  /// In nl, this message translates to:
  /// **'Foto opslaan mislukt. Probeer het opnieuw.'**
  String get errorPhotoSaveFailed;

  /// No description provided for @errorPhotoBusRequired.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer een bus.'**
  String get errorPhotoBusRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
