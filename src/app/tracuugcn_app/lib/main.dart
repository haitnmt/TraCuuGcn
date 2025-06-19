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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showHelperText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showHelperText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchWidget() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.95,
        ), // Semi-transparent background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Builder(
        builder: (context) {
          // Check if device is mobile (narrow screen)
          final screenWidth = MediaQuery.of(context).size.width;
          final isMobile = screenWidth < 600; // Tablet breakpoint
          if (isMobile) {
            // Mobile layout: TextField above, buttons below on the right
            return Column(
              children: [
                TextField(
                  controller: _searchController,
                  maxLines: null, // Auto-expand
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Nhập thông tin tra cứu!',
                    prefixIcon: const Icon(Icons.search, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Help button on left, action buttons on right for mobile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMobileHelpButton(context),
                    Row(
                      children: [
                        _buildMobileImageButton(context),
                        const SizedBox(width: 6),
                        _buildMobileQRButton(context),
                        const SizedBox(width: 6),
                        _buildMobileSendButton(context),
                      ],
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Large screen layout: TextField and buttons in same row
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        maxLines: null, // Auto-expand
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText:
                              'Nhập thông tin mã Qr, mã vạch, số phát hành (Serial) hoặc mã Giấy chứng nhận!',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.red,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
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
                ),
                // Helper text for large screens when text is entered
                if (_showHelperText) ...[
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        'ℹ️ Mã QR, Mã vạch, Số phát hành (Serial) hoặc Mã Giấy chứng nhận',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
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

  // Mobile-specific buttons with smaller icons
  Widget _buildMobileImageButton(BuildContext context) {
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(Icons.image, size: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildMobileQRButton(BuildContext context) {
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(Icons.qr_code_scanner, size: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildMobileSendButton(BuildContext context) {
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.send, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMobileHelpButton(BuildContext context) {
    return Tooltip(
      message: 'Hướng dẫn nhập thông tin',
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hướng dẫn tra cứu'),
                ],
              ),
              content: const SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn có thể tra cứu bằng một trong các thông tin sau:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text('🔍 Mã QR Code:'),
                    Text(
                      '   • Quét trực tiếp từ Giấy chứng nhận',
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      '   • Nhập chuỗi ký tự của mã QR khi quét bằng ứng dụng khác',
                      style: TextStyle(fontSize: 13),
                    ),

                    SizedBox(height: 8),
                    Text('📱 Mã vạch (Barcode):'),
                    Text(
                      '   • Quét trực tiếp từ Giấy chứng nhận',
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      '   • Nhập dãy số phía dưới mã vạch',
                      style: TextStyle(fontSize: 13),
                    ),

                    SizedBox(height: 8),
                    Text('🔢 Số phát hành (Serial):'),
                    Text(
                      '   • Số sê-ri ghi trên Giấy chứng nhận',
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      '   • Ví dụ: AA 01234567',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('📄 Mã Giấy chứng nhận:'),
                    Text(
                      '   • Mã GCN phía dưới mã QR',
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      '   • Ví dụ: 27-T-123456789',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lưu ý: Chỉ cần nhập một trong các thông tin trên để tra cứu.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Đã hiểu',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Icon(
            Icons.help_outline,
            size: 16,
            color: Colors.blue.shade600,
          ),
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
            fit: BoxFit.cover,
            alignment: Alignment.center,
            opacity: 0.8,
          ),
        ),
        child: Stack(
          children: [
            // Main content area
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TRA CỨU THÔNG TIN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'GIẤY CHỨNG NHẬN',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
            // Floating search widget positioned at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSearchWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
