# OpenID Configuration Deployment Guide

## Vị trí Config Files

### 1. Cho Mobile/Web (Bundle vào app)
```
src/app/tracuugcn_app/assets/config/openid.ini
```

### 2. Cho Desktop/Server (External Config - KHUYẾN NGHỊ)
```
configs/openid.ini              # Config chung
configs/openid.dev.ini          # Config môi trường Development
configs/openid.prod.ini         # Config môi trường Production
configs/openid.staging.ini      # Config môi trường Staging
```

## Ưu điểm của External Config

### ✅ Dễ dàng triển khai
- Không cần rebuild app khi thay đổi config
- Có thể update config mà không ảnh hưởng đến code
- Hỗ trợ nhiều environment khác nhau

### ✅ Bảo mật tốt hơn
- Config files có thể đặt ngoài source code
- Không commit sensitive data vào git
- Dễ dàng quản lý quyền truy cập

### ✅ Linh hoạt deployment
- CI/CD có thể inject config tùy theo environment
- DevOps có thể quản lý config độc lập
- Hot-reload config without app restart

## Cách sử dụng

### 1. Trong code (đã được cập nhật)
```dart
// Load config cho environment cụ thể
final config = await OpenIdIniConfig.load(environment: 'prod');

// Load config từ path tùy chỉnh
final config = await OpenIdIniConfig.load(customPath: '/path/to/config.ini');

// Load config mặc định (auto-detect)
final config = await OpenIdIniConfig.load();
```

### 2. Priority Order (thứ tự ưu tiên load config)
1. `configs/openid.{env}.ini` (external, environment-specific)
2. `configs/openid.ini` (external, general)
3. `assets/config/openid.{env}.ini` (bundled, environment-specific)
4. `assets/config/openid.ini` (bundled, general)

### 3. Environment Variable Support
Có thể set environment qua biến môi trường:
```bash
export OPENID_ENVIRONMENT=prod
export OPENID_CONFIG_PATH=/custom/path/openid.ini
```

## Deployment Scenarios

### Scenario 1: Mobile App (iOS/Android)
```
Sử dụng: assets/config/openid.ini
Lý do: Config được bundle vào app, load nhanh, phù hợp mobile
```

### Scenario 2: Web App
```
Sử dụng: assets/config/ cho development
         configs/ cho production (deploy riêng config files)
```

### Scenario 3: Desktop App
```
Sử dụng: configs/ (preferred)
Đặt config files cùng thư mục với executable
Người dùng có thể tự chỉnh sửa config
```

### Scenario 4: Server/API
```
Sử dụng: configs/ với environment variables
CI/CD inject config files tùy theo stage
```

## Best Practices

1. **Không commit sensitive data**
   ```gitignore
   configs/*.ini
   !configs/*.ini.example
   ```

2. **Sử dụng environment variables cho CI/CD**
   ```yaml
   # docker-compose.yml
   volumes:
     - ./configs:/app/configs:ro
   ```

3. **Validate config at startup**
   ```dart
   assert(config.ssoIssuer.isNotEmpty, 'SSO Issuer cannot be empty');
   ```

4. **Hot-reload cho development**
   ```dart
   // Clear cache để reload config
   IniReader.clearCache();
   ```

## Migration Guide

### Từ assets sang external config:

1. Copy file hiện tại:
   ```bash
   cp src/app/tracuugcn_app/assets/config/openid.ini configs/
   ```

2. Tạo environment-specific configs:
   ```bash
   cp configs/openid.ini configs/openid.dev.ini
   cp configs/openid.ini configs/openid.prod.ini
   ```

3. Update config values cho từng environment

4. Test app với config mới:
   ```dart
   final config = await OpenIdIniConfig.load(environment: 'dev');
   ```

5. Deploy với external config:
   - Desktop: đặt configs/ cùng thư mục executable
   - Server: mount configs/ vào container
   - Web: serve configs/ từ web server

## Troubleshooting

### Config không load được:
1. Check file paths
2. Check file permissions
3. Check file format (phải đúng cú pháp INI)
4. Enable debug mode để xem logs

### Performance:
- Config được cache sau lần đầu load
- Clear cache khi cần reload: `IniReader.clearCache()`
