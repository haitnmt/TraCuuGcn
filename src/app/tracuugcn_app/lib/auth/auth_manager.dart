import 'dart:io';
import 'package:flutter/foundation.dart';
import 'mobile/auth_android.dart';
import 'mobile/auth_ios.dart';
import 'desktop/auth_windows.dart';
import 'desktop/auth_macos.dart';
import 'web/auth_web.dart';

// Abstract interface for platform-specific auth implementations
abstract class AuthProvider {
  Future<void> authenticate();
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
}

// AuthManager acts as a bridge between platforms and the main app
class AuthManager {
  late final AuthProvider _authProvider;
  
  AuthManager() {
    _authProvider = _createAuthProvider();
  }
  
  // Factory method to create platform-specific auth provider
  AuthProvider _createAuthProvider() {
    if (kIsWeb) return WebAuth();
    if (Platform.isAndroid) return AndroidAuth();
    if (Platform.isIOS) return iOSAuth();
    if (Platform.isWindows) return WindowsAuth();
    if (Platform.isMacOS) return MacOSAuth();
    throw UnimplementedError('Platform not supported');
  }
  
  // Bridge methods that delegate to platform-specific implementation
  Future<void> authenticate() async {
    await _authProvider.authenticate();
  }
  
  Future<void> logout() async {
    await _authProvider.logout();
  }
  
  Future<bool> isAuthenticated() async {
    return await _authProvider.isAuthenticated();
  }
  
  Future<String?> getToken() async {
    return await _authProvider.getToken();
  }
  
  // Getter to access the auth provider (for platform-specific features)
  AuthProvider get authProvider => _authProvider;
  
  // Additional bridge methods for platform detection
  String getCurrentPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  bool isMobilePlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }
  
  bool isDesktopPlatform() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  bool isWebPlatform() {
    return kIsWeb;
  }
}