import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appTitle = 'Tra Cứu GCN';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Tra cứu thông tin Giấy Chứng Nhận';
  static const String copyright = '© 2025 - vpdkbacninh.vn | haihv.vn';

  // Colors
  static const Color primaryColor = Colors.red;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color hintTextColor = Colors.grey;

  // Screen breakpoints
  static const double mobileBreakpoint = 600.0;

  // Padding and margins
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(20.0);

  // Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 20.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 18.0;
  static const double largeIconSize = 24.0;

  // Text sizes
  static const double smallTextSize = 12.0;
  static const double mediumTextSize = 13.0;
  static const double normalTextSize = 14.0;

  // Search hints and texts
  static const String searchHintText = 'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!';
  static const String mobileSearchHintText = 'Nhập thông tin tra cứu!';
  static const String helperText = 'Mã QR • Mã vạch • Số phát hành (Serial) • Mã Giấy chứng nhận';

  // Messages
  static const String imageFeatureMessage = 'Chức năng chọn ảnh sẽ được thêm vào!';
  static const String qrFeatureMessage = 'Chức năng quét QR sẽ được thêm vào!';
  static const String searchFeatureMessage = 'Chức năng tìm kiếm sẽ được thêm vào!';
  static const String logoutSuccessMessage = 'Đã đăng xuất thành công!';

  // Dialog titles
  static const String helpDialogTitle = 'Hướng dẫn tra cứu';
  static const String aboutDialogTitle = 'Về ứng dụng';
  static const String logoutDialogTitle = 'Xác nhận đăng xuất';

  // Tooltips
  static const String imageTooltip = 'Chọn ảnh từ thư viện';
  static const String qrTooltip = 'Quét mã QR';
  static const String sendTooltip = 'Gửi yêu cầu tra cứu';
  static const String helpTooltip = 'Hướng dẫn nhập thông tin';
  static const String aboutTooltip = 'Về chúng tôi';
  static const String logoutTooltip = 'Đăng xuất';

  // Menu items
  static const String homeMenuItem = 'Trang chủ';
  static const String searchMenuItem = 'Tra cứu';
  static const String historyMenuItem = 'Lịch sử tra cứu';
  static const String settingsMenuItem = 'Cài đặt';

  // Button texts
  static const String closeButton = 'Đóng';
  static const String cancelButton = 'Hủy';
  static const String logoutButton = 'Đăng xuất';
  static const String understoodButton = 'Đã hiểu';

  // Help content
  static const String helpIntroText = 'Bạn có thể tra cứu bằng một trong các thông tin sau:';
  static const String helpQrText = '🔍 Mã QR Code:';
  static const String helpQrDescription = '   • Quét trực tiếp từ giấy chứng nhận';
  static const String helpBarcodeText = '📱 Mã vạch (Barcode):';
  static const String helpBarcodeDescription = '   • Dãy số dưới mã vạch trên GCN';
  static const String helpSerialText = '🔢 Số phát hành (Serial):';
  static const String helpSerialDescription = '   • Số sê-ri ghi trên giấy chứng nhận';
  static const String helpSerialExample = '   • Ví dụ: BN-001234567';
  static const String helpGcnText = '📄 Mã Giấy chứng nhận:';
  static const String helpGcnDescription = '   • Mã số GCN ghi trên tài liệu';
  static const String helpGcnExample = '   • Ví dụ: 27-T-123456789';
  static const String helpNoteText = 'Lưu ý: Chỉ cần nhập một trong các thông tin trên để tra cứu.';

  // Main screen texts
  static const String mainTitle1 = 'TRA CỨU THÔNG TIN';
  static const String mainTitle2 = 'GIẤY CHỨNG NHẬN';
  static const String mainSubtitle = 'QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT';
  static const String mainSubtitleMobile = 'QUYỀN SỬ DỤNG ĐẤT,\nQUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT';

  // Background image
  static const String backgroundImage = 'assets/images/bg.jpg';
}
