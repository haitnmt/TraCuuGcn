// Auth token model
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final String tokenType;
  final int expiresIn;
  final DateTime issuedAt;
  final List<String> scopes;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.issuedAt,
    this.scopes = const [],
  });

  bool get isExpired {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }

  DateTime get expiresAt {
    return issuedAt.add(Duration(seconds: expiresIn));
  }

  Duration get timeToExpiry {
    final expiryTime = issuedAt.add(Duration(seconds: expiresIn));
    return expiryTime.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'idToken': idToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'issuedAt': issuedAt.toIso8601String(),
      'scopes': scopes,
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      idToken: json['idToken'] ?? json['id_token'],
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? json['expires_in'] ?? 3600,
      issuedAt: json['issuedAt'] != null
          ? DateTime.parse(json['issuedAt'])
          : DateTime.now(),
      scopes: List<String>.from(json['scopes'] ?? json['scope']?.split(' ') ?? []),
    );
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    String? tokenType,
    int? expiresIn,
    DateTime? issuedAt,
    List<String>? scopes,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      issuedAt: issuedAt ?? this.issuedAt,
      scopes: scopes ?? this.scopes,
    );
  }

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, expiresIn: ${expiresIn}s, isExpired: $isExpired)';
  }
}
