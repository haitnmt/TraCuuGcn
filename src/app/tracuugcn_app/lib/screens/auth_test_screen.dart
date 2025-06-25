import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_manager.dart';
import '../auth/models/auth_user.dart';
import '../auth/desktop/auth_windows.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  late final AuthManager _authManager;
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _token;
  String _statusMessage = 'Chưa đăng nhập';

  @override
  void initState() {
    super.initState();
    _authManager = AuthManager();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isAuthenticated = await _authManager.isAuthenticated();
      if (isAuthenticated) {
        _token = await _authManager.getToken();
        
        // Get current user info (only for Windows Auth)
        if (_authManager.authProvider is WindowsAuth) {
          final windowsAuth = _authManager.authProvider as WindowsAuth;
          _currentUser = await windowsAuth.getCurrentUser();
        }
        
        setState(() {
          _statusMessage = 'Đã đăng nhập';
        });
      } else {
        setState(() {
          _statusMessage = 'Chưa đăng nhập';
          _currentUser = null;
          _token = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi kiểm tra trạng thái: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang đăng nhập...';
    });

    try {
      await _authManager.authenticate();
      await _checkAuthStatus();
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi đăng nhập: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang đăng xuất...';
    });

    try {
      await _authManager.logout();
      await _checkAuthStatus();
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi đăng xuất: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test - Windows'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng thái xác thực',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          _statusMessage.contains('Đã đăng nhập') 
                              ? Icons.check_circle 
                              : _statusMessage.contains('Lỗi')
                                  ? Icons.error
                                  : Icons.info,
                          color: _statusMessage.contains('Đã đăng nhập')
                              ? Colors.green
                              : _statusMessage.contains('Lỗi')
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusMessage.contains('Đã đăng nhập')
                                  ? Colors.green
                                  : _statusMessage.contains('Lỗi')
                                      ? Colors.red
                                      : null,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Nền tảng: ${_authManager.getCurrentPlatform()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // User Info Card
            if (_currentUser != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin người dùng',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      _buildInfoRow('Tên:', _currentUser!.fullName ?? 'N/A'),
                      _buildInfoRow('Email:', _currentUser!.email),
                      _buildInfoRow('Username:', _currentUser!.username),
                      _buildInfoRow('Vai trò:', _currentUser!.roles.join(', ')),
                      _buildInfoRow('Trạng thái:', _currentUser!.isActive ? 'Hoạt động' : 'Không hoạt động'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16.0),
            
            // Token Info Card (Debug mode only)
            if (kDebugMode && _token != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token (Debug)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SelectableText(
                          _token!.length > 100 
                              ? '${_token!.substring(0, 100)}...'
                              : _token!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Action Buttons
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: _statusMessage.contains('Đã đăng nhập') ? null : _handleLogin,
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập SSO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: !_statusMessage.contains('Đã đăng nhập') ? null : _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
              const SizedBox(height: 8.0),
              TextButton.icon(
                onPressed: _checkAuthStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.0,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
