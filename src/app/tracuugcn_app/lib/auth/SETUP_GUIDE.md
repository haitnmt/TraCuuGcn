# OpenID Connect Setup Guide

## Nhanh chóng bắt đầu (Quick Start)

### 1. Cài đặt dependencies

```bash
cd src/app/tracuugcn_app
flutter pub get
```

### 2. Sao chép file cấu hình mẫu

```bash
cp lib/auth/config/openId_config.dart.example lib/auth/config/openId_config.dart
```

### 3. Cấu hình cho Keycloak (Ví dụ phổ biến nhất)

#### Bước 1: Thiết lập Keycloak Server
1. Tạo một realm mới hoặc sử dụng realm có sẵn
2. Tạo client cho ứng dụng:
   - Client ID: `tracuugcn-app-dev`
   - Client Protocol: `openid-connect`
   - Access Type: `public` (cho mobile/desktop) hoặc `confidential` (cho web)
   - Standard Flow Enabled: `ON`
   - Valid Redirect URIs: (xem bên dưới theo platform)

#### Bước 2: Cấu hình Redirect URIs theo platform

**Android:**
```
com.example.tracuugcn.dev://oauth/callback
```

**iOS:**
```
com.example.tracuugcn.dev://oauth/callback
```

**Web:**
```
http://localhost:3000/auth/callback (development)
https://yourdomain.com/auth/callback (production)
```

**Desktop (macOS/Windows/Linux):**
```
http://localhost:8080/auth/callback
```

### 4. Cập nhật cấu hình trong code

Mở file `lib/auth/config/openId_config.dart` và cập nhật:

```dart
// Thay đổi thông tin này cho phù hợp với Keycloak server của bạn
static OpenIdConfig development({required String platform}) {
  return OpenIdConfig(
    issuer: 'https://your-keycloak-server.com/realms/your-realm',
    clientId: 'tracuugcn-app-dev',
    // ... các thông tin khác
  );
}
```

### 5. Cấu hình theo platform

#### Android
Thêm vào `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
  <activity
      android:name="net.openid.appauth.RedirectUriReceiverActivity"
      android:exported="true">
      <intent-filter>
          <action android:name="android.intent.action.VIEW" />
          <category android:name="android.intent.category.DEFAULT" />
          <category android:name="android.intent.category.BROWSABLE" />
          <data android:scheme="com.example.tracuugcn.dev" />
      </intent-filter>
  </activity>
</application>
```

#### iOS
Thêm vào `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.tracuugcn.oauth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.tracuugcn.dev</string>
        </array>
    </dict>
</array>
```

### 6. Sử dụng trong code

```dart
import 'package:tracuugcn_app/auth/openid_auth_service.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final OpenIdAuthService _authService = OpenIdAuthService();

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authService.initialize(
      provider: 'keycloak',
      environment: 'development', // hoặc 'production'
    );
  }

  Future<void> _login() async {
    final result = await _authService.login();
    if (result.success) {
      print('Đăng nhập thành công!');
      final user = _authService.currentUser;
      print('Xin chào ${user?.fullName}');
    } else {
      print('Đăng nhập thất bại: ${result.message}');
    }
  }

  Future<void> _logout() async {
    final result = await _authService.logout();
    if (result.success) {
      print('Đăng xuất thành công!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('TraCuuGcn')),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _login,
                child: Text('Đăng nhập'),
              ),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Đăng xuất'),
              ),
              if (_authService.isAuthenticated)
                Text('Xin chào ${_authService.currentUser?.fullName}'),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Cấu hình cho các nhà cung cấp khác

### Azure AD
```dart
await _authService.initialize(
  provider: 'azure',
  environment: 'enterprise',
);
```

### Google OAuth
```dart
await _authService.initialize(
  provider: 'google',
);
```

### Nhà cung cấp tùy chỉnh
```dart
await _authService.initialize(
  provider: 'custom',
  customConfig: {
    'issuer': 'https://your-provider.com',
    'clientId': 'your-client-id',
    'scopes': ['openid', 'profile', 'email'],
  },
);
```

## Khắc phục sự cố phổ biến

### 1. Lỗi Redirect URI mismatch
- Kiểm tra redirect URI trong cấu hình ứng dụng khớp chính xác với URI trong provider
- Chú ý về trailing slash và case sensitivity

### 2. Lỗi CORS (Web)
- Thêm domain của bạn vào allowed origins trong OIDC provider
- Kiểm tra cả main domain và redirect URIs

### 3. Lỗi SSL Certificate
- Sử dụng SSL certificate hợp lệ trong production
- Cho development, có thể cần allow insecure connections

### 4. Platform-specific issues
- **Android**: Kiểm tra app signing và package name
- **iOS**: Xác nhận bundle ID và URL scheme configuration
- **Desktop**: Đảm bảo local server có thể bind đến port đã chỉ định

## Tài liệu tham khảo

- [OpenID Connect Specification](https://openid.net/connect/)
- [Flutter AppAuth Documentation](https://pub.dev/packages/flutter_appauth)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [File cấu hình chi tiết](lib/auth/config/README.md)

## Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra tài liệu này trước
2. Xem tài liệu của nhà cung cấp OIDC
3. Kiểm tra logs và error messages
4. Tạo issue mới với thông tin chi tiết về setup và lỗi gặp phải
