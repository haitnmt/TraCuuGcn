# OpenID Configuration

Thư mục này chứa các file cấu hình OpenID Connect cho ứng dụng TraCuuGcn.

## Files

- `openid.ini.example` - Template cấu hình mẫu
- `openid.ini` - Cấu hình chính (không commit vào git)
- `openid.dev.ini` - Cấu hình cho môi trường development (không commit vào git)
- `openid.prod.ini` - Cấu hình cho môi trường production (không commit vào git)

## Cách sử dụng

1. Copy file example:
   ```bash
   cp openid.ini.example openid.ini
   ```

2. Chỉnh sửa các values trong openid.ini với thông tin thực tế

3. Tạo config cho các môi trường khác nhau:
   ```bash
   cp openid.ini openid.dev.ini
   cp openid.ini openid.prod.ini
   ```

4. Update từng file config cho phù hợp với môi trường

## Bảo mật

⚠️ **QUAN TRỌNG**: Các file `.ini` chứa thông tin nhạy cảm và đã được exclude khỏi git.
Không bao giờ commit các file chứa client secrets thực tế vào source control.

## Deployment

- **Development**: Đặt configs cùng thư mục với project root
- **Production**: Mount configs từ external volume/directory
- **Docker**: Sử dụng volumes hoặc secrets để inject configs
