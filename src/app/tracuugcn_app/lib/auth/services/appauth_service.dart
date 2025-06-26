import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/auth_user.dart';
import '../models/auth_token.dart';
import '../utils/ini_reader.dart';
import '../auth_openid.dart';

class AppAuthService {
  static final AppAuthService _instance = AppAuthService._internal();
  factory AppAuthService() => _instance;
  AppAuthService._internal();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _userInfoKey = 'user_info';

  // OAuth Configuration từ config file
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load config for initialization check, but we'll use the existing OpenID config system
      await OpenIdIniConfig.load();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AppAuth service: $e');
    }
  }

  // Đăng nhập với Keycloak/SSO
  Future<AuthToken?> signInWithKeycloak() async {
    await _ensureInitialized();
    
    try {
      final config = await KeycloakConfigs.development(platform: _getCurrentPlatform());
      
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          additionalParameters: config.additionalParameters,
          promptValues: ['login'],
        ),
      );

      final authToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: _calculateExpiresIn(result.accessTokenExpirationDateTime),
        issuedAt: DateTime.now(),
      );

      await _saveTokens(authToken);
      await _fetchAndSaveUserInfo(authToken.accessToken, config.issuer);
      
      return authToken;
    } catch (e) {
      debugPrint('Keycloak sign in error: $e');
      rethrow;
    }
  }

  // Đăng nhập với Google
  Future<AuthToken?> signInWithGoogle() async {
    await _ensureInitialized();
    
    try {
      final config = await GoogleOAuthConfigs.standard(platform: _getCurrentPlatform());
      
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          additionalParameters: config.additionalParameters,
          promptValues: ['select_account'],
        ),
      );

      final authToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: _calculateExpiresIn(result.accessTokenExpirationDateTime),
        issuedAt: DateTime.now(),
      );

      await _saveTokens(authToken);
      await _fetchAndSaveUserInfo(authToken.accessToken, config.issuer);
      
      return authToken;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }

  // Đăng nhập với Azure AD
  Future<AuthToken?> signInWithAzure() async {
    await _ensureInitialized();
    
    try {
      final config = await AzureAdConfigs.enterprise(platform: _getCurrentPlatform());
      
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          additionalParameters: config.additionalParameters,
          promptValues: ['select_account'],
        ),
      );

      final authToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: _calculateExpiresIn(result.accessTokenExpirationDateTime),
        issuedAt: DateTime.now(),
      );

      await _saveTokens(authToken);
      await _fetchAndSaveUserInfo(authToken.accessToken, config.issuer);
      
      return authToken;
    } catch (e) {
      debugPrint('Azure sign in error: $e');
      rethrow;
    }
  }

  // Refresh access token
  Future<AuthToken?> refreshToken() async {
    await _ensureInitialized();
    
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final config = await KeycloakConfigs.development(platform: _getCurrentPlatform());
      
      final TokenResponse result = await _appAuth.token(TokenRequest(
        config.clientId,
        config.redirectUri,
        issuer: config.issuer,
        refreshToken: refreshToken,
        clientSecret: config.clientSecret,
      ));

      final authToken = AuthToken(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken,
        tokenType: result.tokenType ?? 'Bearer',
        expiresIn: _calculateExpiresIn(result.accessTokenExpirationDateTime),
        issuedAt: DateTime.now(),
      );

      await _saveTokens(authToken);
      return authToken;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await logout();
    }
    
    return null;
  }

  // Đăng xuất
  Future<void> logout() async {
    await _ensureInitialized();
    
    try {
      final idToken = await _secureStorage.read(key: _idTokenKey);
      
      if (idToken != null) {
        try {
          final config = await KeycloakConfigs.development(platform: _getCurrentPlatform());
          
          await _appAuth.endSession(EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: config.postLogoutRedirectUri,
            issuer: config.issuer,
          ));
        } catch (e) {
          debugPrint('End session error: $e');
        }
      }
      
      await _clearAllTokens();
    } catch (e) {
      debugPrint('Logout error: $e');
      await _clearAllTokens();
    }
  }

  // Kiểm tra authentication status
  Future<bool> isAuthenticated() async {
    await _ensureInitialized();
    
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    if (accessToken == null) return false;
    
    final currentToken = await getCurrentToken();
    if (currentToken?.isExpired == true) {
      final refreshedToken = await refreshToken();
      return refreshedToken != null;
    }
    
    return true;
  }

  // Lấy token hiện tại
  Future<AuthToken?> getCurrentToken() async {
    await _ensureInitialized();
    
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final idToken = await _secureStorage.read(key: _idTokenKey);
    
    if (accessToken == null) return null;
    
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      tokenType: 'Bearer',
      expiresIn: 3600, // Default value, có thể decode từ JWT
      issuedAt: DateTime.now().subtract(const Duration(minutes: 30)), // Estimate
    );
  }

  // Lấy thông tin user hiện tại
  Future<AuthUser?> getCurrentUser() async {
    await _ensureInitialized();
    
    final userInfoJson = await _secureStorage.read(key: _userInfoKey);
    if (userInfoJson == null) return null;
    
    try {
      final userInfo = jsonDecode(userInfoJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userInfo);
    } catch (e) {
      debugPrint('Error parsing user info: $e');
      return null;
    }
  }

  // Private methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  String _getCurrentPlatform() {
    if (Platform.isAndroid) return PlatformConfig.android;
    if (Platform.isIOS) return PlatformConfig.ios;
    if (Platform.isMacOS) return PlatformConfig.macos;
    if (Platform.isWindows) return PlatformConfig.windows;
    if (Platform.isLinux) return PlatformConfig.linux;
    return PlatformConfig.android; // Default
  }

  int _calculateExpiresIn(DateTime? expirationDateTime) {
    if (expirationDateTime == null) return 3600; // Default 1 hour
    
    final now = DateTime.now();
    final difference = expirationDateTime.difference(now);
    return difference.inSeconds > 0 ? difference.inSeconds : 3600;
  }

  Future<void> _saveTokens(AuthToken token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token.accessToken);
    if (token.refreshToken != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: token.refreshToken!);
    }
    if (token.idToken != null) {
      await _secureStorage.write(key: _idTokenKey, value: token.idToken!);
    }
  }

  Future<void> _clearAllTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _idTokenKey);
    await _secureStorage.delete(key: _userInfoKey);
  }

  Future<void> _fetchAndSaveUserInfo(String accessToken, String issuer) async {
    try {
      String userInfoEndpoint;
      
      if (issuer.contains('accounts.google.com')) {
        userInfoEndpoint = 'https://www.googleapis.com/oauth2/v2/userinfo';
      } else if (issuer.contains('microsoftonline.com')) {
        userInfoEndpoint = 'https://graph.microsoft.com/v1.0/me';
      } else {
        // Keycloak/SSO
        userInfoEndpoint = '${issuer}protocol/openid-connect/userinfo';
      }
      
      final response = await http.get(
        Uri.parse(userInfoEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _secureStorage.write(key: _userInfoKey, value: response.body);
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }
}
