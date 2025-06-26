# Flutter AppAuth Integration

Tích hợp xác thực OAuth 2.0 / OpenID Connect cho Android, iOS và macOS sử dụng `flutter_appauth: ^9.0.1`.

## Tính năng

- ✅ Hỗ trợ Android (API 21+)
- ✅ Hỗ trợ iOS 
- ✅ Hỗ trợ macOS
- ✅ Keycloak/SSO authentication
- ✅ Google OAuth
- ✅ Azure AD authentication
- ✅ Secure token storage với Flutter Secure Storage
- ✅ Token refresh tự động
- ✅ Platform-specific configuration

## Cấu hình

### 1. Dependencies

```yaml
dependencies:
  flutter_appauth: ^9.0.1
  flutter_secure_storage: ^9.0.0
  http: ^1.1.0
```

### 2. Cấu hình Android

#### 2.1 build.gradle.kts
```kotlin
android {
    namespace = "vn.haihv.tracuugcn"
    defaultConfig {
        applicationId = "vn.haihv.tracuugcn"
        minSdk = 21 // AppAuth requires minimum API 21
        manifestPlaceholders["appAuthRedirectScheme"] = "vn.haihv.tracuugcn"
    }
}
```

#### 2.2 AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.INTERNET" />

<activity android:name="net.openid.appauth.RedirectUriReceiverActivity"
    android:exported="true"
    android:tools:node="replace">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="${appAuthRedirectScheme}" />
    </intent-filter>
</activity>
```

### 3. Cấu hình iOS

#### 3.1 Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>vn.haihv.tracuugcn.oauth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vn.haihv.tracuugcn</string>
        </array>
    </dict>
</array>
```

### 4. Cấu hình macOS

#### 4.1 Info.plist (tương tự iOS)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>vn.haihv.tracuugcn.oauth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>vn.haihv.tracuugcn</string>
        </array>
    </dict>
</array>
```

### 5. Cấu hình OpenID

Cập nhật file `configs/openid.ini`:

```ini
OpenId: 
  ssoIssuer: https://sso.vpdkbacninh.vn/realms/vpdk/
  ssoClientId: flutter-tracuugcn-dev
  ssoClientSecret: ER5Nsv1eo6xV6twg0YAmuZgyMrjbbNJl
  
  googleIssuer: https://accounts.google.com
  googleClientId: your-google-client-id.apps.googleusercontent.com
  
  azureIssuer: https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0
  azureClientId: your-azure-client-id
  
  AppAuthRedirectScheme: vn.haihv.tracuugcn
```

## Sử dụng

### 1. Khởi tạo Service

```dart
import 'lib/auth/services/appauth_service.dart';

final appAuthService = AppAuthService();
await appAuthService.initialize();
```

### 2. Đăng nhập

```dart
// Đăng nhập với Keycloak/SSO
final token = await appAuthService.signInWithKeycloak();

// Đăng nhập với Google
final token = await appAuthService.signInWithGoogle();

// Đăng nhập với Azure AD
final token = await appAuthService.signInWithAzure();
```

### 3. Kiểm tra authentication

```dart
final isAuthenticated = await appAuthService.isAuthenticated();
if (isAuthenticated) {
    final user = await appAuthService.getCurrentUser();
    final token = await appAuthService.getCurrentToken();
}
```

### 4. Đăng xuất

```dart
await appAuthService.logout();
```

### 5. Refresh token

```dart
final newToken = await appAuthService.refreshToken();
```

## Platform-specific Implementation

### Android (auth_android.dart)
```dart
class AndroidAuth implements AuthProvider {
  final AppAuthService _appAuthService = AppAuthService();
  
  @override
  Future<void> authenticate({String? languageCode}) async {
    await _appAuthService.signInWithKeycloak();
  }
  
  // Additional Android-specific methods
  Future<AuthToken?> signInWithGoogle() async {
    return await _appAuthService.signInWithGoogle();
  }
}
```

### iOS (auth_ios.dart)
```dart
class IOSAuth implements AuthProvider {
  final AppAuthService _appAuthService = AppAuthService();
  
  // iOS-specific implementation with Touch ID/Face ID support
  Future<AuthToken?> signInWithApple() async {
    // Apple Sign In implementation
  }
}
```

### macOS (auth_macos.dart)
```dart
class MacOSAuth implements AuthProvider {
  final AppAuthService _appAuthService = AppAuthService();
  
  // macOS-specific features
  Future<bool> canUseTouchID() async {
    // Touch ID availability check
  }
}
```

## Demo Widget

```dart
import 'lib/auth/widgets/appauth_login_widget.dart';

// Sử dụng trong app
AppAuthLoginWidget(
  onLoginSuccess: () {
    // Handle successful login
  },
  onLoginError: (error) {
    // Handle login error
  },
)
```

## Debug và Testing

1. **Kiểm tra redirect URI**: Đảm bảo redirect scheme khớp với cấu hình
2. **Network logs**: Sử dụng Charles Proxy hoặc tương tự để debug OAuth flow
3. **Token validation**: Sử dụng jwt.io để decode và validate tokens
4. **Platform-specific logs**: 
   - Android: `adb logcat`
   - iOS: Xcode console
   - macOS: Console.app

## Troubleshooting

### Common Issues:

1. **"Invalid redirect URI"**
   - Kiểm tra cấu hình redirect scheme trong platform config
   - Đảm bảo URI handler được cấu hình đúng

2. **"Network error"**
   - Kiểm tra internet permission trên Android
   - Verify SSL certificates

3. **"Authentication failed"**
   - Kiểm tra client ID và client secret
   - Verify issuer URL

### Platform-specific Issues:

#### Android:
- Minimum SDK: API 21
- Custom tabs support required
- Check `manifestPlaceholders` configuration

#### iOS:
- URL scheme must be unique
- Keychain sharing if using multiple apps
- Safari View Controller support

#### macOS:
- System browser integration
- Keychain access permissions
- macOS 10.15+ requirements

## Security Considerations

1. **Token Storage**: Sử dụng Flutter Secure Storage cho sensitive data
2. **HTTPS Only**: Luôn sử dụng HTTPS cho production
3. **Client Secret**: Chỉ sử dụng cho web/desktop, không store trong mobile app
4. **Token Validation**: Validate tokens server-side
5. **PKCE**: AppAuth tự động sử dụng PKCE cho mobile apps

## Architecture

```
lib/auth/
├── services/
│   └── appauth_service.dart       # Main AppAuth integration
├── mobile/
│   ├── auth_android.dart          # Android-specific implementation
│   └── auth_ios.dart             # iOS-specific implementation  
├── desktop/
│   └── auth_macos.dart           # macOS-specific implementation
├── widgets/
│   └── appauth_login_widget.dart # Demo UI widget
├── models/
│   ├── auth_user.dart           # User model
│   └── auth_token.dart          # Token model
└── utils/
    └── ini_reader.dart          # Configuration loader
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Test trên tất cả platforms (Android, iOS, macOS)
4. Update documentation
5. Submit pull request

## License

MIT License - xem [LICENSE](LICENSE) file for details.
