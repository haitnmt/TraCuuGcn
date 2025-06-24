import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models/auth_user.dart';
import 'models/auth_token.dart';
import 'models/auth_models.dart';
import 'auth_manager.dart';

// Auth service để quản lý trạng thái xác thực
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthManager _authManager = AuthManager();
  
  AuthUser? _currentUser;
  AuthToken? _currentToken;
  AuthState _authState = AuthState.initial;
  String? _errorMessage;

  // Getters
  AuthUser? get currentUser => _currentUser;
  AuthToken? get currentToken => _currentToken;
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated && _currentUser != null;
  bool get isLoading => _authState == AuthState.loading;

  // Stream controller cho auth state changes
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;

  // Initialize auth service
  Future<void> initialize() async {
    try {
      _setAuthState(AuthState.loading);
      
      // Kiểm tra xem user đã đăng nhập trước đó chưa
      final isAuth = await _authManager.isAuthenticated();
      if (isAuth) {
        final token = await _authManager.getToken();
        if (token != null) {
          // Load user info và token
          await _loadUserSession();
          _setAuthState(AuthState.authenticated);
        } else {
          _setAuthState(AuthState.unauthenticated);
        }
      } else {
        _setAuthState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize auth service: $e');
    }
  }

  // Login method
  Future<AuthResult> login(LoginCredentials credentials) async {
    try {
      _setAuthState(AuthState.loading);
      
      // Thực hiện xác thực thông qua AuthManager
      await _authManager.authenticate();
      
      // TODO: Implement actual login logic with API
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock user and token
      _currentUser = AuthUser(
        id: '1',
        username: credentials.username,
        email: '${credentials.username}@example.com',
        fullName: 'User ${credentials.username}',
        roles: ['user'],
        lastLogin: DateTime.now(),
      );
      
      _currentToken = AuthToken(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
        issuedAt: DateTime.now(),
      );
      
      _setAuthState(AuthState.authenticated);
      
      return AuthResult.success(message: 'Login successful');
    } catch (e) {
      _setError('Login failed: $e');
      return AuthResult.failure(message: 'Login failed: $e');
    }
  }

  // Logout method
  Future<AuthResult> logout() async {
    try {
      _setAuthState(AuthState.loading);
      
      await _authManager.logout();
      
      _currentUser = null;
      _currentToken = null;
      _errorMessage = null;
      
      _setAuthState(AuthState.unauthenticated);
      
      return AuthResult.success(message: 'Logout successful');
    } catch (e) {
      _setError('Logout failed: $e');
      return AuthResult.failure(message: 'Logout failed: $e');
    }
  }

  // Register method
  Future<AuthResult> register(RegisterData registerData) async {
    try {
      if (!registerData.passwordsMatch) {
        return AuthResult.failure(message: 'Passwords do not match');
      }
      
      _setAuthState(AuthState.loading);
      
      // TODO: Implement actual registration logic with API
      await Future.delayed(const Duration(seconds: 2));
      
      _setAuthState(AuthState.unauthenticated);
      
      return AuthResult.success(message: 'Registration successful');
    } catch (e) {
      _setError('Registration failed: $e');
      return AuthResult.failure(message: 'Registration failed: $e');
    }
  }

  // Refresh token method
  Future<AuthResult> refreshToken() async {
    try {
      if (_currentToken?.refreshToken == null) {
        return AuthResult.failure(message: 'No refresh token available');
      }
      
      // TODO: Implement actual token refresh logic with API
      await Future.delayed(const Duration(milliseconds: 500));
      
      _currentToken = _currentToken!.copyWith(
        accessToken: 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
        issuedAt: DateTime.now(),
      );
      
      notifyListeners();
      
      return AuthResult.success(message: 'Token refreshed successfully');
    } catch (e) {
      _setError('Token refresh failed: $e');
      return AuthResult.failure(message: 'Token refresh failed: $e');
    }
  }

  // Private methods
  void _setAuthState(AuthState state) {
    _authState = state;
    _authStateController.add(state);
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setAuthState(AuthState.error);
  }

  Future<void> _loadUserSession() async {
    // TODO: Load user session from secure storage
    // This is where you would typically load user data from local storage
  }

  // Cleanup
  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
