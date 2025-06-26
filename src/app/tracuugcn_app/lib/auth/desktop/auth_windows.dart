import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../auth_manager.dart';
import '../config/openid_config.dart';
import '../storage/auth_storage.dart';
import '../models/auth_user.dart';

class WindowsAuth implements AuthProvider {
  static const String _accessTokenKey = 'windows_access_token';
  static const String _refreshTokenKey = 'windows_refresh_token';
  static const String _userInfoKey = 'windows_user_info';
  static const String _stateKey = 'windows_auth_state';
  
  late final AuthStorage _storage;
  late final OpenIdConfig _config;
  HttpServer? _callbackServer;
  Completer<Map<String, String>>? _authCompleter;
  String? _currentLanguageCode;
  
  WindowsAuth() {
    _storage = SecureAuthStorage();
    _config = AutoOpenIdConfig.optimized(provider: 'keycloak');
  }

  @override
  Future<void> authenticate({String? languageCode}) async {
    try {
      debugPrint("[WindowsAuth] Starting authentication...");
      
      // Store the language code for use in browser pages
      _currentLanguageCode = languageCode ?? 'vi';
      debugPrint("[WindowsAuth] Using language: $_currentLanguageCode");
      
      // Generate secure state parameter
      final state = _generateSecureState();
      await _storage.storeSecureData(_stateKey, state);
      
      // Start local callback server
      await _startCallbackServer();
      
      // Build Keycloak authorization URL
      final authUrl = _buildAuthUrl(state);
      debugPrint("[WindowsAuth] Auth URL: $authUrl");
      
      // Launch URL in browser
      await _launchUrl(authUrl);
      
      debugPrint("[WindowsAuth] Browser launched. Waiting for callback...");
      
      // Wait for callback from browser
      final authResult = await _waitForCallback();
      
      // Validate state parameter
      if (!await _validateState(authResult['state'])) {
        throw Exception('Invalid state parameter. Possible CSRF attack.');
      }
      
      // Check for errors in callback
      if (authResult.containsKey('error')) {
        final errorDesc = authResult['error_description'] ?? authResult['error'];
        throw Exception('Authentication failed: $errorDesc');
      }
      
      // Extract authorization code
      final authCode = authResult['code'];
      if (authCode == null || authCode.isEmpty) {
        throw Exception('No authorization code received');
      }
      
      debugPrint("[WindowsAuth] Authorization code received, exchanging for tokens...");
      
      // Exchange authorization code for tokens
      final tokens = await _exchangeCodeForTokens(authCode);
      
      // Get user information
      final accessToken = tokens['access_token'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token received');
      }
      
      final userInfo = await _getUserInfo(accessToken);
      
      // Store tokens and user info
      await _storeAuthData(tokens, userInfo);
      
      debugPrint("[WindowsAuth] Authentication completed successfully");
    } catch (e, stackTrace) {
      debugPrint("[WindowsAuth] Authentication error: $e");
      debugPrint("[WindowsAuth] Stack trace: $stackTrace");
      await _cleanup();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint("[WindowsAuth] Starting logout...");
      
      // Logout from Keycloak server first (silent logout)
      try {
        final refreshToken = await _storage.getSecureData(_refreshTokenKey);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          debugPrint("[WindowsAuth] Performing server logout...");
          await _performSilentLogout(refreshToken);
        } else {
          debugPrint("[WindowsAuth] No refresh token for server logout");
        }
      } catch (e) {
        debugPrint("[WindowsAuth] Server logout failed (continuing with local logout): $e");
      }
      
      // Clear local data
      await _clearAuthData();
      
      debugPrint("[WindowsAuth] Logout completed (server + local)");
      
    } catch (e, stackTrace) {
      debugPrint("[WindowsAuth] Logout error: $e");
      debugPrint("[WindowsAuth] Stack trace: $stackTrace");
      // Even if logout fails, clear local data
      await _clearAuthData();
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Check if we have stored tokens
      final accessToken = await _storage.getSecureData(_accessTokenKey);
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }
      
      // TODO: Validate token expiry and refresh if needed
      return true;
    } catch (e) {
      debugPrint("[WindowsAuth] Authentication check error: $e");
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final accessToken = await _storage.getSecureData(_accessTokenKey);
      
      // TODO: Check token expiry and refresh if needed
      if (accessToken != null && await _isTokenExpired(accessToken)) {
        await _refreshAccessToken();
        return await _storage.getSecureData(_accessTokenKey);
      }
      
      return accessToken;
    } catch (e) {
      debugPrint("[WindowsAuth] Get token error: $e");
      return null;
    }
  }
  
  /// Get current user information
  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      debugPrint("[WindowsAuth] Getting current user...");
      final userInfoJson = await _storage.getSecureData(_userInfoKey);
      debugPrint("[WindowsAuth] Retrieved userInfoJson: $userInfoJson");
      
      if (userInfoJson != null && userInfoJson.isNotEmpty) {
        final userInfo = jsonDecode(userInfoJson);
        debugPrint("[WindowsAuth] Parsed userInfo: $userInfo");
        
        final authUser = AuthUser.fromKeycloakUserInfo(userInfo);
        debugPrint("[WindowsAuth] Created AuthUser: $authUser");
        return authUser;
      }
      
      debugPrint("[WindowsAuth] No user info found in storage");
      return null;
    } catch (e, stackTrace) {
      debugPrint("[WindowsAuth] Get current user error: $e");
      debugPrint("[WindowsAuth] StackTrace: $stackTrace");
      return null;
    }
  }
  
  /// Generate secure random state parameter
  String _generateSecureState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
  
  /// Build Keycloak authorization URL with state
  String _buildAuthUrl(String state) {
    final params = {
      'response_type': 'code',
      'client_id': _config.clientId,
      'redirect_uri': _config.redirectUri,
      'scope': _config.scopes.join(' '),
      'state': state,
    };
    
    // Add locale parameter if language code is available
    if (_currentLanguageCode != null) {
      // Map app language codes to Keycloak locale codes
      String keycloakLocale;
      switch (_currentLanguageCode) {
        case 'vi':
          keycloakLocale = 'vi';
          break;
        case 'en':
          keycloakLocale = 'en';
          break;
        default:
          keycloakLocale = 'vi'; // Default to Vietnamese
      }
      
      params['ui_locales'] = keycloakLocale;
      params['kc_locale'] = keycloakLocale; // Alternative parameter for some Keycloak versions
      
      debugPrint("[WindowsAuth] Adding locale parameters: ui_locales=$keycloakLocale, kc_locale=$keycloakLocale");
    }
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '${_config.issuer}protocol/openid-connect/auth?$queryString';
  }
  
  /// Start local HTTP server to handle OAuth callback
  Future<void> _startCallbackServer() async {
    try {
      // Close any existing server
      await _callbackServer?.close();
      
      // Start server on port 8080
      _callbackServer = await HttpServer.bind('localhost', 8080);
      debugPrint("[WindowsAuth] Callback server started on http://localhost:8080");
      
      // Setup auth completer
      _authCompleter = Completer<Map<String, String>>();
      
      // Listen for requests
      _callbackServer!.listen((HttpRequest request) {
        _handleCallbackRequest(request);
      });
    } catch (e) {
      debugPrint("[WindowsAuth] Failed to start callback server: $e");
      rethrow;
    }
  }
  
  /// Handle OAuth callback request
  void _handleCallbackRequest(HttpRequest request) {
    debugPrint("[WindowsAuth] Received callback: ${request.uri}");
    
    try {
      // Ignore non-auth requests (favicon, etc.)
      if (!request.uri.path.startsWith('/auth/callback')) {
        debugPrint("[WindowsAuth] Ignoring non-auth request: ${request.uri.path}");
        request.response.statusCode = 404;
        request.response.write('Not Found');
        request.response.close();
        return;
      }
      
      // Extract query parameters
      final params = <String, String>{};
      request.uri.queryParameters.forEach((key, value) {
        params[key] = value;
      });
      
      debugPrint("[WindowsAuth] Callback parameters: ${params.keys.join(', ')}");
      
      // Send response to browser
      final response = request.response;
      response.headers.set('Content-Type', 'text/html; charset=utf-8');
      
      if (params.containsKey('error')) {
        // Error response with localized content
        response.write(_generateErrorHtml(params));
      } else {
        // Success response with localized content
        response.write(_generateSuccessHtml());
      }
      
      response.close();
      
      // Complete the authentication process
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.complete(params);
      }
      
      // Close server after handling callback
      _callbackServer?.close();
      _callbackServer = null;
      
    } catch (e) {
      debugPrint("[WindowsAuth] Error handling callback: $e");
      if (!_authCompleter!.isCompleted) {
        _authCompleter!.completeError(e);
      }
    }
  }
  
  /// Wait for OAuth callback
  Future<Map<String, String>> _waitForCallback() async {
    if (_authCompleter == null) {
      throw Exception('Auth completer not initialized');
    }
    
    // Wait for callback with timeout
    return await _authCompleter!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        throw Exception('Authentication timeout. Please try again.');
      },
    );
  }
  
  /// Validate state parameter to prevent CSRF attacks
  Future<bool> _validateState(String? receivedState) async {
    if (receivedState == null || receivedState.isEmpty) {
      return false;
    }
    
    final storedState = await _storage.getSecureData(_stateKey);
    return storedState == receivedState;
  }
  
  /// Exchange authorization code for access tokens
  Future<Map<String, String>> _exchangeCodeForTokens(String authCode) async {
    try {
      final tokenEndpoint = '${_config.issuer}protocol/openid-connect/token';
      
      // Prepare request body - try different client authentication methods
      final body = <String, String>{
        'grant_type': 'authorization_code',
        'client_id': _config.clientId,
        'code': authCode,
        'redirect_uri': _config.redirectUri,
      };
      
      Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      
      // Try client_secret first (most common for confidential clients)
      if (_config.clientSecret != null && _config.clientSecret!.isNotEmpty) {
        body['client_secret'] = _config.clientSecret!;
      } else {
        // For public clients, try without client_secret
        debugPrint("[WindowsAuth] Using public client authentication");
      }
      
      debugPrint("[WindowsAuth] Token endpoint: $tokenEndpoint");
      debugPrint("[WindowsAuth] Request body: ${body.keys.join(', ')}");
      
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: headers,
        body: body,
      );
      
      debugPrint("[WindowsAuth] Token exchange response status: ${response.statusCode}");
      debugPrint("[WindowsAuth] Token exchange response: ${response.body}");
      
      if (response.statusCode != 200) {
        // If confidential client fails, try as public client
        if (_config.clientSecret != null && response.statusCode == 400) {
          debugPrint("[WindowsAuth] Confidential client failed, trying public client...");
          
          final publicBody = <String, String>{
            'grant_type': 'authorization_code',
            'client_id': _config.clientId,
            'code': authCode,
            'redirect_uri': _config.redirectUri,
            // No client_secret for public client
          };
          
          final publicResponse = await http.post(
            Uri.parse(tokenEndpoint),
            headers: headers,
            body: publicBody,
          );
          
          debugPrint("[WindowsAuth] Public client response status: ${publicResponse.statusCode}");
          debugPrint("[WindowsAuth] Public client response: ${publicResponse.body}");
          
          if (publicResponse.statusCode == 200) {
            final tokenData = jsonDecode(publicResponse.body) as Map<String, dynamic>;
            return _extractTokens(tokenData);
          }
        }
        
        debugPrint("[WindowsAuth] Token exchange failed: ${response.body}");
        throw Exception('Token exchange failed: ${response.statusCode} - ${response.body}');
      }
      
      final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
      return _extractTokens(tokenData);
    } catch (e) {
      debugPrint("[WindowsAuth] Token exchange error: $e");
      rethrow;
    }
  }
  
  /// Extract tokens from response
  Map<String, String> _extractTokens(Map<String, dynamic> tokenData) {
    return {
      'access_token': tokenData['access_token'] ?? '',
      'refresh_token': tokenData['refresh_token'] ?? '',
      'id_token': tokenData['id_token'] ?? '',
      'token_type': tokenData['token_type'] ?? 'Bearer',
      'expires_in': tokenData['expires_in']?.toString() ?? '3600',
    };
  }
  
  /// Get user information from UserInfo endpoint
  Future<Map<String, dynamic>> _getUserInfo(String accessToken) async {
    try {
      final userInfoEndpoint = '${_config.issuer}protocol/openid-connect/userinfo';
      debugPrint("[WindowsAuth] Calling UserInfo endpoint: $userInfoEndpoint");
      
      final response = await http.get(
        Uri.parse(userInfoEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      debugPrint("[WindowsAuth] UserInfo response status: ${response.statusCode}");
      debugPrint("[WindowsAuth] UserInfo response body: ${response.body}");
      
      if (response.statusCode != 200) {
        debugPrint("[WindowsAuth] UserInfo request failed: ${response.body}");
        throw Exception('UserInfo request failed: ${response.statusCode}');
      }

      final userInfo = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint("[WindowsAuth] Parsed UserInfo: $userInfo");
      debugPrint("[WindowsAuth] Available keys: ${userInfo.keys.toList()}");
      
      return userInfo;
    } catch (e) {
      debugPrint("[WindowsAuth] UserInfo error: $e");
      rethrow;
    }
  }
  
  /// Store authentication data securely
  Future<void> _storeAuthData(Map<String, String> tokens, Map<String, dynamic> userInfo) async {
    try {
      await _storage.storeSecureData(_accessTokenKey, tokens['access_token'] ?? '');
      await _storage.storeSecureData(_refreshTokenKey, tokens['refresh_token'] ?? '');
      await _storage.storeSecureData(_userInfoKey, jsonEncode(userInfo));
      
      debugPrint("[WindowsAuth] Auth data stored successfully");
    } catch (e) {
      debugPrint("[WindowsAuth] Store auth data error: $e");
      rethrow;
    }
  }
  
  /// Check if access token is expired
  Future<bool> _isTokenExpired(String accessToken) async {
    try {
      // Decode JWT payload (basic check without signature validation)
      final parts = accessToken.split('.');
      if (parts.length != 3) return true;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // Consider token expired if it expires in less than 5 minutes
      return expiryTime.isBefore(now.add(const Duration(minutes: 5)));
    } catch (e) {
      debugPrint("[WindowsAuth] Token expiry check error: $e");
      return true; // Consider expired if we can't validate
    }
  }
  
  /// Refresh access token using refresh token
  Future<void> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.getSecureData(_refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }
      
      final tokenEndpoint = '${_config.issuer}protocol/openid-connect/token';
      
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'refresh_token',
          'client_id': _config.clientId,
          'refresh_token': refreshToken,
          if (_config.clientSecret != null) 'client_secret': _config.clientSecret!,
        },
      );
      
      debugPrint("[WindowsAuth] Token refresh response status: ${response.statusCode}");
      
      if (response.statusCode != 200) {
        debugPrint("[WindowsAuth] Token refresh failed: ${response.body}");
        throw Exception('Token refresh failed: ${response.statusCode}');
      }
      
      final tokenData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Store new tokens
      await _storage.storeSecureData(_accessTokenKey, tokenData['access_token'] ?? '');
      if (tokenData['refresh_token'] != null) {
        await _storage.storeSecureData(_refreshTokenKey, tokenData['refresh_token']);
      }
      
      debugPrint("[WindowsAuth] Tokens refreshed successfully");
    } catch (e) {
      debugPrint("[WindowsAuth] Token refresh error: $e");
      // If refresh fails, clear tokens to force re-authentication
      await _clearAuthData();
      rethrow;
    }
  }
  
  /// Perform silent logout on Keycloak server without opening browser
  Future<void> _performSilentLogout(String? refreshToken) async {
    try {
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint("[WindowsAuth] No refresh token for server logout");
        return;
      }
      
      final logoutEndpoint = '${_config.issuer}protocol/openid-connect/logout';
      
      // Prepare logout request body
      final body = <String, String>{
        'client_id': _config.clientId,
        'refresh_token': refreshToken,
      };
      
      // Add client_secret if available (for confidential clients)
      if (_config.clientSecret != null && _config.clientSecret!.isNotEmpty) {
        body['client_secret'] = _config.clientSecret!;
      }
      
      debugPrint("[WindowsAuth] Logout endpoint: $logoutEndpoint");
      debugPrint("[WindowsAuth] Logout request params: ${body.keys.join(', ')}");
      
      final response = await http.post(
        Uri.parse(logoutEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );
      
      debugPrint("[WindowsAuth] Silent logout response status: ${response.statusCode}");
      debugPrint("[WindowsAuth] Silent logout response: ${response.body}");
      
      // Keycloak logout typically returns 204 (No Content) on success
      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint("[WindowsAuth] Server logout successful - SSO session terminated");
      } else if (response.statusCode == 400) {
        debugPrint("[WindowsAuth] Server logout failed - bad request: ${response.body}");
        // Try without client_secret for public clients
        if (_config.clientSecret != null) {
          debugPrint("[WindowsAuth] Retrying logout as public client...");
          final publicBody = <String, String>{
            'client_id': _config.clientId,
            'refresh_token': refreshToken,
          };
          
          final publicResponse = await http.post(
            Uri.parse(logoutEndpoint),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: publicBody,
          );
          
          debugPrint("[WindowsAuth] Public client logout response: ${publicResponse.statusCode}");
          if (publicResponse.statusCode == 204 || publicResponse.statusCode == 200) {
            debugPrint("[WindowsAuth] Public client logout successful");
          }
        }
      } else {
        debugPrint("[WindowsAuth] Server logout failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("[WindowsAuth] Silent logout error: $e");
      // Don't throw error, as local logout should still proceed
    }
  }
  
  /// Launch URL in system browser
  Future<void> _launchUrl(String url) async {
    debugPrint("[WindowsAuth] Launching URL: $url");
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }
  
  /// Clear all stored authentication data
  Future<void> _clearAuthData() async {
    try {
      await _storage.deleteSecureData(_accessTokenKey);
      await _storage.deleteSecureData(_refreshTokenKey);
      await _storage.deleteSecureData(_userInfoKey);
      await _storage.deleteSecureData(_stateKey);
      
      debugPrint("[WindowsAuth] Auth data cleared");
    } catch (e) {
      debugPrint("[WindowsAuth] Clear auth data error: $e");
    }
  }
  
  /// Cleanup resources
  Future<void> _cleanup() async {
    try {
      await _callbackServer?.close();
      _callbackServer = null;
      
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.completeError(Exception('Authentication cancelled'));
      }
      _authCompleter = null;
    } catch (e) {
      debugPrint("[WindowsAuth] Cleanup error: $e");
    }
  }
  
  /// Generate localized success HTML page based on current language
  String _generateSuccessHtml() {
    final isVietnamese = _currentLanguageCode == 'vi';
    
    if (isVietnamese) {
      return '''
        <html>
          <head>
            <title>Đăng nhập thành công</title>
            <meta charset="utf-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                margin: 0;
                height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
              }
              .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 15px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
                max-width: 600px;
              }
              .success-icon {
                font-size: 64px;
                color: #4caf50;
                margin-bottom: 20px;
              }
              .message {
                font-size: 18px;
                margin: 15px 0;
                opacity: 0.9;
              }
              .note {
                font-size: 14px;
                opacity: 0.7;
                margin-top: 30px;
                padding: 15px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                text-align: left;
              }
              .divider {
                height: 1px;
                background: rgba(255, 255, 255, 0.3);
                margin: 20px 0;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="success-icon">✅</div>
              <h1 style="color: #4caf50; margin: 20px 0;">Đăng nhập thành công!</h1>
              
              <div class="divider"></div>
              
              <p class="message">Bạn đã đăng nhập thành công vào hệ thống Tra cứu GCN.</p>
              <p class="message">Quay lại ứng dụng để tiếp tục sử dụng.</p>
              
              <div class="note">
                <strong>📌 Hướng dẫn:</strong><br>
                Bạn có thể đóng tab này và quay lại ứng dụng để sử dụng các tính năng.
              </div>
            </div>
          </body>
        </html>
      ''';
    } else {
      return '''
        <html>
          <head>
            <title>Login Successful</title>
            <meta charset="utf-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                margin: 0;
                height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
              }
              .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 15px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
                max-width: 600px;
              }
              .success-icon {
                font-size: 64px;
                color: #4caf50;
                margin-bottom: 20px;
              }
              .message {
                font-size: 18px;
                margin: 15px 0;
                opacity: 0.9;
              }
              .note {
                font-size: 14px;
                opacity: 0.7;
                margin-top: 30px;
                padding: 15px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                text-align: left;
              }
              .divider {
                height: 1px;
                background: rgba(255, 255, 255, 0.3);
                margin: 20px 0;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="success-icon">✅</div>
              <h1 style="color: #4caf50; margin: 20px 0;">Login Successful!</h1>
              
              <div class="divider"></div>
              
              <p class="message">You have successfully logged into the Certificate Lookup System.</p>
              <p class="message">Return to the application to continue using.</p>
              
              <div class="note">
                <strong>📌 Instructions:</strong><br>
                You can close this tab and return to the application to use the features.
              </div>
            </div>
          </body>
        </html>
      ''';
    }
  }
  
  /// Generate localized error HTML page based on current language
  String _generateErrorHtml(Map<String, String> params) {
    final isVietnamese = _currentLanguageCode == 'vi';
    final error = params['error'] ?? 'unknown_error';
    final errorDesc = params['error_description'] ?? (isVietnamese ? 'Lỗi không xác định' : 'Unknown error');
    
    if (isVietnamese) {
      return '''
        <html>
          <head>
            <title>Đăng nhập thất bại</title>
            <meta charset="utf-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #ff7b7b 0%, #d32f2f 100%);
                color: white;
                margin: 0;
                height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
              }
              .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 15px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
                max-width: 600px;
              }
              .error-icon {
                font-size: 64px;
                color: #ff5252;
                margin-bottom: 20px;
              }
              .error-details {
                background: rgba(0, 0, 0, 0.2);
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
                font-family: 'Courier New', monospace;
                font-size: 14px;
              }
              .note {
                font-size: 14px;
                opacity: 0.8;
                margin-top: 20px;
                padding: 15px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                text-align: left;
              }
              .divider {
                height: 1px;
                background: rgba(255, 255, 255, 0.3);
                margin: 15px 0;
              }
              .message {
                margin: 10px 0;
                opacity: 0.9;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="error-icon">❌</div>
              <h1 style="color: #ff5252; margin: 20px 0;">Đăng nhập thất bại</h1>
              
              <div class="divider"></div>
              
              <p class="message">Đã xảy ra lỗi trong quá trình đăng nhập:</p>
              
              <div class="error-details">
                <strong>Lỗi:</strong> $error<br>
                <strong>Mô tả:</strong> $errorDesc
              </div>
              
              <div class="note">
                <strong>💡 Hướng dẫn:</strong><br>
                Vui lòng đóng tab này và thử đăng nhập lại trong ứng dụng.
              </div>
            </div>
          </body>
        </html>
      ''';
    } else {
      return '''
        <html>
          <head>
            <title>Login Failed</title>
            <meta charset="utf-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                background: linear-gradient(135deg, #ff7b7b 0%, #d32f2f 100%);
                color: white;
                margin: 0;
                height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
              }
              .container {
                background: rgba(255, 255, 255, 0.1);
                padding: 40px;
                border-radius: 15px;
                backdrop-filter: blur(10px);
                box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
                border: 1px solid rgba(255, 255, 255, 0.18);
                max-width: 600px;
              }
              .error-icon {
                font-size: 64px;
                color: #ff5252;
                margin-bottom: 20px;
              }
              .error-details {
                background: rgba(0, 0, 0, 0.2);
                padding: 15px;
                border-radius: 8px;
                margin: 20px 0;
                font-family: 'Courier New', monospace;
                font-size: 14px;
              }
              .note {
                font-size: 14px;
                opacity: 0.8;
                margin-top: 20px;
                padding: 15px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                text-align: left;
              }
              .divider {
                height: 1px;
                background: rgba(255, 255, 255, 0.3);
                margin: 15px 0;
              }
              .message {
                margin: 10px 0;
                opacity: 0.9;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="error-icon">❌</div>
              <h1 style="color: #ff5252; margin: 20px 0;">Login Failed</h1>
              
              <div class="divider"></div>
              
              <p class="message">An error occurred during the login process:</p>
              
              <div class="error-details">
                <strong>Error:</strong> $error<br>
                <strong>Description:</strong> $errorDesc
              </div>
              
              <div class="note">
                <strong>💡 Instructions:</strong><br>
                Please close this tab and try logging in again from the application.
              </div>
            </div>
          </body>
        </html>
      ''';
    }
  }
}