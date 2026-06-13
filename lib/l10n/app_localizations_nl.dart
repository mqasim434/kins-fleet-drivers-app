// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'KINS Fleet Chauffeur';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profiel';

  @override
  String get splashChauffeur => 'Chauffeur';

  @override
  String get loginWelcome => 'Welkom terug';

  @override
  String get loginSubtitle => 'Log in met uw chauffeuraccount';

  @override
  String get loginEmail => 'E-mailadres';

  @override
  String get loginPassword => 'Wachtwoord';

  @override
  String get loginForgot => 'Wachtwoord vergeten?';

  @override
  String get loginSubmit => 'Inloggen';

  @override
  String get loginBusy => 'Bezig met inloggen…';

  @override
  String get forgotTitle => 'Wachtwoord vergeten';

  @override
  String get forgotResetTitle => 'Wachtwoord resetten';

  @override
  String get forgotEmailSentTitle => 'E-mail verzonden';

  @override
  String get forgotEmailSentBody =>
      'Controleer uw inbox voor instructies om uw wachtwoord te resetten.';

  @override
  String get forgotInstructions =>
      'Voer uw e-mailadres in. U ontvangt een link om uw wachtwoord te resetten.';

  @override
  String get forgotSend => 'Versturen';

  @override
  String get forgotBack => 'Terug naar inloggen';

  @override
  String get forgotBusy => 'Bezig met verzenden…';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardHello(String name) {
    return 'Hallo, $name';
  }

  @override
  String get dashboardShiftsToday => 'Diensten vandaag';

  @override
  String get dashboardQuickActions => 'Snelle acties';

  @override
  String get quickMyShifts => 'Mijn diensten';

  @override
  String get quickPhotos => 'Foto\'s';

  @override
  String get quickHandover => 'Overdracht';

  @override
  String get quickDamage => 'Schade melden';

  @override
  String get profileTitle => 'Profiel';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profilePhone => 'Telefoon';

  @override
  String get profileDepartment => 'Afdeling';

  @override
  String get profileStatus => 'Status';

  @override
  String get profileLogout => 'Uitloggen';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsLanguageNl => 'Nederlands';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get shiftsTitle => 'Mijn diensten';

  @override
  String get shiftsLoading => 'Diensten laden…';

  @override
  String get shiftsEmpty => 'Geen diensten ingepland';

  @override
  String get shiftsEmptySubtitle =>
      'Er staan geen diensten voor u gepland vanaf vandaag.';

  @override
  String get shiftsUpcoming => 'Vandaag en komende diensten';

  @override
  String get shiftDetailTitle => 'Dienstdetails';

  @override
  String get shiftNotFound => 'Dienst niet gevonden.';

  @override
  String get shiftAccessDenied => 'U heeft geen toegang tot deze dienst.';

  @override
  String get shiftLoadFailed => 'Dienst laden mislukt. Probeer het opnieuw.';

  @override
  String get shiftSectionService => 'Dienst';

  @override
  String get shiftSectionBus => 'Bus';

  @override
  String get labelDate => 'Datum';

  @override
  String get labelTime => 'Tijd';

  @override
  String get labelDepartment => 'Afdeling';

  @override
  String get labelDriver => 'Chauffeur';

  @override
  String get labelNotes => 'Notities';

  @override
  String get labelBusNumber => 'Busnummer';

  @override
  String get labelLicensePlate => 'Kenteken';

  @override
  String get labelBrandModel => 'Merk / model';

  @override
  String get labelYear => 'Bouwjaar';

  @override
  String get labelStatus => 'Status';

  @override
  String busLine(String number, String plate) {
    return 'Bus $number · $plate';
  }

  @override
  String get modulePhotos => 'Busfoto\'s';

  @override
  String get moduleHandovers => 'Overdrachten';

  @override
  String get moduleDamage => 'Schade melden';

  @override
  String moduleComingSoon(String title) {
    return '$title komt binnenkort';
  }

  @override
  String moduleComingSoonSubtitle(int module) {
    return 'Module $module wordt na test van de vorige module gebouwd.';
  }

  @override
  String pageNotFound(String uri) {
    return 'Pagina niet gevonden: $uri';
  }

  @override
  String get emptyValue => '—';

  @override
  String get errorLoadShifts =>
      'Diensten laden mislukt. Controleer uw verbinding en probeer opnieuw.';

  @override
  String get errorLoadDashboard =>
      'Diensten laden mislukt. Controleer uw verbinding en probeer opnieuw.';

  @override
  String get errorAdminApp =>
      'Dit account is voor de beheerders-app. Gebruik de KINS Fleet web-app.';

  @override
  String get errorInactiveAccount =>
      'Uw account is niet actief. Neem contact op met een beheerder.';

  @override
  String get errorMissingProfile =>
      'Geen gebruikersprofiel gevonden. Neem contact op met een beheerder.';

  @override
  String get errorMissingDriver =>
      'Chauffeurprofiel niet gevonden. Neem contact op met een beheerder.';

  @override
  String get errorMissingDriverLink =>
      'Geen chauffeur gekoppeld aan dit account. Neem contact op met een beheerder.';

  @override
  String get errorSignInFailed => 'Inloggen mislukt. Probeer het opnieuw.';

  @override
  String get errorNetwork =>
      'Netwerkfout. Controleer uw verbinding en probeer opnieuw.';

  @override
  String get errorInvalidEmail => 'Voer een geldig e-mailadres in.';

  @override
  String get errorUserDisabled =>
      'Dit account is uitgeschakeld. Neem contact op met een beheerder.';

  @override
  String get errorWrongCredentials => 'Onjuist e-mailadres of wachtwoord.';

  @override
  String get errorTooManyRequests =>
      'Te veel pogingen. Probeer het over een paar minuten opnieuw.';

  @override
  String get errorMissingPassword => 'Voer uw wachtwoord in.';

  @override
  String get errorGeneric => 'Er is iets misgegaan. Probeer het opnieuw.';

  @override
  String get validationEmailRequired => 'Voer uw e-mailadres in.';

  @override
  String get validationEmailInvalid => 'Voer een geldig e-mailadres in.';

  @override
  String get validationPasswordRequired => 'Voer uw wachtwoord in.';

  @override
  String get validationPasswordMinLength =>
      'Wachtwoord moet minimaal 6 tekens bevatten.';

  @override
  String validationRequired(String label) {
    return '$label is verplicht.';
  }

  @override
  String get statusActive => 'Actief';

  @override
  String get statusInactive => 'Inactief';

  @override
  String get statusUnavailable => 'Niet beschikbaar';

  @override
  String get statusAvailable => 'Beschikbaar';

  @override
  String get shiftScheduled => 'Ingepland';

  @override
  String get shiftCompleted => 'Voltooid';

  @override
  String get shiftCancelled => 'Geannuleerd';

  @override
  String get damageReported => 'Gemeld';

  @override
  String get damageConfirmed => 'Bevestigd';

  @override
  String get damageRepaired => 'Gerepareerd';

  @override
  String get severityLow => 'Laag';

  @override
  String get severityMedium => 'Gemiddeld';

  @override
  String get severityHigh => 'Hoog';

  @override
  String get photosTitle => 'Busfoto\'s';

  @override
  String get photosLoading => 'Foto\'s laden…';

  @override
  String get photosEmpty => 'Nog geen foto\'s geüpload';

  @override
  String get photosEmptySubtitle =>
      'Maak een foto of kies er een uit uw galerij.';

  @override
  String get photosSelectBus => 'Bus';

  @override
  String get photosSelectDate => 'Datum';

  @override
  String get photosNotes => 'Notities (optioneel)';

  @override
  String get photosTakePhoto => 'Camera';

  @override
  String get photosChooseGallery => 'Galerij';

  @override
  String photosUploading(int percent) {
    return 'Uploaden… $percent%';
  }

  @override
  String get photosUploadSuccess => 'Foto succesvol geüpload.';

  @override
  String get photosFromTodayShifts => 'Bussen van vandaag';

  @override
  String get photosAllActiveBuses => 'Overige actieve bussen';

  @override
  String get photosSelectBusHint => 'Selecteer een bus';

  @override
  String get photosMyUploads => 'Mijn uploads';

  @override
  String get errorLoadPhotos =>
      'Foto\'s laden mislukt. Controleer uw verbinding en probeer opnieuw.';

  @override
  String get errorImageKitNotConfigured =>
      'ImageKit is niet geconfigureerd. Voeg IMAGEKIT-sleutels toe aan .env.json.';

  @override
  String get errorPhotoFileTooLarge => 'Bestand is te groot. Maximum is 10 MB.';

  @override
  String get errorPhotoInvalidType =>
      'Alleen JPG, PNG, WEBP en HEIC-afbeeldingen zijn toegestaan.';

  @override
  String get errorPhotoUploadFailed => 'Upload mislukt. Probeer het opnieuw.';

  @override
  String get errorPhotoSaveFailed =>
      'Foto opslaan mislukt. Probeer het opnieuw.';

  @override
  String get errorPhotoBusRequired => 'Selecteer een bus.';
}
