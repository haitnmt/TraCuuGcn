// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Tra cứu GCN';

  @override
  String get appVersion => 'Phiên bản: 1.0.0';

  @override
  String get appDescription => 'Tra cứu thông tin Giấy Chứng Nhận';

  @override
  String get copyright => '© 2025 - vpdkbacninh.vn | haihv.vn';

  @override
  String get searchHintText =>
      'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!';

  @override
  String get mobileSearchHintText => 'Nhập thông tin tra cứu!';

  @override
  String get helperText =>
      'Mã QR, Mã vạch, Số phát hành (Serial) hoặc Mã Giấy chứng nhận';

  @override
  String get imageFeatureMessage => 'Chức năng chọn ảnh sẽ được thêm vào!';

  @override
  String get qrFeatureMessage => 'Chức năng quét QR sẽ được thêm vào!';

  @override
  String get searchFeatureMessage => 'Chức năng tìm kiếm sẽ được thêm vào!';

  @override
  String get logoutSuccessMessage => 'Đã đăng xuất thành công!';

  @override
  String get helpDialogTitle => 'Hướng dẫn tra cứu';

  @override
  String get aboutDialogTitle => 'Về ứng dụng';

  @override
  String get logoutDialogTitle => 'Xác nhận đăng xuất';

  @override
  String get languageDialogTitle => 'Chọn ngôn ngữ';

  @override
  String get imageTooltip => 'Chọn ảnh từ thư viện';

  @override
  String get qrTooltip => 'Quét mã QR';

  @override
  String get sendTooltip => 'Gửi yêu cầu tra cứu';

  @override
  String get helpTooltip => 'Hướng dẫn nhập thông tin';

  @override
  String get aboutTooltip => 'Về chúng tôi';

  @override
  String get logoutTooltip => 'Đăng xuất';

  @override
  String get homeMenuItem => 'Trang chủ';

  @override
  String get searchMenuItem => 'Tra cứu';

  @override
  String get historyMenuItem => 'Lịch sử tra cứu';

  @override
  String get settingsMenuItem => 'Cài đặt';

  @override
  String get languageMenuItem => 'Ngôn ngữ';

  @override
  String get closeButton => 'Đóng';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get logoutButton => 'Đăng xuất';

  @override
  String get understoodButton => 'Đã hiểu';

  @override
  String get selectButton => 'Chọn';

  @override
  String get helpIntroText =>
      'Bạn có thể tra cứu bằng một trong các thông tin sau:';

  @override
  String get helpQrText => '🔍 Mã QR Code:';

  @override
  String get helpQrDescription => '   • Quét trực tiếp từ giấy chứng nhận';

  @override
  String get helpBarcodeText => '📱 Mã vạch (Barcode):';

  @override
  String get helpBarcodeDescription => '   • Dãy số dưới mã vạch trên GCN';

  @override
  String get helpSerialText => '🔢 Số phát hành (Serial):';

  @override
  String get helpSerialDescription => '   • Số sê-ri ghi trên giấy chứng nhận';

  @override
  String get helpSerialExample => '   • Ví dụ: BN-001234567';

  @override
  String get helpGcnText => '📄 Mã Giấy chứng nhận:';

  @override
  String get helpGcnDescription => '   • Mã số GCN ghi trên tài liệu';

  @override
  String get helpGcnExample => '   • Ví dụ: 27-T-123456789';

  @override
  String get helpNoteText =>
      'Lưu ý: Chỉ cần nhập một trong các thông tin trên để tra cứu.';

  @override
  String get mainTitle1 => 'TRA CỨU THÔNG TIN';

  @override
  String get mainTitle2 => 'GIẤY CHỨNG NHẬN';

  @override
  String get mainSubtitle =>
      'QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT';

  @override
  String get mainSubtitleMobile =>
      'QUYỀN SỬ DỤNG ĐẤT,\nQUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT';

  @override
  String get logoutConfirmMessage =>
      'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get clearHistory => 'Xóa lịch sử';

  @override
  String get hoursAgo => 'giờ trước';

  @override
  String get daysAgo => 'ngày trước';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginSSOButton => 'Đăng nhập SSO';

  @override
  String get loginInProgress => 'Đang đăng nhập...';

  @override
  String get loginFailed => 'Đăng nhập thất bại. Vui lòng thử lại.';

  @override
  String loginError(String error) {
    return 'Lỗi đăng nhập: $error';
  }

  @override
  String logoutError(String error) {
    return 'Lỗi đăng xuất: $error';
  }

  @override
  String get logoutSuccess => 'Đã đăng xuất thành công';

  @override
  String get loginFooterText => 'Sử dụng tài khoản SSO của bạn để đăng nhập';

  @override
  String get checkAuthStatusButton => 'Kiểm tra trạng thái đăng nhập';
}
