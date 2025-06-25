# SSO Authentication Testing Guide

## Tổng quan
Tài liệu này hướng dẫn cách test tính năng xác thực SSO thực với Keycloak dev server.

## Thay đổi chính

### WindowsAuth Implementation
- **Đã bỏ**: Logic người dùng giả lập (mock user)
- **Đã triển khai**: Xác thực SSO thật với Keycloak
- **Tính năng mới**:
  - HTTP callback server trên localhost:8080
  - Token exchange với authorization code
  - Lưu trữ secure tokens (access & refresh)
  - Kiểm tra token expiry và refresh tự động
  - Xử lý lỗi và validation state parameter (CSRF protection)

### Authentication Flow
1. **Khởi tạo**: Tạo state parameter bảo mật và khởi động callback server
2. **Authorization**: Mở browser với Keycloak auth URL
3. **User Login**: Người dùng đăng nhập trên Keycloak
4. **Callback**: Keycloak redirect về localhost:8080 với authorization code
5. **Token Exchange**: Đổi authorization code lấy access & refresh tokens
6. **User Info**: Lấy thông tin người dùng từ UserInfo endpoint
7. **Storage**: Lưu tokens và user info vào secure storage

## Cách Test

### 1. Khởi chạy App
```bash
cd "g:\source\haitnmt\TraCuuGcn\src\app\tracuugcn_app"
flutter run -d windows
```

### 2. Test Authentication
- App sẽ mở với màn hình `AuthTestScreen`
- Click nút **"Login with SSO"**
- Quan sát console logs để theo dõi authentication flow

### 3. Expected Behavior

#### Khi bấm Login:
```
[WindowsAuth] Starting authentication...
[WindowsAuth] Callback server started on http://localhost:8080
[WindowsAuth] Auth URL: https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/auth?...
[WindowsAuth] Browser launched. Waiting for callback...
```

#### Browser sẽ mở Keycloak login page:
- URL: `https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/auth`
- Parameters bao gồm: client_id, redirect_uri, scope, state

#### Sau khi đăng nhập thành công:
```
[WindowsAuth] Received callback: http://localhost:8080/auth/callback?code=...&state=...
[WindowsAuth] Authorization code received, exchanging for tokens...
[WindowsAuth] Token exchange response status: 200
[WindowsAuth] UserInfo response status: 200
[WindowsAuth] Auth data stored successfully
[WindowsAuth] Authentication completed successfully
```

#### App UI sẽ cập nhật:
- Hiển thị trạng thái "Authenticated: true"
- Hiển thị thông tin user thật từ Keycloak
- Hiển thị access token (first 50 chars)

### 4. Test Logout
- Click nút **"Logout"**
- App sẽ thực hiện:
  1. **Server logout**: Gửi HTTP POST request đến Keycloak logout endpoint để terminate SSO session
  2. **Local logout**: Clear stored tokens và user info từ secure storage
- **Không mở browser** cho logout (silent logout)
- UI sẽ cập nhật trạng thái về "Not authenticated"
- **Khi login lại**: Sẽ yêu cầu đăng nhập lại trên Keycloak (vì SSO session đã bị terminate)

## Troubleshooting

### Lỗi thường gặp:

#### 1. "Could not launch URL"
- **Nguyên nhân**: url_launcher không thể mở browser
- **Giải pháp**: Đảm bảo có browser mặc định được cài đặt

#### 2. "Authentication timeout"
- **Nguyên nhân**: Không hoàn thành đăng nhập trong 5 phút
- **Giải pháp**: Thử lại và đăng nhập nhanh hơn

#### 3. "Token exchange failed: 400"
- **Nguyên nhân**: Client configuration sai hoặc redirect_uri không match
- **Giải pháp**: Kiểm tra cấu hình Keycloak client:
  - Client ID: `flutter-tracuugcn-dev`
  - Client Secret: `ER5Nsv1eo6xV6twg0YAmuZgyMrjbbNJl`
  - Valid Redirect URIs: `http://localhost:8080/auth/callback`

#### 4. "UserInfo request failed: 401"
- **Nguyên nhân**: Access token không hợp lệ
- **Giải pháp**: Kiểm tra token exchange và scopes

#### 5. "Invalid state parameter"
- **Nguyên nhân**: Possible CSRF attack hoặc callback bị duplicate
- **Giải pháp**: Thử lại authentication flow

## Debug Information

### Console Logs
App sẽ log các thông tin debug với prefix `[WindowsAuth]`:
- Authentication flow steps
- HTTP request/response status codes
- Error messages với stack traces

### Network Traffic
Có thể monitor các HTTP requests:
- Authorization: `GET https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/auth`
- Token Exchange: `POST https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/token`
- UserInfo: `GET https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/userinfo`
- Logout: `GET https://sso.vpdkbacninh.vn/realms/vpdk/protocol/openid-connect/logout`

### Stored Data
Authentication data được lưu trong Flutter Secure Storage:
- `windows_access_token`: JWT access token
- `windows_refresh_token`: Refresh token for token renewal
- `windows_user_info`: JSON user information from UserInfo endpoint
- `windows_auth_state`: State parameter for CSRF protection

## Next Steps

### 1. Production Ready
- Implement proper error handling UI
- Add token refresh logic in background
- Handle network connectivity issues
- Add biometric authentication if needed

### 2. Other Platforms
- Extend to Android (using Custom Tabs)
- Extend to iOS (using SFSafariViewController)
- Extend to macOS (similar to Windows)
- Web implementation (using popup/redirect)

### 3. Security Enhancements
- Implement PKCE (Proof Key for Code Exchange)
- Add certificate pinning for production
- Implement proper token validation
- Add session management
