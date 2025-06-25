# TraCuuGcn - Windows Authentication với Keycloak SSO

## Tổng quan

Dự án này implement xác thực SSO cho ứng dụng Windows sử dụng Keycloak OpenID Connect. AuthManager được thiết kế như một bridge pattern để quản lý các platform-specific authentication providers.

## Cấu trúc Authentication

### 1. AuthManager (Bridge Pattern)
- `AuthManager` là class chính làm cầu nối giữa UI và các platform-specific providers
- Tự động detect platform và tạo appropriate provider
- Cung cấp unified interface cho tất cả platforms

### 2. AuthProvider Interface
- Abstract interface định nghĩa các method cần thiết cho authentication
- Các platform-specific classes implement interface này

### 3. Platform-Specific Implementations
- `WindowsAuth`: Implementation cho Windows platform
- `AndroidAuth`: Implementation cho Android platform  
- `iOSAuth`: Implementation cho iOS platform
- `MacOSAuth`: Implementation cho macOS platform
- `WebAuth`: Implementation cho Web platform

## Cấu hình Keycloak

### OpenID Connect Configuration
File `lib/auth/config/openid_config.dart` chứa cấu hình cho:

```dart
// Development Environment URLs
static const String keycloakDevIssuer = 'https://sso.vpdkbacninh.vn/realms/vpdk/';

// Client IDs
static const String keycloakDev = 'tracuugcn-app-dev';
static const String keycloakDevSecret = 'ER5Nsv1eo6xV6twg0YAmuZgyMrjbbNJl';
```

### Platform Detection
Hệ thống tự động detect platform và apply cấu hình phù hợp:
- Windows: Sử dụng system browser với local redirect server
- Mobile: Sử dụng in-app browser hoặc custom tabs
- Web: Sử dụng popup/redirect flow

## WindowsAuth Implementation

### Tính năng chính:
1. **Browser-based Authentication**: Mở Keycloak login page trong system browser
2. **Secure Storage**: Sử dụng `flutter_secure_storage` để lưu tokens
3. **Auto Configuration**: Tự động build auth URL và logout URL
4. **Mock Authentication**: Có chế độ demo để test

### Flow Authentication:
```
1. User clicks "Đăng nhập SSO"
2. App builds Keycloak authorization URL
3. Launch system browser với URL
4. User login trên Keycloak
5. Keycloak redirect về app với authorization code
6. App exchange code để lấy tokens
7. Store tokens securely
8. Get user info từ Keycloak
```

### Current Implementation Status:
- ✅ URL building for Keycloak
- ✅ System browser launching  
- ✅ Secure token storage
- ✅ User info parsing
- 🚧 Callback handling (đang simulate bằng mock data)
- 🚧 Token refresh logic

## Test Screen

### AuthTestScreen Features:
- **Authentication Status**: Hiển thị trạng thái đăng nhập
- **User Information**: Hiển thị thông tin user từ Keycloak
- **Token Display**: Debug mode hiển thị access token
- **Platform Detection**: Hiển thị platform hiện tại
- **Actions**: Login, Logout, Refresh status

### Test Flow:
1. Mở app → Hiển thị AuthTestScreen
2. Click "Đăng nhập SSO" → Mở browser với Keycloak URL
3. Sau 2 giây → Simulate successful login với mock data
4. Hiển thị user info và token
5. Click "Đăng xuất" → Clear stored data

## Dependencies

```yaml
dependencies:
  # OpenID Connect / OAuth
  openid_client: ^0.4.5
  flutter_secure_storage: ^9.0.0
  url_launcher: ^6.2.1
  http: ^1.1.0
```

## Cách chạy

```bash
cd src/app/tracuugcn_app
flutter pub get
flutter run -d windows
```

## Cấu hình Keycloak (Real Implementation)

Để implement hoàn chỉnh, cần:

1. **Callback Handler**: Implement local HTTP server để handle redirect
2. **Token Exchange**: Exchange authorization code với access token
3. **Refresh Token**: Implement token refresh logic
4. **Error Handling**: Handle various OAuth errors

### Keycloak Client Configuration:
```
Client ID: tracuugcn-app-dev
Valid Redirect URIs: http://localhost:8080/auth/callback
Web Origins: http://localhost:8080
```

## Troubleshooting

### Common Issues:
1. **Browser không mở**: Kiểm tra `url_launcher` permissions
2. **Secure storage lỗi**: Kiểm tra Windows Credential Manager
3. **Keycloak URL sai**: Verify issuer URL trong config

### Debug Mode:
- AuthTestScreen hiển thị detailed logs
- Token information visible trong debug mode
- Platform detection information

## Roadmap

### Immediate (Current Sprint):
- [x] Basic Windows authentication structure
- [x] Keycloak URL building
- [x] Browser launching
- [x] Mock authentication flow
- [x] Secure storage integration

### Next Sprint:
- [ ] Real callback handling
- [ ] Token exchange implementation
- [ ] Error handling improvement
- [ ] Token refresh logic

### Future:
- [ ] Biometric authentication (mobile)
- [ ] Remember me functionality
- [ ] Multi-tenant support
- [ ] Offline token validation

## Architecture Benefits

1. **Platform Agnostic**: Dễ dàng add support cho platforms mới
2. **Maintainable**: Separation of concerns rõ ràng
3. **Testable**: Mỗi platform có thể test independent
4. **Configurable**: Centralized configuration management
5. **Secure**: Platform-specific security best practices
