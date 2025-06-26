// User model cho hệ thống xác thực
class AuthUser {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? displayName; // Tên hiển thị ưu tiên
  final String? avatar;
  final List<String> roles;
  final DateTime? lastLogin;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.displayName,
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
      'displayName': displayName,
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
      displayName: json['displayName'],
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
    try {
      // Priority order for fullName
      final fullName = userInfo['name'] ?? 
                      (userInfo['given_name'] != null && userInfo['family_name'] != null 
                        ? '${userInfo['given_name']} ${userInfo['family_name']}'
                        : userInfo['given_name']) ?? '';
      
      // Priority order for displayName (per Keycloak config guide):
      // 1. display_name (custom attribute)
      // 2. name (full name)  
      // 3. given_name (first name)
      // 4. preferred_username (username)
      final displayName = userInfo['display_name'] ?? 
                         userInfo['name'] ?? 
                         userInfo['given_name'] ?? 
                         userInfo['preferred_username'] ?? 
                         userInfo['username'] ?? 
                         'User';
      
      // Debug logging - show available keys and values
      print("[AuthUser] Parsing Keycloak userInfo:");
      print("[AuthUser] Available keys: ${userInfo.keys.toList()}");
      print("[AuthUser] display_name: ${userInfo['display_name']}");
      print("[AuthUser] name: ${userInfo['name']}");
      print("[AuthUser] given_name: ${userInfo['given_name']}");
      print("[AuthUser] family_name: ${userInfo['family_name']}");
      print("[AuthUser] preferred_username: ${userInfo['preferred_username']}");
      print("[AuthUser] computed fullName: $fullName");
      print("[AuthUser] computed displayName: $displayName");
      print("[AuthUser] email_verified type: ${userInfo['email_verified'].runtimeType}");
      print("[AuthUser] email_verified value: ${userInfo['email_verified']}");
      
      // Safe parsing của email_verified
      bool isActive = true;
      final emailVerified = userInfo['email_verified'];
      if (emailVerified != null) {
        if (emailVerified is bool) {
          isActive = emailVerified;
        } else if (emailVerified is String) {
          isActive = emailVerified.toLowerCase() == 'true';
        }
      }
      
      final authUser = AuthUser(
        id: userInfo['sub'] ?? userInfo['id'] ?? '',
        username: userInfo['preferred_username'] ?? userInfo['username'] ?? '',
        email: userInfo['email'] ?? '',
        fullName: fullName,
        displayName: displayName,
        avatar: userInfo['picture'],
        roles: _extractKeycloakRoles(userInfo),
        isActive: isActive,
        lastLogin: DateTime.now(), // Set current time as last login
      );
      
      print("[AuthUser] Created AuthUser: $authUser");
      return authUser;
    } catch (e, stackTrace) {
      print("[AuthUser] Error parsing Keycloak userInfo: $e");
      print("[AuthUser] StackTrace: $stackTrace");
      rethrow;
    }
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
    String? displayName,
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
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get the best display name for this user
  String get effectiveDisplayName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return username;
  }

  /// Get formatted last login time
  String get formattedLastLogin {
    if (lastLogin == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastLogin!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
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
