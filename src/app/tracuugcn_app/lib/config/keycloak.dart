import 'package:flutter/foundation.dart';
import '../models/keycloak_config.dart';

class Keycloak {
  // Đây là ví dụ cấu hình Keycloak
  // Thay đổi các giá trị này theo cấu hình Keycloak của bạn
    // Base configuration
  static const String _keycloakUrl = 'https://sso.vpdkbacninh.vn';
  static const String _realm = 'vpdk';
  static const String _clientId = 'flutter-tracuugcn-dev';
  static const String _clientSecret = '8ViPIxXrowIDu5RWmLlQhQLspzP1oy7Y';
  
  // Alternative HTTP configuration (if SSL issues)
  // Uncomment and use this if you have SSL certificate issues
  // static const String _keycloakUrl = 'http://sso.vpdkbacninh.vn';
  
  // Platform-specific redirect URIs
  static const String _mobileRedirectUri = 'vn.vpdkbacninh.tracuugcn.dev://login-callback';
  static const String _webRedirectUri = 'http://localhost:62005/';
  
  // Default scopes
  static const List<String> _defaultScopes = [
    'openid',    // Bắt buộc cho OpenID Connect
    'profile',   // Để lấy thông tin profile
    'email',     // Để lấy email
    'roles',     // Để lấy roles (nếu có)
  ];

  /// Get platform-specific Keycloak config
  static KeycloakConfig get config {
    if (kIsWeb) {
      // Web platform configuration
      return KeycloakConfig.forWeb(
        keycloakUrl: _keycloakUrl,
        realm: _realm,
        clientId: _clientId,
        clientSecret: _clientSecret,
        webRedirectUri: _webRedirectUri,
        scopes: _defaultScopes,
      );
    } else {
      // Mobile platform configuration  
      return KeycloakConfig.forMobile(
        keycloakUrl: _keycloakUrl,
        realm: _realm,
        clientId: _clientId,
        clientSecret: _clientSecret,
        mobileRedirectUri: _mobileRedirectUri,
        scopes: _defaultScopes,
      );
    }
  }

  /// Create custom config for specific platform
  static KeycloakConfig createConfig({
    String? keycloakUrl,
    String? realm,
    String? clientId,
    String? clientSecret,
    String? mobileRedirectUri,
    String? webRedirectUri,
    List<String>? scopes,
    bool? forceWeb,
  }) {
    final isWeb = forceWeb ?? kIsWeb;
    
    if (isWeb) {
      return KeycloakConfig.forWeb(
        keycloakUrl: keycloakUrl ?? _keycloakUrl,
        realm: realm ?? _realm,
        clientId: clientId ?? _clientId,
        clientSecret: clientSecret ?? _clientSecret,
        webRedirectUri: webRedirectUri ?? _webRedirectUri,
        scopes: scopes ?? _defaultScopes,
      );
    } else {
      return KeycloakConfig.forMobile(
        keycloakUrl: keycloakUrl ?? _keycloakUrl,
        realm: realm ?? _realm,
        clientId: clientId ?? _clientId,
        clientSecret: clientSecret ?? _clientSecret,
        mobileRedirectUri: mobileRedirectUri ?? _mobileRedirectUri,
        scopes: scopes ?? _defaultScopes,
      );
    }
  }
}

