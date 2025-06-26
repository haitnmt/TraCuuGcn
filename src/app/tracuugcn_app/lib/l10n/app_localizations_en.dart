// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Certificate Information';

  @override
  String get appVersion => 'Version: 1.0.0';

  @override
  String get appDescription => 'Certificate Information Lookup';

  @override
  String get copyright => '© 2025 - vpdkbacninh.vn | haihv.vn';

  @override
  String get searchHintText =>
      'Enter QR code, barcode, serial number or certificate number!';

  @override
  String get mobileSearchHintText => 'Enter lookup information!';

  @override
  String get helperText =>
      'QR Code, Barcode, Serial Number or Certificate Number';

  @override
  String get imageFeatureMessage => 'Image selection feature will be added!';

  @override
  String get qrFeatureMessage => 'QR scanning feature will be added!';

  @override
  String get searchFeatureMessage => 'Search feature will be added!';

  @override
  String get logoutSuccessMessage => 'Logged out successfully!';

  @override
  String get helpDialogTitle => 'Lookup Guide';

  @override
  String get aboutDialogTitle => 'About';

  @override
  String get logoutDialogTitle => 'Confirm Logout';

  @override
  String get languageDialogTitle => 'Select Language';

  @override
  String get imageTooltip => 'Select image from gallery';

  @override
  String get qrTooltip => 'Scan QR code';

  @override
  String get sendTooltip => 'Send lookup request';

  @override
  String get helpTooltip => 'Input guide';

  @override
  String get aboutTooltip => 'About us';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get homeMenuItem => 'Home';

  @override
  String get searchMenuItem => 'Search';

  @override
  String get historyMenuItem => 'Search History';

  @override
  String get settingsMenuItem => 'Settings';

  @override
  String get languageMenuItem => 'Language';

  @override
  String get closeButton => 'Close';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get logoutButton => 'Logout';

  @override
  String get understoodButton => 'Understood';

  @override
  String get selectButton => 'Select';

  @override
  String get helpIntroText =>
      'You can search using one of the following information:';

  @override
  String get helpQrText => '🔍 QR Code:';

  @override
  String get helpQrDescription => '   • Scan directly from certificate';

  @override
  String get helpBarcodeText => '📱 Barcode:';

  @override
  String get helpBarcodeDescription =>
      '   • Numbers below barcode on certificate';

  @override
  String get helpSerialText => '🔢 Serial Number:';

  @override
  String get helpSerialDescription => '   • Serial number on certificate';

  @override
  String get helpSerialExample => '   • Example: BN-001234567';

  @override
  String get helpGcnText => '📄 Certificate Number:';

  @override
  String get helpGcnDescription => '   • Certificate ID on document';

  @override
  String get helpGcnExample => '   • Example: 27-T-123456789';

  @override
  String get helpNoteText =>
      'Note: Only need to enter one of the above information to search.';

  @override
  String get mainTitle1 => 'LOOK UP INFORMATION';

  @override
  String get mainTitle2 => 'CERTIFICATE';

  @override
  String get mainSubtitle =>
      'LAND USE RIGHTS, OWNERSHIP OF ASSETS ATTACHED TO LAND';

  @override
  String get mainSubtitleMobile =>
      'LAND USE RIGHTS,\nOWNERSHIP OF ASSETS ATTACHED TO LAND';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to logout from the application?';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get minutesAgo => 'minutes ago';

  @override
  String get justNow => 'Just now';

  @override
  String get daysAgo => 'days ago';

  @override
  String get loginButton => 'Login';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginSSOButton => 'SSO Login';

  @override
  String get loginInProgress => 'Logging in...';

  @override
  String get loginFailed => 'Login failed. Please try again.';

  @override
  String loginError(String error) {
    return 'Login error: $error';
  }

  @override
  String logoutError(String error) {
    return 'Logout error: $error';
  }

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get loginFooterText => 'Use your SSO account to login';

  @override
  String get checkAuthStatusButton => 'Check authentication status';

  @override
  String get defaultUserName => 'User';

  @override
  String get emailLabel => 'Email';

  @override
  String get roleLabel => 'Role';

  @override
  String get lastLoginLabel => 'Last login';
}
