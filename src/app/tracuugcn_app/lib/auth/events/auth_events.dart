import 'dart:async';

// Auth event types
enum AuthEventType {
  loginAttempt,
  loginSuccess,
  loginFailure,
  logout,
  tokenRefresh,
  sessionExpired,
  userUpdated,
}

// Auth event class
class AuthEvent {
  final AuthEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? userId;

  const AuthEvent({
    required this.type,
    required this.timestamp,
    this.data,
    this.userId,
  });

  factory AuthEvent.loginAttempt(String username) {
    return AuthEvent(
      type: AuthEventType.loginAttempt,
      timestamp: DateTime.now(),
      data: {'username': username},
    );
  }

  factory AuthEvent.loginSuccess(String userId) {
    return AuthEvent(
      type: AuthEventType.loginSuccess,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  factory AuthEvent.loginFailure(String reason) {
    return AuthEvent(
      type: AuthEventType.loginFailure,
      timestamp: DateTime.now(),
      data: {'reason': reason},
    );
  }

  factory AuthEvent.logout(String userId) {
    return AuthEvent(
      type: AuthEventType.logout,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  factory AuthEvent.tokenRefresh(String userId) {
    return AuthEvent(
      type: AuthEventType.tokenRefresh,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  factory AuthEvent.sessionExpired(String userId) {
    return AuthEvent(
      type: AuthEventType.sessionExpired,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  factory AuthEvent.userUpdated(String userId, Map<String, dynamic> changes) {
    return AuthEvent(
      type: AuthEventType.userUpdated,
      timestamp: DateTime.now(),
      userId: userId,
      data: changes,
    );
  }

  @override
  String toString() {
    return 'AuthEvent(type: $type, timestamp: $timestamp, userId: $userId)';
  }
}

// Auth event bus để quản lý các sự kiện xác thực
class AuthEventBus {
  static final AuthEventBus _instance = AuthEventBus._internal();
  factory AuthEventBus() => _instance;
  AuthEventBus._internal();

  final StreamController<AuthEvent> _eventController = StreamController<AuthEvent>.broadcast();
  
  Stream<AuthEvent> get events => _eventController.stream;
  Stream<AuthEvent> eventsOfType(AuthEventType type) => 
      _eventController.stream.where((event) => event.type == type);

  void emit(AuthEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

// Auth event listener mixin
mixin AuthEventListener {
  late StreamSubscription<AuthEvent> _authEventSubscription;

  void startListeningToAuthEvents() {
    _authEventSubscription = AuthEventBus().events.listen(onAuthEvent);
  }

  void stopListeningToAuthEvents() {
    _authEventSubscription.cancel();
  }

  void onAuthEvent(AuthEvent event);
}
