import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Utility class to read INI configuration files
class IniReader {
  static final Map<String, Map<String, Map<String, String>>> _cache = {};
  
  /// Read INI file from assets
  static Future<Map<String, Map<String, String>>> readFromAssets(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }
    
    try {
      final content = await rootBundle.loadString(path);
      final parsed = _parseIniContent(content);
      _cache[path] = parsed;
      return parsed;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading INI file from assets: $e');
      }
      return {};
    }
  }
  
  /// Read INI file from file system (for desktop platforms)
  static Future<Map<String, Map<String, String>>> readFromFile(String filePath) async {
    if (_cache.containsKey(filePath)) {
      return _cache[filePath]!;
    }
    
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('INI file not found: $filePath');
        }
        return {};
      }
      
      final content = await file.readAsString();
      final parsed = _parseIniContent(content);
      _cache[filePath] = parsed;
      return parsed;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading INI file: $e');
      }
      return {};
    }
  }
  
  /// Parse INI content into a nested map
  static Map<String, Map<String, String>> _parseIniContent(String content) {
    final Map<String, Map<String, String>> result = {};
    String currentSection = '';
    
    final lines = content.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      
      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) {
        continue;
      }
      
      // Check if it's a section header
      if (line.endsWith(':')) {
        currentSection = line.substring(0, line.length - 1).trim();
        result[currentSection] = {};
        continue;
      }
      
      // Check if it's a key-value pair
      if (line.contains(':')) {
        final colonIndex = line.indexOf(':');
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        
        if (currentSection.isNotEmpty) {
          result[currentSection]![key] = value;
        } else {
          // If no section, put it in a default section
          result.putIfAbsent('default', () => {})[key] = value;
        }
      }
    }
    
    return result;
  }
  
  /// Get a value from the parsed INI data
  static String? getValue(
    Map<String, Map<String, String>> iniData,
    String section,
    String key,
    [String? defaultValue]
  ) {
    return iniData[section]?[key] ?? defaultValue;
  }
  
  /// Clear the cache
  static void clearCache() {
    _cache.clear();
  }
}

/// OpenID configuration loaded from INI file
class OpenIdIniConfig {
  final Map<String, Map<String, String>> _iniData;
  
  const OpenIdIniConfig(this._iniData);
  
  /// Load configuration from INI file
  static Future<OpenIdIniConfig> load({String? customPath, String? environment}) async {
    Map<String, Map<String, String>> iniData;
    
    if (customPath != null) {
      iniData = await IniReader.readFromFile(customPath);
    } else {
      // Priority order for config loading (external files only):
      // 1. Environment-specific external config (configs/openid.{env}.ini)
      // 2. General external config (configs/openid.ini)
      
      final configPaths = <String>[];
      
      // Get current directory and try multiple relative paths
      final currentDir = Directory.current.path;
      if (kDebugMode) {
        print('Current directory: $currentDir');
      }
      
      // External config paths - try various locations
      // From Flutter app directory, configs folder is at ../../../configs/
      if (environment != null) {
        configPaths.add('configs/openid.$environment.ini');
        configPaths.add('../configs/openid.$environment.ini');
      }
      configPaths.add('configs/openid.ini');
      configPaths.add('../configs/openid.ini');
            
      iniData = {};
      bool loaded = false;
      
      // Try to load from external files only
      for (String path in configPaths) {
        try {
          final file = File(path);
          if (await file.exists()) {
            iniData = await IniReader.readFromFile(path);
            if (iniData.isNotEmpty) {
              if (kDebugMode) {
                print('Loaded OpenID config from: ${file.absolute.path}');
              }
              loaded = true;
              break;
            }
          } else {
            if (kDebugMode) {
              print('Config file not found: ${file.absolute.path}');
            }
          }
        } catch (e) {
          // Continue to next path
          if (kDebugMode) {
            print('Could not load config from $path: $e');
          }
        }
      }
      
      if (!loaded) {
        if (kDebugMode) {
          print('Warning: No OpenID config file found in any location, using default values');
          print('Searched paths relative to: $currentDir');
        }
        
        // Try to create a default config file
        final defaultConfigPath = await createDefaultConfigFile();
        if (defaultConfigPath != null) {
          try {
            iniData = await IniReader.readFromFile(defaultConfigPath);
            if (iniData.isNotEmpty) {
              loaded = true;
              if (kDebugMode) {
                print('Loaded from newly created default config: $defaultConfigPath');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('Could not load from default config: $e');
            }
          }
        }
      }
    }
    
    return OpenIdIniConfig(iniData);
  }
  
  /// Create a default config file if none exists
  static Future<String?> createDefaultConfigFile() async {
    try {
      // Try to create in the project root configs directory first
      final projectRootConfigDir = Directory('../../../configs');
      final projectRootConfigFile = File('../../../configs/openid.ini');
      
      if (!await projectRootConfigDir.exists()) {
        await projectRootConfigDir.create(recursive: true);
      }
      
      if (!await projectRootConfigFile.exists()) {
        const defaultConfig = '''OpenId:
ssoIssuer: https://sso.demo.com/realms/demo/
ssoClientId: flutter-tracuugcn
ssoClientSecret: 
azureIssuer: https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0
azureClientId: 
azureClientSecret: 
googleIssuer: https://accounts.google.com
googleClientId: 
googleClientSecret: 
appleIssuer: https://appleid.apple.com
appleClientId: 
appleClientSecret: 
DesktopLocalUrl: http://localhost:8080
WebUrl: http://localhost:3000
AppAuthRedirectScheme: vn.haihv.tracuugcn
''';
        await projectRootConfigFile.writeAsString(defaultConfig);
        if (kDebugMode) {
          print('Created default config file: ${projectRootConfigFile.absolute.path}');
        }
        return projectRootConfigFile.path;
      }
      
      // If project root doesn't work, try local configs directory
      final localConfigDir = Directory('configs');
      final localConfigFile = File('configs/openid.ini');
      
      if (!await localConfigDir.exists()) {
        await localConfigDir.create(recursive: true);
      }
      
      if (!await localConfigFile.exists()) {
        const defaultConfig = '''OpenId:
ssoIssuer: https://sso.demo.com/realms/demo/
ssoClientId: flutter-tracuugcn
ssoClientSecret: 
azureIssuer: https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0
azureClientId: 
azureClientSecret: 
googleIssuer: https://accounts.google.com
googleClientId: 
googleClientSecret: 
appleIssuer: https://appleid.apple.com
appleClientId: 
appleClientSecret: 
DesktopLocalUrl: http://localhost:8080
WebUrl: http://localhost:3000
AppAuthRedirectScheme: vn.haihv.tracuugcn
''';
        await localConfigFile.writeAsString(defaultConfig);
        if (kDebugMode) {
          print('Created default config file: ${localConfigFile.absolute.path}');
        }
        return localConfigFile.path;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Could not create default config file: $e');
      }
    }
    return null;
  }

  // SSO/Keycloak Configuration
  String get ssoIssuer => IniReader.getValue(_iniData, 'OpenId', 'ssoIssuer') ?? 'https://sso.demo.com/realms/demo/';
  String get ssoClientId => IniReader.getValue(_iniData, 'OpenId', 'ssoClientId') ?? 'flutter-tracuugcn';
  String get ssoClientSecret => IniReader.getValue(_iniData, 'OpenId', 'ssoClientSecret') ?? '';
  
  // Azure AD Configuration
  String get azureIssuer => IniReader.getValue(_iniData, 'OpenId', 'azureIssuer') ?? 'https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0';
  String get azureClientId => IniReader.getValue(_iniData, 'OpenId', 'azureClientId') ?? '';
  String get azureClientSecret => IniReader.getValue(_iniData, 'OpenId', 'azureClientSecret') ?? '';
  
  // Google OAuth Configuration
  String get googleIssuer => IniReader.getValue(_iniData, 'OpenId', 'googleIssuer') ?? 'https://accounts.google.com';
  String get googleClientId => IniReader.getValue(_iniData, 'OpenId', 'googleClientId') ?? '';
  String get googleClientSecret => IniReader.getValue(_iniData, 'OpenId', 'googleClientSecret') ?? '';
  
  // Apple OAuth Configuration
  String get appleIssuer => IniReader.getValue(_iniData, 'OpenId', 'appleIssuer') ?? 'https://appleid.apple.com';
  String get appleClientId => IniReader.getValue(_iniData, 'OpenId', 'appleClientId') ?? '';
  String get appleClientSecret => IniReader.getValue(_iniData, 'OpenId', 'appleClientSecret') ?? '';
  
  // Application URLs
  String get desktopLocalUrl => IniReader.getValue(_iniData, 'OpenId', 'DesktopLocalUrl') ?? 'http://localhost:8080';
  String get webUrl => IniReader.getValue(_iniData, 'OpenId', 'WebUrl') ?? 'http://localhost:3000';
  String get appAuthRedirectScheme => IniReader.getValue(_iniData, 'OpenId', 'AppAuthRedirectScheme') ?? 'vn.haihv.tracuugcn';
  
  /// Check if configuration is loaded and valid
  bool get isValid => _iniData.isNotEmpty && _iniData.containsKey('OpenId');
  
  /// Get all configuration as a map for debugging
  Map<String, dynamic> toMap() {
    return {
      'ssoIssuer': ssoIssuer,
      'ssoClientId': ssoClientId,
      'ssoClientSecret': ssoClientSecret.isNotEmpty ? '***' : '',
      'azureIssuer': azureIssuer,
      'azureClientId': azureClientId,
      'azureClientSecret': azureClientSecret.isNotEmpty ? '***' : '',
      'googleIssuer': googleIssuer,
      'googleClientId': googleClientId,
      'googleClientSecret': googleClientSecret.isNotEmpty ? '***' : '',
      'appleIssuer': appleIssuer,
      'appleClientId': appleClientId,
      'appleClientSecret': appleClientSecret.isNotEmpty ? '***' : '',
      'desktopLocalUrl': desktopLocalUrl,
      'webUrl': webUrl,
      'appAuthRedirectScheme': appAuthRedirectScheme,
    };
  }

  /// Get debug information about config loading
  Map<String, dynamic> getDebugInfo() {
    return {
      'configLoaded': isValid,
      'configSections': _iniData.keys.toList(),
      'openIdKeysFound': _iniData['OpenId']?.keys.toList() ?? [],
      'totalKeys': _iniData.values.fold<int>(0, (sum, section) => sum + section.length),
    };
  }
}
