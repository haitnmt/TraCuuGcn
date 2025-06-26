import 'package:flutter/foundation.dart';
import '../auth_manager.dart';
import '../models/auth_user.dart';
import '../models/auth_token.dart';
import '../services/appauth_service.dart';

class IOSAuth implements AuthProvider {
  final AppAuthService _appAuthService = AppAuthService();

  @override
  Future<void> authenticate({String? languageCode}) async {
    try {
      await _appAuthService.initialize();
      
      // Thử đăng nhập với Keycloak/SSO trước
      final token = await _appAuthService.signInWithKeycloak();
      
      if (token == null) {
        throw Exception('Authentication failed: No token received');
      }
      
      if (kDebugMode) {
        print('iOS authentication successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS authentication error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _appAuthService.logout();
      
      if (kDebugMode) {
        print('iOS logout successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('iOS logout error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final isAuth = await _appAuthService.isAuthenticated();
      return isAuth;
    } catch (e) {
      if (kDebugMode) {
        print('iOS isAuthenticated error: $e');
      }
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _appAuthService.getCurrentToken();
      return token?.accessToken;
    } catch (e) {
      if (kDebugMode) {
        print('iOS getToken error: $e');
      }
      return null;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = await _appAuthService.getCurrentUser();
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('iOS getCurrentUser error: $e');
      }
      return null;
    }
  }

  // iOS-specific methods
  Future<AuthToken?> signInWithGoogle() async {
    try {
      await _appAuthService.initialize();
      return await _appAuthService.signInWithGoogle();
    } catch (e) {
      if (kDebugMode) {
        print('iOS Google sign in error: $e');
      }
      rethrow;
    }
  }

  Future<AuthToken?> signInWithAzure() async {
    try {
      await _appAuthService.initialize();
      return await _appAuthService.signInWithAzure();
    } catch (e) {
      if (kDebugMode) {
        print('iOS Azure sign in error: $e');
      }
      rethrow;
    }
  }

  Future<AuthToken?> signInWithApple() async {
    try {
      await _appAuthService.initialize();
      // Apple Sign In would use Sign in with Apple framework
      // For now using OAuth flow as fallback
      return await _appAuthService.signInWithKeycloak();
    } catch (e) {
      if (kDebugMode) {
        print('iOS Apple sign in error: $e');
      }
      rethrow;
    }
  }

  Future<AuthToken?> refreshToken() async {
    try {
      return await _appAuthService.refreshToken();
    } catch (e) {
      if (kDebugMode) {
        print('iOS refresh token error: $e');
      }
      return null;
    }
  }
}
