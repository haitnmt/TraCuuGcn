import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utility class for detecting the current platform and providing
/// platform-specific configurations for OpenID Connect
class PlatformDetector {
  /// Get the current platform as a string identifier
  static String getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Check if the current platform is mobile (Android or iOS)
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Check if the current platform is desktop (macOS, Windows, or Linux)
  static bool get isDesktop => 
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// Check if the current platform is web
  static bool get isWeb => kIsWeb;

  /// Get platform-specific app identifier
  static String getAppIdentifier({
    required String basePackageName,
    String? environment,
  }) {
    final env = environment != null ? '.$environment' : '';
    
    switch (getCurrentPlatform()) {
      case 'android':
      case 'ios':
        return '$basePackageName$env';
      case 'web':
        return basePackageName;
      case 'macos':
      case 'windows':
      case 'linux':
        return '$basePackageName.desktop$env';
      default:
        return basePackageName;
    }
  }

  /// Get platform-specific redirect URI scheme
  static String getRedirectScheme({
    required String basePackageName,
    String? environment,
  }) {
    final identifier = getAppIdentifier(
      basePackageName: basePackageName,
      environment: environment,
    );
    
    switch (getCurrentPlatform()) {
      case 'android':
      case 'ios':
        return '$identifier://oauth';
      case 'web':
        return 'https'; // or http for development
      case 'macos':
      case 'windows':
      case 'linux':
        return 'http://localhost:8080';
      default:
        return 'http://localhost:8080';
    }
  }

  /// Get platform-specific user agent string
  static String getUserAgent() {
    final platform = getCurrentPlatform();
    final version = '1.0.0'; // Replace with actual app version
    
    switch (platform) {
      case 'android':
        return 'TraCuuGcn/$version (Android)';
      case 'ios':
        return 'TraCuuGcn/$version (iOS)';
      case 'web':
        return 'TraCuuGcn/$version (Web)';
      case 'macos':
        return 'TraCuuGcn/$version (macOS)';
      case 'windows':
        return 'TraCuuGcn/$version (Windows)';
      case 'linux':
        return 'TraCuuGcn/$version (Linux)';
      default:
        return 'TraCuuGcn/$version';
    }
  }

  /// Check if platform supports custom URL schemes
  static bool get supportsCustomUrlSchemes => isMobile;

  /// Check if platform supports system browser
  static bool get supportsSystemBrowser => !kIsWeb;

  /// Check if platform supports embedded browser/webview
  static bool get supportsEmbeddedBrowser => isMobile;

  /// Get recommended browser type for the platform
  static String getRecommendedBrowserType() {
    switch (getCurrentPlatform()) {
      case 'android':
        return 'chrome_custom_tabs';
      case 'ios':
        return 'safari_view_controller';
      case 'web':
        return 'embedded';
      case 'macos':
      case 'windows':
      case 'linux':
        return 'system_browser';
      default:
        return 'system_browser';
    }
  }

  /// Get platform-specific authentication flow preferences
  static Map<String, dynamic> getAuthFlowPreferences() {
    final platform = getCurrentPlatform();
    
    switch (platform) {
      case 'android':
        return {
          'use_custom_tabs': true,
          'use_webview': false,
          'prefer_ephemeral_session': false,
          'supports_pkce': true,
          'supports_state': true,
        };
      case 'ios':
        return {
          'use_safari_view_controller': true,
          'use_webview': false,
          'prefer_ephemeral_session': true,
          'supports_pkce': true,
          'supports_state': true,
        };
      case 'web':
        return {
          'use_popup': false,
          'use_redirect': true,
          'silent_renew': true,
          'supports_pkce': true,
          'supports_state': true,
        };
      case 'macos':
      case 'windows':
      case 'linux':
        return {
          'use_system_browser': true,
          'local_server_port': 8080,
          'supports_pkce': true,
          'supports_state': true,
        };
      default:
        return {
          'supports_pkce': true,
          'supports_state': true,
        };
    }
  }

  /// Get platform-specific security requirements
  static Map<String, dynamic> getSecurityRequirements() {
    final platform = getCurrentPlatform();
    
    switch (platform) {
      case 'android':
      case 'ios':
        return {
          'require_https': true,
          'allow_insecure_localhost': true,
          'use_secure_storage': true,
          'validate_certificates': true,
          'require_client_secret': false,
        };
      case 'web':
        return {
          'require_https': true,
          'allow_insecure_localhost': false,
          'use_secure_cookies': true,
          'validate_certificates': true,
          'require_client_secret': true,
          'same_site_cookies': 'strict',
        };
      case 'macos':
      case 'windows':
      case 'linux':
        return {
          'require_https': true,
          'allow_insecure_localhost': true,
          'use_secure_storage': true,
          'validate_certificates': true,
          'require_client_secret': false,
        };
      default:
        return {
          'require_https': true,
          'validate_certificates': true,
        };
    }
  }

  /// Get platform-specific storage recommendations
  static Map<String, dynamic> getStorageRecommendations() {
    final platform = getCurrentPlatform();
    
    switch (platform) {
      case 'android':
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
          'keystore': 'android_keystore',
          'biometric_auth': true,
        };
      case 'ios':
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
          'keystore': 'ios_keychain',
          'biometric_auth': true,
        };
      case 'web':
        return {
          'token_storage': 'secure_http_only_cookies',
          'cache_storage': 'local_storage',
          'session_storage': 'session_storage',
          'biometric_auth': false,
        };
      case 'macos':
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
          'keystore': 'macos_keychain',
          'biometric_auth': true,
        };
      case 'windows':
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
          'keystore': 'windows_credential_store',
          'biometric_auth': false,
        };
      case 'linux':
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
          'keystore': 'linux_secret_service',
          'biometric_auth': false,
        };
      default:
        return {
          'token_storage': 'flutter_secure_storage',
          'cache_storage': 'shared_preferences',
        };
    }
  }

  /// Debug information about the current platform
  static Map<String, dynamic> getDebugInfo() {
    return {
      'platform': getCurrentPlatform(),
      'is_mobile': isMobile,
      'is_desktop': isDesktop,
      'is_web': isWeb,
      'supports_custom_schemes': supportsCustomUrlSchemes,
      'supports_system_browser': supportsSystemBrowser,
      'supports_embedded_browser': supportsEmbeddedBrowser,
      'recommended_browser': getRecommendedBrowserType(),
      'user_agent': getUserAgent(),
      'auth_flow_preferences': getAuthFlowPreferences(),
      'security_requirements': getSecurityRequirements(),
      'storage_recommendations': getStorageRecommendations(),
    };
  }
}

/// Extension methods for easier platform detection
extension PlatformExtensions on String {
  bool get isAndroid => this == 'android';
  bool get isIOS => this == 'ios';
  bool get isWeb => this == 'web';
  bool get isMacOS => this == 'macos';
  bool get isWindows => this == 'windows';
  bool get isLinux => this == 'linux';
  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isMacOS || isWindows || isLinux;
}
