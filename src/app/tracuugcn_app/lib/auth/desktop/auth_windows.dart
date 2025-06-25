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
  
  WindowsAuth() {
    _storage = SecureAuthStorage();
    _config = AutoOpenIdConfig.optimized(provider: 'keycloak');
  }

  @override
  Future<void> authenticate() async {
    try {
      debugPrint("[WindowsAuth] Starting authentication...");
      
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
      
      // Get refresh token for logout
      final refreshToken = await _storage.getSecureData(_refreshTokenKey);
      
      // Build logout URL
      final logoutUrl = _buildLogoutUrl(refreshToken);
      if (logoutUrl != null) {
        await _launchUrl(logoutUrl);
      }
      
      // Clear stored data
      await _clearAuthData();
      
      debugPrint("[WindowsAuth] Logout completed");
    } catch (e, stackTrace) {
      debugPrint("[WindowsAuth] Logout error: $e");
      debugPrint("[WindowsAuth] Stack trace: $stackTrace");
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
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userInfoJson = await _storage.getSecureData(_userInfoKey);
      if (userInfoJson != null && userInfoJson.isNotEmpty) {
        final userInfo = jsonDecode(userInfoJson);
        return AuthUser.fromKeycloakUserInfo(userInfo);
      }
      
      return null;
    } catch (e) {
      debugPrint("[WindowsAuth] Get current user error: $e");
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
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '${_config.issuer}protocol/openid-connect/auth?$queryString';
  }
  
  /// Build Keycloak logout URL
  String? _buildLogoutUrl(String? refreshToken) {
    try {
      final params = <String, String>{
        'redirect_uri': _config.postLogoutRedirectUri ?? _config.redirectUri,
      };
      
      // Add refresh token if available for proper logout
      if (refreshToken != null && refreshToken.isNotEmpty) {
        params['refresh_token'] = refreshToken;
      }
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      return '${_config.issuer}protocol/openid-connect/logout?$queryString';
    } catch (e) {
      debugPrint("[WindowsAuth] Error building logout URL: $e");
      return null;
    }
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
        // Error response
        response.write('''
          <html>
            <head><title>Authentication Failed</title></head>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
              <h1 style="color: #d32f2f;">Authentication Failed</h1>
              <p>Error: ${params['error']}</p>
              <p>Description: ${params['error_description'] ?? 'Unknown error'}</p>
              <p>You can close this window.</p>
            </body>
          </html>
        ''');
      } else {
        // Success response
        response.write('''
          <html>
            <head><title>Authentication Successful</title></head>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
              <h1 style="color: #4caf50;">Authentication Successful</h1>
              <p>You have been successfully authenticated. You can close this window.</p>
              <script>
                setTimeout(function() {
                  window.close();
                }, 2000);
              </script>
            </body>
          </html>
        ''');
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
      
      final response = await http.get(
        Uri.parse(userInfoEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      debugPrint("[WindowsAuth] UserInfo response status: ${response.statusCode}");
      
      if (response.statusCode != 200) {
        debugPrint("[WindowsAuth] UserInfo request failed: ${response.body}");
        throw Exception('UserInfo request failed: ${response.statusCode}');
      }
      
      return jsonDecode(response.body) as Map<String, dynamic>;
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
}