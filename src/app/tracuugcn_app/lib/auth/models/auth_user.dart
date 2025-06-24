// User model cho hệ thống xác thực
class AuthUser {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatar;
  final List<String> roles;
  final DateTime? lastLogin;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatar,
    this.roles = const [],
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'roles': roles,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      roles: List<String>.from(json['roles'] ?? []),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  AuthUser copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? avatar,
    List<String>? roles,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, username: $username, email: $email, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
