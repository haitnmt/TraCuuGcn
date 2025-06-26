import 'package:flutter/foundation.dart';
import 'utils/platform_detector.dart';
import 'utils/ini_reader.dart';

/// OpenID Connect Configuration for TraCuuGcn App
/// 
/// This file contains configurations for various OpenID Connect providers
/// optimized for different platforms (Android, iOS, Web, Desktop)
/// Configuration is loaded from openid.ini file

// MARK: - Configuration Constants
/// OpenID Connect URLs loaded from INI file
class OpenIdUrls {
  static OpenIdIniConfig? _iniConfig;
  
  static Future<void> _ensureConfigLoaded() async {
    _iniConfig ??= await OpenIdIniConfig.load();
  }
  
  // Keycloak/SSO URLs
  static Future<String> get keycloakIssuer async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoIssuer ?? 'https://sso.vpdkbacninh.vn/realms/vpdk/';
  }
  
  // Legacy getters for backward compatibility
  static Future<String> get keycloakDevIssuer => keycloakIssuer;
  static Future<String> get keycloakProdIssuer => keycloakIssuer;
  static Future<String> get keycloakLocalIssuer => keycloakIssuer;
  
  // Azure AD URLs
  static Future<String> get azureIssuer async {
    await _ensureConfigLoaded();
    return _iniConfig?.azureIssuer ?? 'https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0';
  }
  
  // Google OAuth URLs
  static Future<String> get googleIssuer async {
    await _ensureConfigLoaded();
    return _iniConfig?.googleIssuer ?? 'https://accounts.google.com';
  }
  
  // Apple OAuth URLs
  static Future<String> get appleIssuer async {
    await _ensureConfigLoaded();
    return _iniConfig?.appleIssuer ?? 'https://appleid.apple.com';
  }
  
  // Web URLs
  static Future<String> get webUrl async {
    await _ensureConfigLoaded();
    return _iniConfig?.webUrl ?? 'http://localhost:3000';
  }
  
  static String get webDevUrl => 'http://localhost:3000'; // For dev only
  static String get webProdUrl => 'https://tracuugcn.vpdkbacninh.vn'; // Production URL
  
  static Future<String> get desktopLocalUrl async {
    await _ensureConfigLoaded();
    return _iniConfig?.desktopLocalUrl ?? 'http://localhost:8080';
  }
}

/// Client IDs for different environments and platforms loaded from INI file
class ClientIds {
  static OpenIdIniConfig? _iniConfig;
  
  static Future<void> _ensureConfigLoaded() async {
    _iniConfig ??= await OpenIdIniConfig.load();
  }
  
  // Keycloak Client IDs - using SSO config from INI
  static Future<String> get keycloakDev async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoClientId ?? 'flutter-tracuugcn-dev';
  }
  
  static Future<String> get keycloakProd async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoClientId ?? 'tracuugcn-app';
  }
  
  static Future<String> get keycloakLocal async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoClientId ?? 'tracuugcn-app-local';
  }
  
  // Client Secrets (only for web platform)
  static Future<String> get keycloakDevSecret async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoClientSecret ?? '';
  }
  
  static Future<String> get keycloakProdSecret async {
    await _ensureConfigLoaded();
    return _iniConfig?.ssoClientSecret ?? '';
  }
  
  // Azure AD Client ID
  static Future<String> get azureClientId async {
    await _ensureConfigLoaded();
    return _iniConfig?.azureClientId ?? '';
  }
  
  static Future<String> get azureClientSecret async {
    await _ensureConfigLoaded();
    return _iniConfig?.azureClientSecret ?? '';
  }
  
  // Google OAuth Client IDs
  static Future<String> get googleClientId async {
    await _ensureConfigLoaded();
    return _iniConfig?.googleClientId ?? '';
  }
  
  static Future<String> get googleClientSecret async {
    await _ensureConfigLoaded();
    return _iniConfig?.googleClientSecret ?? '';
  }
  
  // Apple OAuth Client IDs
  static Future<String> get appleClientId async {
    await _ensureConfigLoaded();
    return _iniConfig?.appleClientId ?? 'com.example.tracuugcn';
  }
  
  static Future<String> get appleClientSecret async {
    await _ensureConfigLoaded();
    return _iniConfig?.appleClientSecret ?? '';
  }
  
  // Platform-specific Google Client IDs (fallback to main google client id)
  static Future<String> get googleAndroidClientId async => await googleClientId;
  static Future<String> get googleIosClientId async => await googleClientId;
  static Future<String> get googleWebClientId async => await googleClientId;
  static Future<String> get googleDesktopClientId async => await googleClientId;
}

/// App Package/Bundle Identifiers loaded from INI file
class AppIdentifiers {
  static OpenIdIniConfig? _iniConfig;
  
  static Future<void> _ensureConfigLoaded() async {
    _iniConfig ??= await OpenIdIniConfig.load();
  }
  
  static Future<String> get packageName async {
    await _ensureConfigLoaded();
    return _iniConfig?.appAuthRedirectScheme ?? 'vn.haihv.tracuugcn';
  }
  
  static Future<String> get bundleId async {
    await _ensureConfigLoaded();
    return _iniConfig?.appAuthRedirectScheme ?? 'vn.haihv.tracuugcn';
  }
}

/// Default Scopes for different providers
class DefaultScopes {
  static const List<String> keycloakBasic = ['openid', 'profile', 'email'];
  static const List<String> keycloakWithRoles = ['openid', 'profile', 'email', 'roles'];
  static const List<String> keycloakWithOfflineAccess = ['openid', 'profile', 'email', 'roles', 'offline_access'];
  static const List<String> azure = ['openid', 'profile', 'email', 'User.Read'];
  static const List<String> google = ['openid', 'profile', 'email'];
}

/// Port configurations
class PortConfig {
  static const int desktopAuthPort = 8080;
  static const int webDevPort = 3000;
}

// MARK: - Base Configuration Class
class OpenIdConfig {
  final String issuer;
  final String clientId;
  final String? clientSecret;
  final List<String> scopes;
  final String redirectUri;
  final String? postLogoutRedirectUri;
  final Map<String, String>? additionalParameters;
  final bool allowInsecureConnections;
  final Map<String, dynamic>? platformSpecificConfig;

  const OpenIdConfig({
    required this.issuer,
    required this.clientId,
    this.clientSecret,
    required this.scopes,
    required this.redirectUri,
    this.postLogoutRedirectUri,
    this.additionalParameters,
    this.allowInsecureConnections = false,
    this.platformSpecificConfig,
  });

  Map<String, dynamic> toJson() {
    return {
      'issuer': issuer,
      'clientId': clientId,
      'clientSecret': clientSecret,
      'scopes': scopes,
      'redirectUri': redirectUri,
      'postLogoutRedirectUri': postLogoutRedirectUri,
      'additionalParameters': additionalParameters,
      'allowInsecureConnections': allowInsecureConnections,
      'platformSpecificConfig': platformSpecificConfig,
    };
  }

  factory OpenIdConfig.fromJson(Map<String, dynamic> json) {
    return OpenIdConfig(
      issuer: json['issuer'] ?? '',
      clientId: json['clientId'] ?? '',
      clientSecret: json['clientSecret'],
      scopes: (json['scopes'] as List?)?.cast<String>() ?? ['openid', 'profile', 'email'],
      redirectUri: json['redirectUri'] ?? '',
      postLogoutRedirectUri: json['postLogoutRedirectUri'],
      additionalParameters: (json['additionalParameters'] as Map?)?.cast<String, String>(),
      allowInsecureConnections: json['allowInsecureConnections'] ?? false,
      platformSpecificConfig: json['platformSpecificConfig'] as Map<String, dynamic>?,
    );
  }
}

// MARK: - Platform Detection
class PlatformConfig {
  static const String android = 'android';
  static const String ios = 'ios';
  static const String web = 'web';
  static const String macos = 'macos';
  static const String windows = 'windows';
  static const String linux = 'linux';
}

// MARK: - Keycloak Configuration
class KeycloakConfigs {
  // Development Environment
  static Future<OpenIdConfig> development({required String platform}) async {
    final iniConfig = await OpenIdIniConfig.load();
    final baseRedirectUri = await _getRedirectUri('dev', platform, iniConfig);
    
    return OpenIdConfig(
      issuer: iniConfig.ssoIssuer,
      clientId: iniConfig.ssoClientId,
      clientSecret: (platform == PlatformConfig.web || platform == PlatformConfig.windows) ? iniConfig.ssoClientSecret : null,
      scopes: DefaultScopes.keycloakWithRoles,
      redirectUri: baseRedirectUri,
      postLogoutRedirectUri: await _getPostLogoutRedirectUri('dev', platform, iniConfig),
      additionalParameters: {
        'response_mode': 'query',
      },
      allowInsecureConnections: true, // Only for development
      platformSpecificConfig: await _getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  // Production Environment
  static Future<OpenIdConfig> production({required String platform}) async {
    final iniConfig = await OpenIdIniConfig.load();
    final baseRedirectUri = await _getRedirectUri('prod', platform, iniConfig);
    
    return OpenIdConfig(
      issuer: iniConfig.ssoIssuer,
      clientId: iniConfig.ssoClientId,
      clientSecret: platform == PlatformConfig.web ? iniConfig.ssoClientSecret : null,
      scopes: DefaultScopes.keycloakWithOfflineAccess,
      redirectUri: baseRedirectUri,
      postLogoutRedirectUri: await _getPostLogoutRedirectUri('prod', platform, iniConfig),
      additionalParameters: {
        'response_mode': 'query',
        'prompt': 'login',
      },
      allowInsecureConnections: false,
      platformSpecificConfig: await _getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  // Local Development
  static Future<OpenIdConfig> localhost({required String platform}) async {
    final iniConfig = await OpenIdIniConfig.load();
    final baseRedirectUri = await _getRedirectUri('local', platform, iniConfig);
    
    return OpenIdConfig(
      issuer: iniConfig.ssoIssuer,
      clientId: iniConfig.ssoClientId,
      scopes: DefaultScopes.keycloakBasic,
      redirectUri: baseRedirectUri,
      postLogoutRedirectUri: await _getPostLogoutRedirectUri('local', platform, iniConfig),
      allowInsecureConnections: true,
      platformSpecificConfig: await _getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  static Future<String> _getRedirectUri(String env, String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
        return '$packageName.$env://oauth/callback';
      case PlatformConfig.ios:
        return '$packageName.$env://oauth/callback';
      case PlatformConfig.web:
        switch (env) {
          case 'dev':
            return '${iniConfig.webUrl}/auth/callback';
          case 'prod':
            return '${OpenIdUrls.webProdUrl}/auth/callback';
          case 'local':
            return '${iniConfig.webUrl}/auth/callback';
          default:
            return '${iniConfig.webUrl}/auth/callback';
        }
      case PlatformConfig.macos:
      case PlatformConfig.windows:
      case PlatformConfig.linux:
        return '${iniConfig.desktopLocalUrl}/auth/callback';
      default:
        return '${iniConfig.desktopLocalUrl}/auth/callback';
    }
  }

  static Future<String> _getPostLogoutRedirectUri(String env, String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
      case PlatformConfig.ios:
        return '$packageName.$env://logout/callback';
      case PlatformConfig.web:
        switch (env) {
          case 'dev':
            return '${iniConfig.webUrl}/';
          case 'prod':
            return '${OpenIdUrls.webProdUrl}/';
          case 'local':
            return '${iniConfig.webUrl}/';
          default:
            return '${iniConfig.webUrl}/';
        }
      default:
        return '${iniConfig.desktopLocalUrl}/';
    }
  }

  static Future<Map<String, dynamic>> _getPlatformSpecificConfig(String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
        return {
          'browser_type': 'chrome_custom_tabs',
          'use_webview': false,
          'package_name': packageName,
        };
      case PlatformConfig.ios:
        return {
          'browser_type': 'safari_view_controller',
          'use_webview': false,
          'bundle_id': packageName,
        };
      case PlatformConfig.web:
        return {
          'popup_mode': false,
          'silent_renew': true,
          'automatic_silent_renew': true,
        };
      case PlatformConfig.macos:
      case PlatformConfig.windows:
      case PlatformConfig.linux:
        return {
          'use_system_browser': true,
          'local_port': PortConfig.desktopAuthPort,
        };
      default:
        return {};
    }
  }
}

// MARK: - Azure AD Configuration
class AzureAdConfigs {
  static Future<OpenIdConfig> enterprise({required String platform}) async {
    final iniConfig = await OpenIdIniConfig.load();
    final baseRedirectUri = await _getAzureRedirectUri(platform, iniConfig);
    
    return OpenIdConfig(
      issuer: iniConfig.azureIssuer,
      clientId: iniConfig.azureClientId,
      scopes: DefaultScopes.azure,
      redirectUri: baseRedirectUri,
      postLogoutRedirectUri: await _getAzurePostLogoutUri(platform, iniConfig),
      additionalParameters: {
        'response_type': 'code',
        'response_mode': 'query',
        'prompt': 'select_account',
      },
      platformSpecificConfig: await KeycloakConfigs._getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  static Future<String> _getAzureRedirectUri(String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
        return 'msauth://$packageName/YOUR_SIGNATURE_HASH';
      case PlatformConfig.ios:
        return 'msauth.$packageName://auth';
      case PlatformConfig.web:
        return '${OpenIdUrls.webProdUrl}/auth/azure/callback';
      default:
        return '${iniConfig.desktopLocalUrl}/auth/azure/callback';
    }
  }

  static Future<String> _getAzurePostLogoutUri(String platform, OpenIdIniConfig iniConfig) async {
    switch (platform) {
      case PlatformConfig.web:
        return '${OpenIdUrls.webProdUrl}/';
      default:
        return '${iniConfig.desktopLocalUrl}/';
    }
  }
}

// MARK: - Google OAuth Configuration
class GoogleOAuthConfigs {
  static Future<OpenIdConfig> standard({required String platform}) async {
    final iniConfig = await OpenIdIniConfig.load();
    
    return OpenIdConfig(
      issuer: iniConfig.googleIssuer,
      clientId: await _getGoogleClientId(platform, iniConfig),
      scopes: DefaultScopes.google,
      redirectUri: await _getGoogleRedirectUri(platform, iniConfig),
      additionalParameters: {
        'access_type': 'offline',
        'include_granted_scopes': 'true',
      },
      platformSpecificConfig: await KeycloakConfigs._getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  static Future<String> _getGoogleClientId(String platform, OpenIdIniConfig iniConfig) async {
    // All platforms use the same client ID from INI
    return iniConfig.googleClientId;
  }

  static Future<String> _getGoogleRedirectUri(String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
        return '$packageName:/oauth2redirect';
      case PlatformConfig.ios:
        return '$packageName:/oauth2redirect';
      case PlatformConfig.web:
        return '${OpenIdUrls.webProdUrl}/auth/google/callback';
      default:
        return '${iniConfig.desktopLocalUrl}/auth/google/callback';
    }
  }
}

// MARK: - Generic OIDC Provider Configuration
class GenericOidcConfigs {
  static Future<OpenIdConfig> custom({
    required String issuer,
    required String clientId,
    String? clientSecret,
    required String platform,
    List<String>? customScopes,
    Map<String, String>? customParameters,
  }) async {
    final iniConfig = await OpenIdIniConfig.load();
    
    return OpenIdConfig(
      issuer: issuer,
      clientId: clientId,
      clientSecret: clientSecret,
      scopes: customScopes ?? DefaultScopes.keycloakBasic,
      redirectUri: await _getCustomRedirectUri(platform, iniConfig),
      postLogoutRedirectUri: await _getCustomPostLogoutUri(platform, iniConfig),
      additionalParameters: customParameters,
      platformSpecificConfig: await KeycloakConfigs._getPlatformSpecificConfig(platform, iniConfig),
    );
  }

  static Future<String> _getCustomRedirectUri(String platform, OpenIdIniConfig iniConfig) async {
    final packageName = iniConfig.appAuthRedirectScheme;
    
    switch (platform) {
      case PlatformConfig.android:
      case PlatformConfig.ios:
        return '$packageName://oauth/callback';
      case PlatformConfig.web:
        return '${OpenIdUrls.webProdUrl}/auth/callback';
      default:
        return '${iniConfig.desktopLocalUrl}/auth/callback';
    }
  }

  static Future<String> _getCustomPostLogoutUri(String platform, OpenIdIniConfig iniConfig) async {
    switch (platform) {
      case PlatformConfig.web:
        return '${OpenIdUrls.webProdUrl}/';
      default:
        return '${iniConfig.desktopLocalUrl}/';
    }
  }
}

// MARK: - Configuration Factory
class OpenIdConfigFactory {
  static Future<OpenIdConfig> getConfig({
    required String provider,
    required String environment,
    required String platform,
    Map<String, dynamic>? customConfig,
  }) async {
    switch (provider.toLowerCase()) {
      case 'keycloak':
        switch (environment.toLowerCase()) {
          case 'development':
          case 'dev':
            return await KeycloakConfigs.development(platform: platform);
          case 'production':
          case 'prod':
            return await KeycloakConfigs.production(platform: platform);
          case 'localhost':
          case 'local':
            return await KeycloakConfigs.localhost(platform: platform);
          default:
            return await KeycloakConfigs.development(platform: platform);
        }
      case 'azure':
      case 'azuread':
        return await AzureAdConfigs.enterprise(platform: platform);
      case 'google':
        return await GoogleOAuthConfigs.standard(platform: platform);
      case 'custom':
        if (customConfig != null) {
          return await GenericOidcConfigs.custom(
            issuer: customConfig['issuer'] ?? '',
            clientId: customConfig['clientId'] ?? '',
            clientSecret: customConfig['clientSecret'],
            platform: platform,
            customScopes: customConfig['scopes']?.cast<String>(),
            customParameters: customConfig['additionalParameters']?.cast<String, String>(),
          );
        }
        throw ArgumentError('Custom config requires customConfig parameter');
      default:
        throw ArgumentError('Unsupported provider: $provider');
    }
  }
}

// MARK: - Auto-Configuration Helper
class AutoOpenIdConfig {
  /// Automatically configure OpenID based on current platform and environment
  static Future<OpenIdConfig> auto({
    required String provider,
    String? environment,
    Map<String, dynamic>? customConfig,
  }) async {
    final currentPlatform = PlatformDetector.getCurrentPlatform();
    final env = environment ?? (kDebugMode ? 'development' : 'production');
    
    return await OpenIdConfigFactory.getConfig(
      provider: provider,
      environment: env,
      platform: currentPlatform,
      customConfig: customConfig,
    );
  }

  /// Get configuration with platform-specific optimizations
  static Future<OpenIdConfig> optimized({
    required String provider,
    String? environment,
    Map<String, dynamic>? customConfig,
  }) async {
    final config = await auto(
      provider: provider,
      environment: environment,
      customConfig: customConfig,
    );
    
    // Apply platform-specific optimizations
    final platformPrefs = PlatformDetector.getAuthFlowPreferences();
    final securityReqs = PlatformDetector.getSecurityRequirements();
    
    final optimizedConfig = {
      ...config.platformSpecificConfig ?? {},
      ...platformPrefs,
      'security_requirements': securityReqs,
    };
    
    return OpenIdConfig(
      issuer: config.issuer,
      clientId: config.clientId,
      clientSecret: config.clientSecret,
      scopes: config.scopes,
      redirectUri: config.redirectUri,
      postLogoutRedirectUri: config.postLogoutRedirectUri,
      additionalParameters: config.additionalParameters,
      allowInsecureConnections: config.allowInsecureConnections,
      platformSpecificConfig: optimizedConfig,
    );
  }
}

