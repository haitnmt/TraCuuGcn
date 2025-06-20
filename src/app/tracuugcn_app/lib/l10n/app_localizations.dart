import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
  ];

  /// Title of the application
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu GCN'**
  String get appTitle;

  /// Version of the application
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản: 1.0.0'**
  String get appVersion;

  /// Description of the application
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu thông tin Giấy Chứng Nhận'**
  String get appDescription;

  /// Copyright information
  ///
  /// In vi, this message translates to:
  /// **'© 2025 - vpdkbacninh.vn | haihv.vn'**
  String get copyright;

  /// Hint text for search input field
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!'**
  String get searchHintText;

  /// Hint text for mobile search input field
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin tra cứu!'**
  String get mobileSearchHintText;

  /// Helper text showing supported search types
  ///
  /// In vi, this message translates to:
  /// **'Mã QR, Mã vạch, Số phát hành (Serial) hoặc Mã Giấy chứng nhận'**
  String get helperText;

  /// Message for image selection feature
  ///
  /// In vi, this message translates to:
  /// **'Chức năng chọn ảnh sẽ được thêm vào!'**
  String get imageFeatureMessage;

  /// Message for QR scanning feature
  ///
  /// In vi, this message translates to:
  /// **'Chức năng quét QR sẽ được thêm vào!'**
  String get qrFeatureMessage;

  /// Message for search feature
  ///
  /// In vi, this message translates to:
  /// **'Chức năng tìm kiếm sẽ được thêm vào!'**
  String get searchFeatureMessage;

  /// Success message after logout
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất thành công!'**
  String get logoutSuccessMessage;

  /// Title for help dialog
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn tra cứu'**
  String get helpDialogTitle;

  /// Title for about dialog
  ///
  /// In vi, this message translates to:
  /// **'Về ứng dụng'**
  String get aboutDialogTitle;

  /// Title for logout confirmation dialog
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đăng xuất'**
  String get logoutDialogTitle;

  /// Title for language selection dialog
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get languageDialogTitle;

  /// Tooltip for image selection button
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh từ thư viện'**
  String get imageTooltip;

  /// Tooltip for QR scanning button
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get qrTooltip;

  /// Tooltip for send/search button
  ///
  /// In vi, this message translates to:
  /// **'Gửi yêu cầu tra cứu'**
  String get sendTooltip;

  /// Tooltip for help button
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn nhập thông tin'**
  String get helpTooltip;

  /// Tooltip for about button
  ///
  /// In vi, this message translates to:
  /// **'Về chúng tôi'**
  String get aboutTooltip;

  /// Tooltip for logout button
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutTooltip;

  /// Home menu item
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeMenuItem;

  /// Search menu item
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu'**
  String get searchMenuItem;

  /// History menu item
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử tra cứu'**
  String get historyMenuItem;

  /// Settings menu item
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsMenuItem;

  /// Language menu item
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageMenuItem;

  /// Close button text
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeButton;

  /// Cancel button text
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelButton;

  /// Logout button text
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutButton;

  /// Understood button text
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get understoodButton;

  /// Select button text
  ///
  /// In vi, this message translates to:
  /// **'Chọn'**
  String get selectButton;

  /// Introduction text for help guide
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể tra cứu bằng một trong các thông tin sau:'**
  String get helpIntroText;

  /// Help text for QR code lookup option
  ///
  /// In vi, this message translates to:
  /// **'🔍 Mã QR Code:'**
  String get helpQrText;

  /// Description for QR code lookup method
  ///
  /// In vi, this message translates to:
  /// **'   • Quét trực tiếp từ giấy chứng nhận'**
  String get helpQrDescription;

  /// Help text for barcode lookup option
  ///
  /// In vi, this message translates to:
  /// **'📱 Mã vạch (Barcode):'**
  String get helpBarcodeText;

  /// Description for barcode lookup method
  ///
  /// In vi, this message translates to:
  /// **'   • Dãy số dưới mã vạch trên GCN'**
  String get helpBarcodeDescription;

  /// Help text for serial number lookup option
  ///
  /// In vi, this message translates to:
  /// **'🔢 Số phát hành (Serial):'**
  String get helpSerialText;

  /// Description for serial number lookup method
  ///
  /// In vi, this message translates to:
  /// **'   • Số sê-ri ghi trên giấy chứng nhận'**
  String get helpSerialDescription;

  /// Example format for serial number
  ///
  /// In vi, this message translates to:
  /// **'   • Ví dụ: BN-001234567'**
  String get helpSerialExample;

  /// Help text for certificate number lookup option
  ///
  /// In vi, this message translates to:
  /// **'📄 Mã Giấy chứng nhận:'**
  String get helpGcnText;

  /// Description for certificate number lookup method
  ///
  /// In vi, this message translates to:
  /// **'   • Mã số GCN ghi trên tài liệu'**
  String get helpGcnDescription;

  /// Example format for certificate number
  ///
  /// In vi, this message translates to:
  /// **'   • Ví dụ: 27-T-123456789'**
  String get helpGcnExample;

  /// Note text for help guide
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý: Chỉ cần nhập một trong các thông tin trên để tra cứu.'**
  String get helpNoteText;

  /// Main title part 1
  ///
  /// In vi, this message translates to:
  /// **'TRA CỨU THÔNG TIN'**
  String get mainTitle1;

  /// Main title part 2
  ///
  /// In vi, this message translates to:
  /// **'GIẤY CHỨNG NHẬN'**
  String get mainTitle2;

  /// Main subtitle for desktop view
  ///
  /// In vi, this message translates to:
  /// **'QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT'**
  String get mainSubtitle;

  /// Main subtitle for mobile view
  ///
  /// In vi, this message translates to:
  /// **'QUYỀN SỬ DỤNG ĐẤT,\nQUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT'**
  String get mainSubtitleMobile;

  /// Logout confirmation message
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'**
  String get logoutConfirmMessage;

  /// Vietnamese language option
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// English language option
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// Clear history button text
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử'**
  String get clearHistory;

  /// Hours ago time indicator
  ///
  /// In vi, this message translates to:
  /// **'giờ trước'**
  String get hoursAgo;

  /// Days ago time indicator
  ///
  /// In vi, this message translates to:
  /// **'ngày trước'**
  String get daysAgo;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
