import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tra Cứu GCN',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildSearchWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          // Check if device is mobile (narrow screen)
          final screenWidth = MediaQuery.of(context).size.width;
          final isMobile = screenWidth < 600; // Tablet breakpoint
          if (isMobile) {
            // Mobile layout: TextField and vertical buttons in same row
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 3,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.search),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Vertical buttons on the right
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImageButton(context),
                    const SizedBox(height: 4),
                    _buildQRButton(context),
                    const SizedBox(height: 4),
                    _buildSendButton(context),
                  ],
                ),
              ],
            );
          } else {
            // Large screen layout: TextField and buttons in same row
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 1,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImageButton(context),
                    const SizedBox(width: 8),
                    _buildQRButton(context),
                    const SizedBox(width: 8),
                    _buildSendButton(context),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildImageButton(BuildContext context) {
    return Tooltip(
      message: 'Chọn ảnh từ thư viện',
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng chọn ảnh sẽ được thêm vào!'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.image, size: 18, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildQRButton(BuildContext context) {
    return Tooltip(
      message: 'Quét mã QR',
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng quét QR sẽ được thêm vào!'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.qr_code_scanner, size: 18, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Tooltip(
      message: 'Gửi yêu cầu tra cứu',
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng tìm kiếm sẽ được thêm vào!'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.send, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra Cứu GCN'),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Show menu drawer or menu options
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.red),
                      title: const Text('Trang chủ'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.search, color: Colors.red),
                      title: const Text('Tra cứu'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history, color: Colors.red),
                      title: const Text('Lịch sử tra cứu'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.red),
                      title: const Text('Cài đặt'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Về chúng tôi',
            onPressed: () {
              // Show about dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Về ứng dụng'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tra Cứu GCN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Phiên bản: 1.0.0'),
                      SizedBox(height: 8),
                      Text('Tra cứu thông tin Giấy Chứng Nhận'),
                      SizedBox(height: 8),
                      Text('© 2025 - vpdkbacninh.vn | haihv.vn'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              // Show logout confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text(
                    'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Add logout logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã đăng xuất thành công!'),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover, // Cover the entire container
            alignment: Alignment.center, // Center the image
            opacity: 0.8, // Make background more visible
          ),
        ),
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TRA CỨU THÔNG TIN',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'GIẤY CHỨNG NHẬN',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isSmallScreen = screenWidth < 600;

                        return Text(
                          isSmallScreen
                              ? 'QUYỀN SỬ DỤNG ĐẤT,\nQUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT'
                              : 'QUYỀN SỬ DỤNG ĐẤT, QUYỀN SỞ HỮU TÀI SẢN GẮN LIỀN VỚI ĐẤT',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Fixed search widget at bottom
            _buildSearchWidget(),
          ],
        ),
      ),
    );
  }
}
