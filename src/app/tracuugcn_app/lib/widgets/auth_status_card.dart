import 'package:flutter/material.dart';

class AuthStatusCard extends StatelessWidget {
  final String status;
  final String platform;
  final bool isLoading;

  const AuthStatusCard({
    super.key,
    required this.status,
    required this.platform,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _getStatusColor(),
                  size: 24.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Trạng thái xác thực',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: _getStatusColor().withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                      ),
                    )
                  else
                    Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 20.0,
                    ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  _getPlatformIcon(),
                  size: 16.0,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Nền tảng: $platform',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isLoading) return Colors.orange;
    if (status.contains('Đã đăng nhập')) return Colors.green;
    if (status.contains('Lỗi')) return Colors.red;
    return Colors.grey;
  }

  IconData _getStatusIcon() {
    if (status.contains('Đã đăng nhập')) return Icons.check_circle;
    if (status.contains('Lỗi')) return Icons.error;
    return Icons.info;
  }

  IconData _getPlatformIcon() {
    switch (platform.toLowerCase()) {
      case 'windows':
        return Icons.desktop_windows;
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.computer;
      default:
        return Icons.device_unknown;
    }
  }
}
