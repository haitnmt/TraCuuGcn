import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/appauth_service.dart';
import '../models/auth_token.dart';
import '../models/auth_user.dart';

class AppAuthLoginWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final Function(String)? onLoginError;

  const AppAuthLoginWidget({
    super.key,
    this.onLoginSuccess,
    this.onLoginError,
  });

  @override
  State<AppAuthLoginWidget> createState() => _AppAuthLoginWidgetState();
}

class _AppAuthLoginWidgetState extends State<AppAuthLoginWidget> {
  final AppAuthService _appAuthService = AppAuthService();
  bool _isLoading = false;
  String? _statusMessage;
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing authentication...';
      });

      await _appAuthService.initialize();
      
      // Kiểm tra xem user đã đăng nhập chưa
      final isAuth = await _appAuthService.isAuthenticated();
      if (isAuth) {
        final user = await _appAuthService.getCurrentUser();
        setState(() {
          _currentUser = user;
          _statusMessage = 'User already authenticated';
        });
      } else {
        setState(() {
          _statusMessage = 'Ready to authenticate';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Initialization error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithKeycloak() async {
    await _performSignIn(() => _appAuthService.signInWithKeycloak(), 'Keycloak/SSO');
  }

  Future<void> _signInWithGoogle() async {
    await _performSignIn(() => _appAuthService.signInWithGoogle(), 'Google');
  }

  Future<void> _signInWithAzure() async {
    await _performSignIn(() => _appAuthService.signInWithAzure(), 'Azure AD');
  }

  Future<void> _performSignIn(Future<AuthToken?> Function() signInMethod, String providerName) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Signing in with $providerName...';
    });

    try {
      final token = await signInMethod();
      
      if (token != null) {
        final user = await _appAuthService.getCurrentUser();
        setState(() {
          _currentUser = user;
          _statusMessage = 'Successfully signed in with $providerName';
        });
        
        widget.onLoginSuccess?.call();
      } else {
        setState(() {
          _statusMessage = 'Sign in with $providerName failed: No token received';
        });
        widget.onLoginError?.call('Sign in failed');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign in with $providerName error: $e';
      });
      widget.onLoginError?.call(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Signing out...';
    });

    try {
      await _appAuthService.logout();
      setState(() {
        _currentUser = null;
        _statusMessage = 'Successfully signed out';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign out error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Refreshing token...';
    });

    try {
      final token = await _appAuthService.refreshToken();
      if (token != null) {
        setState(() {
          _statusMessage = 'Token refreshed successfully';
        });
      } else {
        setState(() {
          _statusMessage = 'Token refresh failed';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Token refresh error: $e';
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
        title: const Text('AppAuth Login Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      )
                    else
                      Text(_statusMessage ?? 'Ready'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Info Card
            if (_currentUser != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${_currentUser!.displayName ?? _currentUser!.fullName ?? 'N/A'}'),
                      Text('Email: ${_currentUser!.email}'),
                      Text('ID: ${_currentUser!.id}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Login Buttons
            if (_currentUser == null) ...[
              Text(
                'Sign In Options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithKeycloak,
                icon: const Icon(Icons.security),
                label: const Text('Sign in with Keycloak/SSO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.account_circle),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithAzure,
                icon: const Icon(Icons.business),
                label: const Text('Sign in with Azure AD'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ] else ...[
              // Logged in actions
              Text(
                'User Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _refreshToken,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Token'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Debug Info
            if (kDebugMode) ...[
              Text(
                'Debug Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flutter AppAuth Version: ^9.0.1'),
                      Text('Platform: ${Theme.of(context).platform.name}'),
                      Text('Debug Mode: $kDebugMode'),
                      Text('Profile Mode: $kProfileMode'),
                      Text('Release Mode: $kReleaseMode'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
