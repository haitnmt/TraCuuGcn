import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'config/openid_config.dart';
import 'utils/platform_detector.dart';
import 'models/auth_models.dart';
import 'models/auth_token.dart';
import 'models/auth_user.dart';

/// Complete OpenID Connect authentication implementation
/// This is a comprehensive example showing how to use the configurations
class OpenIdAuthService {
  static final OpenIdAuthService _instance = OpenIdAuthService._internal();
  factory OpenIdAuthService() => _instance;
  OpenIdAuthService._internal();

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _userInfoKey = 'user_info';
  static const String _configKey = 'auth_config';

  OpenIdConfig? _currentConfig;
  AuthToken? _currentToken;
  AuthUser? _currentUser;

  /// Initialize the service with a specific provider configuration
  Future<void> initialize({
    required String provider,
    String? environment,
    Map<String, dynamic>? customConfig,
  }) async {
    try {
      // Get optimized configuration for current platform
      _currentConfig = AutoOpenIdConfig.optimized(
        provider: provider,
        environment: environment,
        customConfig: customConfig,
      );

      // Store configuration for future use
      await _secureStorage.write(
        key: _configKey,
        value: jsonEncode(_currentConfig!.toJson()),
      );

      // Try to restore previous session
      await _restoreSession();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize OpenID service: $e');
      }
      rethrow;
    }
  }

  /// Perform login using OpenID Connect
  Future<AuthResult> login({
    Map<String, String>? additionalParameters,
    List<String>? scopes,
    String? languageCode,
  }) async {
    if (_currentConfig == null) {
      return AuthResult.failure(
        message: 'Service not initialized. Call initialize() first.',
        errorCode: 'NOT_INITIALIZED',
      );
    }

    try {
      // Start with config's additional parameters
      final allParams = <String, String>{
        ..._currentConfig!.additionalParameters ?? {},
        ...additionalParameters ?? {},
      };

      // Add locale parameters if language code is provided
      if (languageCode != null) {
        // Map app language codes to Keycloak locale codes
        String keycloakLocale;
        switch (languageCode) {
          case 'vi':
            keycloakLocale = 'vi';
            break;
          case 'en':
            keycloakLocale = 'en';
            break;
          default:
            keycloakLocale = 'vi'; // Default to Vietnamese
        }
        
        allParams['ui_locales'] = keycloakLocale;
        allParams['kc_locale'] = keycloakLocale; // Alternative parameter for some Keycloak versions
        
        debugPrint("[OpenIdAuthService] Adding locale parameters: ui_locales=$keycloakLocale, kc_locale=$keycloakLocale");
      }

      // Use provided scopes or default from config
      final authScopes = scopes ?? _currentConfig!.scopes;

      // Perform authorization and token exchange
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _currentConfig!.clientId,
          _currentConfig!.redirectUri,
          issuer: _currentConfig!.issuer,
          clientSecret: _currentConfig!.clientSecret,
          scopes: authScopes,
          additionalParameters: allParams,
          allowInsecureConnections: _currentConfig!.allowInsecureConnections,
        ),
      );

      // Create auth token
      _currentToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        expiresIn: result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 3600,
        issuedAt: DateTime.now(),
        tokenType: result.tokenType ?? 'Bearer',
      );

      // Store tokens securely
      await _storeTokens(_currentToken!);

      // Get user information
      await _fetchUserInfo();

      return AuthResult.success(
        message: 'Login successful',
        data: {
          'user': _currentUser?.toJson(),
          'token': _currentToken?.toJson(),
        },
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Authentication failed: ${e.toString()}',
        errorCode: 'AUTH_FAILED',
      );
    }
  }

  /// Refresh the access token
  Future<AuthResult> refreshToken() async {
    if (_currentConfig == null || _currentToken?.refreshToken == null) {
      return AuthResult.failure(
        message: 'No refresh token available',
        errorCode: 'NO_REFRESH_TOKEN',
      );
    }

    try {
      final result = await _appAuth.token(
        TokenRequest(
          _currentConfig!.clientId,
          _currentConfig!.redirectUri,
          issuer: _currentConfig!.issuer,
          clientSecret: _currentConfig!.clientSecret,
          refreshToken: _currentToken!.refreshToken,
          grantType: 'refresh_token',
          allowInsecureConnections: _currentConfig!.allowInsecureConnections,
        ),
      );

      // Update token
      _currentToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? _currentToken!.refreshToken,
        idToken: result.idToken ?? _currentToken!.idToken,
        expiresIn: result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 3600,
        issuedAt: DateTime.now(),
        tokenType: result.tokenType ?? 'Bearer',
      );

      // Store updated tokens
      await _storeTokens(_currentToken!);

      return AuthResult.success(
        message: 'Token refreshed successfully',
        data: _currentToken?.toJson(),
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Token refresh failed: ${e.toString()}',
        errorCode: 'REFRESH_ERROR',
      );
    }
  }

  /// Perform logout
  Future<AuthResult> logout() async {
    try {
      // End session with the provider if supported
      if (_currentConfig != null && _currentToken?.idToken != null) {
        try {
          await _appAuth.endSession(
            EndSessionRequest(
              idTokenHint: _currentToken!.idToken,
              postLogoutRedirectUrl: _currentConfig!.postLogoutRedirectUri,
              issuer: _currentConfig!.issuer,
              allowInsecureConnections: _currentConfig!.allowInsecureConnections,
            ),
          );
        } catch (e) {
          // Continue with local logout even if remote logout fails
          if (kDebugMode) {
            print('Remote logout failed: $e');
          }
        }
      }

      // Clear local storage
      await _clearStorage();

      // Clear in-memory state
      _currentToken = null;
      _currentUser = null;

      return AuthResult.success(message: 'Logout successful');
    } catch (e) {
      return AuthResult.failure(
        message: 'Logout failed: ${e.toString()}',
        errorCode: 'LOGOUT_FAILED',
      );
    }
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated {
    return _currentToken != null && !_currentToken!.isExpired;
  }

  /// Get current user information
  AuthUser? get currentUser => _currentUser;

  /// Get current token
  AuthToken? get currentToken => _currentToken;

  /// Get current configuration
  OpenIdConfig? get currentConfig => _currentConfig;

  /// Fetch user information from the provider
  Future<void> _fetchUserInfo() async {
    if (_currentToken?.accessToken == null) return;

    try {
      // This is a simplified example - in practice, you'd call the userinfo endpoint
      // or decode the ID token to get user information
      
      if (_currentToken!.idToken != null) {
        // Decode ID token (simplified - in practice, you should validate the token)
        final parts = _currentToken!.idToken!.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Add padding if needed
          final paddedPayload = payload + '=' * ((4 - payload.length % 4) % 4);
          final decoded = utf8.decode(base64Url.decode(paddedPayload));
          final claims = jsonDecode(decoded) as Map<String, dynamic>;

          _currentUser = AuthUser(
            id: claims['sub'] ?? '',
            username: claims['preferred_username'] ?? claims['email'] ?? '',
            email: claims['email'] ?? '',
            fullName: claims['name'] ?? '',
            roles: (claims['roles'] as List?)?.cast<String>() ?? [],
            lastLogin: DateTime.now(),
          );

          // Store user info
          await _secureStorage.write(
            key: _userInfoKey,
            value: jsonEncode(_currentUser!.toJson()),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch user info: $e');
      }
    }
  }

  /// Store tokens securely
  Future<void> _storeTokens(AuthToken token) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: token.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: token.refreshToken ?? ''),
      _secureStorage.write(key: _idTokenKey, value: token.idToken ?? ''),
    ]);
  }

  /// Restore session from stored tokens
  Future<void> _restoreSession() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final idToken = await _secureStorage.read(key: _idTokenKey);
      final userInfoJson = await _secureStorage.read(key: _userInfoKey);

      if (accessToken != null) {
        _currentToken = AuthToken(
          accessToken: accessToken,
          refreshToken: refreshToken?.isNotEmpty == true ? refreshToken : null,
          idToken: idToken?.isNotEmpty == true ? idToken : null,
          expiresIn: 3600, // Default - should be calculated properly
          issuedAt: DateTime.now(), // This should be stored and restored
        );

        // Check if token is expired and try to refresh
        if (_currentToken!.isExpired && _currentToken!.refreshToken != null) {
          await this.refreshToken();
        }
      }

      if (userInfoJson != null) {
        final userInfo = jsonDecode(userInfoJson) as Map<String, dynamic>;
        _currentUser = AuthUser.fromJson(userInfo);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to restore session: $e');
      }
      // Clear corrupted data
      await _clearStorage();
    }
  }

  /// Clear all stored authentication data
  Future<void> _clearStorage() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _idTokenKey),
      _secureStorage.delete(key: _userInfoKey),
    ]);
  }

  /// Get platform-specific debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'platform_info': PlatformDetector.getDebugInfo(),
      'current_config': _currentConfig?.toJson(),
      'is_authenticated': isAuthenticated,
      'has_refresh_token': _currentToken?.refreshToken != null,
      'token_expires_at': _currentToken?.expiresAt.toIso8601String(),
      'current_user_id': _currentUser?.id,
    };
  }
}

/// Example usage class showing how to integrate the auth service
class AuthExampleUsage {
  static final OpenIdAuthService _authService = OpenIdAuthService();

  /// Initialize with Keycloak
  static Future<void> initializeKeycloak() async {
    await _authService.initialize(
      provider: 'keycloak',
      environment: kDebugMode ? 'development' : 'production',
    );
  }

  /// Initialize with Azure AD
  static Future<void> initializeAzureAD() async {
    await _authService.initialize(
      provider: 'azure',
      environment: 'enterprise',
    );
  }

  /// Initialize with Google
  static Future<void> initializeGoogle() async {
    await _authService.initialize(provider: 'google');
  }

  /// Initialize with custom provider
  static Future<void> initializeCustom() async {
    await _authService.initialize(
      provider: 'custom',
      customConfig: {
        'issuer': 'https://your-custom-provider.com',
        'clientId': 'your-client-id',
        'scopes': ['openid', 'profile', 'email'],
      },
    );
  }

  /// Example login flow
  static Future<bool> performLogin() async {
    try {
      final result = await _authService.login();
      if (result.success) {
        print('Login successful: ${result.message}');
        return true;
      } else {
        print('Login failed: ${result.message}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  /// Example token refresh
  static Future<bool> refreshAuthToken() async {
    try {
      final result = await _authService.refreshToken();
      return result.success;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Example logout
  static Future<bool> performLogout() async {
    try {
      final result = await _authService.logout();
      return result.success;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  /// Check authentication status
  static bool isLoggedIn() {
    return _authService.isAuthenticated;
  }

  /// Get current user
  static AuthUser? getCurrentUser() {
    return _authService.currentUser;
  }

  /// Print debug information
  static void printDebugInfo() {
    final debugInfo = _authService.getDebugInfo();
    print('Auth Debug Info: ${jsonEncode(debugInfo)}');
  }
}
