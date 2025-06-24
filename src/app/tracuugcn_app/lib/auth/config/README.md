# OpenID Connect Configuration Guide

This guide provides detailed instructions for configuring OpenID Connect authentication in the TraCuuGcn application across different platforms.

## Overview

The application supports multiple OpenID Connect providers and platforms:

### Supported Providers
- **Keycloak** - Self-hosted or cloud-hosted
- **Azure AD** - Enterprise and multi-tenant
- **Google OAuth** - Standard Google authentication
- **Custom OIDC Providers** - Any standard OIDC-compliant provider

### Supported Platforms
- **Android** - Native mobile app
- **iOS** - Native mobile app
- **Web** - Browser-based application
- **macOS** - Desktop application
- **Windows** - Desktop application
- **Linux** - Desktop application

## Quick Start

1. Copy the example configuration file:
   ```bash
   cp lib/auth/config/openId_config.dart.example lib/auth/config/openId_config.dart
   ```

2. Update the configuration with your provider details:
   ```dart
   // Example for Keycloak development
   final config = OpenIdConfigFactory.getConfig(
     provider: 'keycloak',
     environment: 'development',
     platform: PlatformConfig.android,
   );
   ```

3. Install required dependencies:
   ```bash
   flutter pub add flutter_appauth
   flutter pub add flutter_secure_storage
   ```

## Provider-Specific Configuration

### Keycloak Configuration

#### 1. Keycloak Server Setup
- Create a new realm or use an existing one
- Create a client for your application
- Configure redirect URIs for each platform

#### 2. Client Configuration
```dart
// Development environment
final config = KeycloakConfigs.development(platform: PlatformConfig.android);

// Production environment
final config = KeycloakConfigs.production(platform: PlatformConfig.web);

// Local development
final config = KeycloakConfigs.localhost(platform: PlatformConfig.ios);
```

#### 3. Required Keycloak Client Settings
- **Client ID**: `tracuugcn-app-dev` (or your custom client ID)
- **Client Protocol**: `openid-connect`
- **Access Type**: 
  - `public` for mobile/desktop apps
  - `confidential` for web apps
- **Standard Flow Enabled**: `ON`
- **Direct Access Grants Enabled**: `ON` (if needed)
- **Valid Redirect URIs**: Platform-specific URIs (see below)

### Azure AD Configuration

#### 1. Azure AD App Registration
- Register a new application in Azure AD
- Configure authentication settings
- Add platform-specific redirect URIs

#### 2. Client Configuration
```dart
// Enterprise configuration
final config = AzureAdConfigs.enterprise(platform: PlatformConfig.web);

// Multi-tenant configuration
final config = AzureAdConfigs.multiTenant(platform: PlatformConfig.android);
```

#### 3. Required Azure AD Settings
- **Application Type**: 
  - `Web` for web applications
  - `Mobile and desktop applications` for mobile/desktop
- **Redirect URIs**: Platform-specific URIs
- **Supported Account Types**: Choose based on your needs
- **API Permissions**: `User.Read` (minimum)

### Google OAuth Configuration

#### 1. Google Cloud Console Setup
- Create a new project or use existing
- Enable Google+ API
- Create OAuth 2.0 credentials for each platform

#### 2. Client Configuration
```dart
final config = GoogleOAuthConfigs.standard(platform: PlatformConfig.ios);
```

#### 3. Required Google OAuth Settings
- **Application Type**: Platform-specific
- **Authorized Redirect URIs**: Platform-specific URIs
- **Scopes**: `openid`, `profile`, `email`

## Platform-Specific Setup

### Android Setup

#### 1. Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_appauth: ^6.0.2
  flutter_secure_storage: ^9.0.0
```

#### 2. Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
  <!-- Add the redirect activity -->
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

Add to `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            'appAuthRedirectScheme': 'com.example.tracuugcn.dev'
        ]
    }
}
```

#### 3. Redirect URIs
- Development: `com.example.tracuugcn.dev://oauth/callback`
- Production: `com.example.tracuugcn://oauth/callback`

### iOS Setup

#### 1. Dependencies
Same as Android - add to `pubspec.yaml`.

#### 2. iOS Configuration
Add to `ios/Runner/Info.plist`:
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

#### 3. Redirect URIs
- Development: `com.example.tracuugcn.dev://oauth/callback`
- Production: `com.example.tracuugcn://oauth/callback`

### Web Setup

#### 1. Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_appauth: ^6.0.2
  # Note: flutter_secure_storage not needed for web
```

#### 2. Web Configuration
No additional configuration files needed. Ensure your web server can serve the redirect URIs.

#### 3. CORS Configuration
Configure your OIDC provider to allow your web domain:
- Add your domain to allowed origins
- Include both the main domain and redirect URIs

#### 4. Redirect URIs
- Development: `http://localhost:3000/auth/callback`
- Production: `https://tracuugcn.yourdomain.com/auth/callback`

### Desktop Setup (macOS, Windows, Linux)

#### 1. Dependencies
Same as Android/iOS - add to `pubspec.yaml`.

#### 2. Desktop Configuration
No additional configuration files needed. The app will start a local HTTP server to handle the redirect.

#### 3. Firewall Configuration
Ensure your firewall allows the local HTTP server (default port 8080).

#### 4. Redirect URIs
- All platforms: `http://localhost:8080/auth/callback`

## Environment Variables

For sensitive configuration, consider using environment variables:

```dart
// Using environment variables
class EnvironmentConfig {
  static const String keycloakIssuer = String.fromEnvironment(
    'KEYCLOAK_ISSUER',
    defaultValue: 'http://localhost:8080/realms/tracuugcn',
  );
  
  static const String keycloakClientId = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
    defaultValue: 'tracuugcn-app-dev',
  );
  
  static const String keycloakClientSecret = String.fromEnvironment(
    'KEYCLOAK_CLIENT_SECRET',
    defaultValue: '',
  );
}
```

## Security Best Practices

### 1. Client Secrets
- **Never** include client secrets in mobile or desktop applications
- Use client secrets only for web applications
- Store client secrets securely on the server side

### 2. Redirect URIs
- Use custom URL schemes for mobile apps
- Avoid using `http://` in production (use `https://`)
- Validate redirect URIs on the server side

### 3. Token Storage
- Use `flutter_secure_storage` for mobile/desktop
- Use secure HTTP-only cookies for web
- Never store tokens in plain text

### 4. PKCE (Proof Key for Code Exchange)
- Always enable PKCE for public clients
- Most modern OIDC libraries enable this by default

### 5. Scopes
- Request only the minimum required scopes
- Understand what each scope provides
- Regularly review and update scope requirements

## Troubleshooting

### Common Issues

#### 1. Redirect URI Mismatch
**Error**: `redirect_uri_mismatch`
**Solution**: 
- Check that redirect URIs match exactly (including case and trailing slashes)
- Verify the URI is registered in your OIDC provider
- Ensure URL encoding is correct

#### 2. CORS Issues (Web)
**Error**: CORS policy blocks the request
**Solution**:
- Add your domain to the OIDC provider's allowed origins
- Include both the main domain and redirect URIs
- Check browser developer tools for specific CORS errors

#### 3. SSL Certificate Issues
**Error**: SSL certificate verification failed
**Solution**:
- Use valid SSL certificates in production
- For development, you may need to allow insecure connections
- Check certificate chain and expiration

#### 4. Token Expiration
**Error**: Token expired
**Solution**:
- Implement automatic token refresh
- Check token expiration times
- Handle refresh token rotation

#### 5. Scope Permission Issues
**Error**: Insufficient permissions
**Solution**:
- Verify requested scopes are supported
- Check client permissions in the OIDC provider
- Ensure user has necessary permissions

### Debugging Tips

1. **Enable Logging**: Add logging to track the authentication flow
2. **Check Network Traffic**: Use browser developer tools or network monitoring
3. **Validate Tokens**: Use JWT debugging tools to inspect token contents
4. **Test with Different Browsers/Devices**: Some issues are platform-specific
5. **Check Provider Documentation**: Each provider has specific requirements

## Example Implementation

Here's a complete example of how to use the configuration:

```dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'auth/config/openId_config.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  
  Future<void> login() async {
    try {
      // Get platform-specific configuration
      final config = OpenIdConfigFactory.getConfig(
        provider: 'keycloak',
        environment: 'development',
        platform: PlatformConfig.android, // or detect automatically
      );
      
      // Perform authentication
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          issuer: config.issuer,
          scopes: config.scopes,
          additionalParameters: config.additionalParameters,
          allowInsecureConnections: config.allowInsecureConnections,
        ),
      );
      
      if (result != null) {
        // Handle successful authentication
        print('Access Token: ${result.accessToken}');
        print('ID Token: ${result.idToken}');
      }
    } catch (e) {
      // Handle authentication error
      print('Authentication failed: $e');
    }
  }
  
  Future<void> logout() async {
    final config = OpenIdConfigFactory.getConfig(
      provider: 'keycloak',
      environment: 'development',
      platform: PlatformConfig.android,
    );
    
    await _appAuth.endSession(EndSessionRequest(
      idTokenHint: 'stored_id_token',
      postLogoutRedirectUrl: config.postLogoutRedirectUri,
      issuer: config.issuer,
    ));
  }
}
```

## Additional Resources

- [OpenID Connect Specification](https://openid.net/connect/)
- [Flutter AppAuth Documentation](https://pub.dev/packages/flutter_appauth)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Azure AD Documentation](https://docs.microsoft.com/en-us/azure/active-directory/)
- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)

## Support

If you encounter issues:
1. Check this documentation first
2. Review the provider-specific documentation
3. Check the GitHub issues for known problems
4. Create a new issue with detailed information about your setup and error messages
