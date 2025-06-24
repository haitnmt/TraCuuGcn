import 'dart:io';
import 'package:flutter/foundation.dart';
import 'mobile/auth_android.dart';
import 'mobile/auth_ios.dart';
import 'desktop/auth_windows.dart';
import 'desktop/auth_macos.dart';
import 'web/auth_web.dart';

abstract class AuthManager {
  Future<void> authenticate();
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
  
  factory AuthManager() {
    if (kIsWeb) return WebAuth();
    if (Platform.isAndroid) return AndroidAuth();
    if (Platform.isIOS) return iOSAuth();
    if (Platform.isWindows) return WindowsAuth();
    if (Platform.isMacOS) return MacOSAuth();
    throw UnimplementedError();
  }
}