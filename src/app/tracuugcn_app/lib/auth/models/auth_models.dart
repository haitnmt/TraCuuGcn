// Auth state enumeration
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Auth result class
class AuthResult {
  final bool success;
  final String? message;
  final String? errorCode;
  final dynamic data;

  const AuthResult({
    required this.success,
    this.message,
    this.errorCode,
    this.data,
  });

  factory AuthResult.success({String? message, dynamic data}) {
    return AuthResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory AuthResult.failure({String? message, String? errorCode}) {
    return AuthResult(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, errorCode: $errorCode)';
  }
}

// Auth exception class
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

// Login credentials class
class LoginCredentials {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginCredentials({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

// Registration data class
class RegisterData {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String? fullName;
  final Map<String, dynamic>? additionalData;

  const RegisterData({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.fullName,
    this.additionalData,
  });

  bool get passwordsMatch => password == confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      ...?additionalData,
    };
  }
}
