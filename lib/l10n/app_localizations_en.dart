// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KINS Fleet Driver';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get splashChauffeur => 'Driver';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in with your driver account';

  @override
  String get loginEmail => 'Email address';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginForgot => 'Forgot password?';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginBusy => 'Signing in…';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotResetTitle => 'Reset password';

  @override
  String get forgotEmailSentTitle => 'Email sent';

  @override
  String get forgotEmailSentBody =>
      'Check your inbox for instructions to reset your password.';

  @override
  String get forgotInstructions =>
      'Enter your email address. You will receive a link to reset your password.';

  @override
  String get forgotSend => 'Send';

  @override
  String get forgotBack => 'Back to sign in';

  @override
  String get forgotBusy => 'Sending…';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get dashboardShiftsToday => 'Shifts today';

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get quickMyShifts => 'My shifts';

  @override
  String get quickPhotos => 'Photos';

  @override
  String get quickHandover => 'Handover';

  @override
  String get quickDamage => 'Report damage';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileDepartment => 'Department';

  @override
  String get profileStatus => 'Status';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageNl => 'Nederlands';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get shiftsTitle => 'My shifts';

  @override
  String get shiftsLoading => 'Loading shifts…';

  @override
  String get shiftsEmpty => 'No shifts scheduled';

  @override
  String get shiftsEmptySubtitle =>
      'You have no shifts scheduled from today onwards.';

  @override
  String get shiftsUpcoming => 'Today and upcoming shifts';

  @override
  String get shiftDetailTitle => 'Shift details';

  @override
  String get shiftNotFound => 'Shift not found.';

  @override
  String get shiftAccessDenied => 'You do not have access to this shift.';

  @override
  String get shiftLoadFailed => 'Failed to load shift. Please try again.';

  @override
  String get shiftSectionService => 'Shift';

  @override
  String get shiftSectionBus => 'Bus';

  @override
  String get labelDate => 'Date';

  @override
  String get labelTime => 'Time';

  @override
  String get labelDepartment => 'Department';

  @override
  String get labelDriver => 'Driver';

  @override
  String get labelNotes => 'Notes';

  @override
  String get labelBusNumber => 'Bus number';

  @override
  String get labelLicensePlate => 'License plate';

  @override
  String get labelBrandModel => 'Brand / model';

  @override
  String get labelYear => 'Year';

  @override
  String get labelStatus => 'Status';

  @override
  String busLine(String number, String plate) {
    return 'Bus $number · $plate';
  }

  @override
  String get modulePhotos => 'Bus photos';

  @override
  String get moduleHandovers => 'Handovers';

  @override
  String get moduleDamage => 'Report damage';

  @override
  String moduleComingSoon(String title) {
    return '$title coming soon';
  }

  @override
  String moduleComingSoonSubtitle(int module) {
    return 'Module $module will be built after testing the previous module.';
  }

  @override
  String pageNotFound(String uri) {
    return 'Page not found: $uri';
  }

  @override
  String get emptyValue => '—';

  @override
  String get errorLoadShifts =>
      'Failed to load shifts. Check your connection and try again.';

  @override
  String get errorLoadDashboard =>
      'Failed to load shifts. Check your connection and try again.';

  @override
  String get errorAdminApp =>
      'This account is for the admin app. Use the KINS Fleet web app.';

  @override
  String get errorInactiveAccount =>
      'Your account is not active. Contact an administrator.';

  @override
  String get errorMissingProfile =>
      'No user profile found. Contact an administrator.';

  @override
  String get errorMissingDriver =>
      'Driver profile not found. Contact an administrator.';

  @override
  String get errorMissingDriverLink =>
      'No driver linked to this account. Contact an administrator.';

  @override
  String get errorSignInFailed => 'Sign in failed. Please try again.';

  @override
  String get errorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get errorInvalidEmail => 'Enter a valid email address.';

  @override
  String get errorUserDisabled =>
      'This account is disabled. Contact an administrator.';

  @override
  String get errorWrongCredentials => 'Incorrect email address or password.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get errorMissingPassword => 'Enter your password.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get validationEmailRequired => 'Enter your email address.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Enter your password.';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 6 characters.';

  @override
  String validationRequired(String label) {
    return '$label is required.';
  }

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusUnavailable => 'Unavailable';

  @override
  String get statusAvailable => 'Available';

  @override
  String get shiftScheduled => 'Scheduled';

  @override
  String get shiftCompleted => 'Completed';

  @override
  String get shiftCancelled => 'Cancelled';

  @override
  String get damageReported => 'Reported';

  @override
  String get damageConfirmed => 'Confirmed';

  @override
  String get damageRepaired => 'Repaired';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';
}
