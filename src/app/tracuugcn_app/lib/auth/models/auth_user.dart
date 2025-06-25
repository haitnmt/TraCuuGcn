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

  // Factory constructor for Keycloak user info
  factory AuthUser.fromKeycloakUserInfo(Map<String, dynamic> userInfo) {
    return AuthUser(
      id: userInfo['sub'] ?? userInfo['id'] ?? '',
      username: userInfo['preferred_username'] ?? userInfo['username'] ?? '',
      email: userInfo['email'] ?? '',
      fullName: userInfo['name'] ?? userInfo['given_name'] ?? '',
      avatar: userInfo['picture'],
      roles: _extractKeycloakRoles(userInfo),
      isActive: userInfo['email_verified'] ?? true,
    );
  }

  // Helper method to extract roles from Keycloak token
  static List<String> _extractKeycloakRoles(Map<String, dynamic> userInfo) {
    final List<String> roles = [];
    
    // Check for roles in realm_access
    if (userInfo['realm_access'] != null && 
        userInfo['realm_access']['roles'] != null) {
      roles.addAll(List<String>.from(userInfo['realm_access']['roles']));
    }
    
    // Check for roles in resource_access
    if (userInfo['resource_access'] != null) {
      final resourceAccess = userInfo['resource_access'] as Map<String, dynamic>;
      for (final clientRoles in resourceAccess.values) {
        if (clientRoles['roles'] != null) {
          roles.addAll(List<String>.from(clientRoles['roles']));
        }
      }
    }
    
    // Check for groups (if groups are mapped to roles)
    if (userInfo['groups'] != null) {
      roles.addAll(List<String>.from(userInfo['groups']));
    }
    
    return roles;
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
