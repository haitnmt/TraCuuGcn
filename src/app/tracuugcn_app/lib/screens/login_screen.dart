import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthManager _authManager;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _authManager = AuthManager();
  }

  Future<void> _handleKeycloakLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authManager.authenticate();
      
      // Check if authentication was successful
      final isAuthenticated = await _authManager.isAuthenticated();
      if (isAuthenticated) {
        // Navigate to home screen or wherever you want to go after login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi đăng nhập: ${e.toString()}';
      });
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkCurrentAuth() async {
    final isAuthenticated = await _authManager.isAuthenticated();
    if (isAuthenticated && mounted) {
      // User is already authenticated, navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or App Title
                      const Icon(
                        Icons.security,
                        size: 80.0,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'TraCuuGcn',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1976D2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Hệ thống tra cứu giấy chứng nhận',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32.0),
                      
                      // Error message
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Keycloak SSO Login Button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleKeycloakLogin,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(_isLoading ? 'Đang đăng nhập...' : 'Đăng nhập SSO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Check Auth Status Button (for debugging)
                      if (kDebugMode)
                        TextButton(
                          onPressed: _isLoading ? null : _checkCurrentAuth,
                          child: const Text('Kiểm tra trạng thái đăng nhập'),
                        ),
                      
                      const SizedBox(height: 24.0),
                      
                      // Footer
                      Text(
                        'Sử dụng tài khoản SSO của bạn để đăng nhập',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
