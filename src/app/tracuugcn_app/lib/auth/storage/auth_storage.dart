import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Storage interface cho việc lưu trữ dữ liệu xác thực
abstract class AuthStorage {
  Future<void> storeToken(String key, String token);
  Future<String?> getToken(String key);
  Future<void> removeToken(String key);
  Future<void> storeUser(String user);
  Future<String?> getUser();
  Future<void> removeUser();
  Future<void> clear();
  
  // Secure storage methods
  Future<void> storeSecureData(String key, String data);
  Future<String?> getSecureData(String key);
  Future<void> deleteSecureData(String key);
}

// Secure storage implementation
class SecureAuthStorage implements AuthStorage {
  static const _secureStorage = FlutterSecureStorage();
  
  @override
  Future<void> storeToken(String key, String token) async {
    await _secureStorage.write(key: key, value: token);
  }

  @override
  Future<String?> getToken(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> removeToken(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> storeUser(String user) async {
    await _secureStorage.write(key: 'user_data', value: user);
  }

  @override
  Future<String?> getUser() async {
    return await _secureStorage.read(key: 'user_data');
  }

  @override
  Future<void> removeUser() async {
    await _secureStorage.delete(key: 'user_data');
  }

  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
  
  @override
  Future<void> storeSecureData(String key, String data) async {
    await _secureStorage.write(key: key, value: data);
  }

  @override
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }
}

// Regular storage implementation (for non-sensitive data)
class RegularAuthStorage implements AuthStorage {
  static SharedPreferences? _prefs;
  
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  @override
  Future<void> storeToken(String key, String token) async {
    final prefs = await _preferences;
    await prefs.setString(key, token);
  }

  @override
  Future<String?> getToken(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  @override
  Future<void> removeToken(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  @override
  Future<void> storeUser(String user) async {
    final prefs = await _preferences;
    await prefs.setString('user_data', user);
  }

  @override
  Future<String?> getUser() async {
    final prefs = await _preferences;
    return prefs.getString('user_data');
  }

  @override
  Future<void> removeUser() async {
    final prefs = await _preferences;
    await prefs.remove('user_data');
  }

  @override
  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
  
  @override
  Future<void> storeSecureData(String key, String data) async {
    // For regular storage, we'll just use SharedPreferences
    final prefs = await _preferences;
    await prefs.setString(key, data);
  }

  @override
  Future<String?> getSecureData(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  @override
  Future<void> deleteSecureData(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }
}

// Factory để tạo storage phù hợp
class AuthStorageFactory {
  static AuthStorage createSecure() => SecureAuthStorage();
  static AuthStorage createRegular() => RegularAuthStorage();
}
