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

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tra Cứu GCN'**
  String get appTitle;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// No description provided for @appDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu thông tin Giấy Chứng Nhận'**
  String get appDescription;

  /// No description provided for @copyright.
  ///
  /// In vi, this message translates to:
  /// **'© 2025 - vpdkbacninh.vn | haihv.vn'**
  String get copyright;

  /// No description provided for @searchHintText.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!'**
  String get searchHintText;

  /// No description provided for @mobileSearchHintText.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin tra cứu!'**
  String get mobileSearchHintText;

  /// No description provided for @helperText.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR • Mã vạch • Số phát hành (Serial) • Mã Giấy chứng nhận'**
  String get helperText;

  /// No description provided for @imageFeatureMessage.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng chọn ảnh sẽ được thêm vào!'**
  String get imageFeatureMessage;

  /// No description provided for @qrFeatureMessage.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng quét QR sẽ được thêm vào!'**
  String get qrFeatureMessage;

  /// No description provided for @searchFeatureMessage.
  ///
  /// In vi, this message translates to:
  /// **'Chức năng tìm kiếm sẽ được thêm vào!'**
  String get searchFeatureMessage;

  /// No description provided for @logoutSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất thành công!'**
  String get logoutSuccessMessage;

  /// No description provided for @helpDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn tra cứu'**
  String get helpDialogTitle;

  /// No description provided for @aboutDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Về ứng dụng'**
  String get aboutDialogTitle;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đăng xuất'**
  String get logoutDialogTitle;

  /// No description provided for @languageDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get languageDialogTitle;

  /// No description provided for @imageTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh từ thư viện'**
  String get imageTooltip;

  /// No description provided for @qrTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get qrTooltip;

  /// No description provided for @sendTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Gửi yêu cầu tra cứu'**
  String get sendTooltip;

  /// No description provided for @helpTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dẫn nhập thông tin'**
  String get helpTooltip;

  /// No description provided for @aboutTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Về chúng tôi'**
  String get aboutTooltip;

  /// No description provided for @logoutTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutTooltip;

  /// No description provided for @homeMenuItem.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeMenuItem;

  /// No description provided for @searchMenuItem.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu'**
  String get searchMenuItem;

  /// No description provided for @historyMenuItem.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử tra cứu'**
  String get historyMenuItem;

  /// No description provided for @settingsMenuItem.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsMenuItem;

  /// No description provided for @languageMenuItem.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageMenuItem;

  /// No description provided for @closeButton.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeButton;

  /// No description provided for @cancelButton.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelButton;

  /// No description provided for @logoutButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutButton;

  /// No description provided for @understoodButton.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get understoodButton;

  /// No description provided for @selectButton.
  ///
  /// In vi, this message translates to:
  /// **'Chọn'**
  String get selectButton;

  /// No description provided for @helpIntroText.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể tra cứu bằng một trong các thông tin sau:'**
  String get helpIntroText;

  /// No description provided for @helpQrText.
  ///
  /// In vi, this message translates to:
  /// **'🔍 Mã QR Code:'**
  String get helpQrText;

  /// No description provided for @helpQrDescription.
  ///
  /// In vi, this message translates to:
  /// **'   • Quét trực tiếp từ giấy chứng nhận'**
  String get helpQrDescription;

  /// No description provided for @helpBarcodeText.
  ///
  /// In vi, this message translates to:
  /// **'📱 Mã vạch (Barcode):'**
  String get helpBarcodeText;

  /// No description provided for @helpBarcodeDescription.
  ///
  /// In vi, this message translates to:
  /// **'   • Dãy số dưới mã vạch trên GCN'**
  String get helpBarcodeDescription;

  /// No description provided for @helpSerialText.
  ///
  /// In vi, this message translates to:
  /// **'🔢 Số phát hành (Serial):'**
  String get helpSerialText;

  /// No description provided for @helpSerialDescription.
  ///
  /// In vi, this message translates to:
  /// **'   • Số sê-ri ghi trên giấy chứng nhận'**
  String get helpSerialDescription;

  /// No description provided for @helpSerialExample.
  ///
  /// In vi, this message translates to:
  /// **'   • Ví dụ: BN-001234567'**
  String get helpSerialExample;

  /// No description provided for @helpGcnText.
  ///
  /// In vi, this message translates to:
  /// **'📄 Mã Giấy chứng nhận:'**
  String get helpGcnText;

  /// No description provided for @helpGcnDescription.
  ///
  /// In vi, this message translates to:
  /// **'   • Mã số GCN ghi trên tài liệu'**
  String get helpGcnDescription;

  /// No description provided for @helpGcnExample.
  ///
  /// In vi, this message translates to:
  /// **'   • Ví dụ: 27-T-123456789'**
  String get helpGcnExample;

  /// No description provided for @helpNoteText.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý: Chỉ cần nhập một trong các thông tin trên để tra cứu.'**
  String get helpNoteText;

  /// No description provided for @mainTitle1.
  ///
  /// In vi, this message translates to:
  /// **'TRA CỨU THÔNG TIN'**
  String get mainTitle1;

  /// No description provided for @mainTitle2.
  ///
  /// In vi, this message translates to:
  /// **'GIẤY CHỨNG NHẬN'**
  String get mainTitle2;

  /// No description provided for @mainSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT'**
  String get mainSubtitle;

  /// No description provided for @mainSubtitleMobile.
  ///
  /// In vi, this message translates to:
  /// **'QUYỀN SỬ DỤNG ĐẤT,\nQUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT'**
  String get mainSubtitleMobile;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'**
  String get logoutConfirmMessage;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;
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
