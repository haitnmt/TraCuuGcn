// Storage interface cho việc lưu trữ dữ liệu xác thực
abstract class AuthStorage {
  Future<void> storeToken(String key, String token);
  Future<String?> getToken(String key);
  Future<void> removeToken(String key);
  Future<void> storeUser(String user);
  Future<String?> getUser();
  Future<void> removeUser();
  Future<void> clear();
}

// Secure storage implementation (sẽ được implement cụ thể cho từng platform)
class SecureAuthStorage implements AuthStorage {
  // TODO: Implement using flutter_secure_storage or similar
  
  @override
  Future<void> storeToken(String key, String token) async {
    // Implement secure token storage
    print("Storing token securely: $key");
  }

  @override
  Future<String?> getToken(String key) async {
    // Implement secure token retrieval
    print("Getting token securely: $key");
    return null;
  }

  @override
  Future<void> removeToken(String key) async {
    // Implement secure token removal
    print("Removing token securely: $key");
  }

  @override
  Future<void> storeUser(String user) async {
    // Implement secure user storage
    print("Storing user securely");
  }

  @override
  Future<String?> getUser() async {
    // Implement secure user retrieval
    print("Getting user securely");
    return null;
  }

  @override
  Future<void> removeUser() async {
    // Implement secure user removal
    print("Removing user securely");
  }

  @override
  Future<void> clear() async {
    // Implement secure storage clear
    print("Clearing secure storage");
  }
}

// Regular storage implementation (for non-sensitive data)
class RegularAuthStorage implements AuthStorage {
  // TODO: Implement using SharedPreferences or similar
  
  @override
  Future<void> storeToken(String key, String token) async {
    // Implement regular token storage
    print("Storing token: $key");
  }

  @override
  Future<String?> getToken(String key) async {
    // Implement regular token retrieval
    print("Getting token: $key");
    return null;
  }

  @override
  Future<void> removeToken(String key) async {
    // Implement regular token removal
    print("Removing token: $key");
  }

  @override
  Future<void> storeUser(String user) async {
    // Implement regular user storage
    print("Storing user");
  }

  @override
  Future<String?> getUser() async {
    // Implement regular user retrieval
    print("Getting user");
    return null;
  }

  @override
  Future<void> removeUser() async {
    // Implement regular user removal
    print("Removing user");
  }

  @override
  Future<void> clear() async {
    // Implement regular storage clear
    print("Clearing storage");
  }
}
