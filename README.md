# Phong Thủy Số – Tra & Luận Số

App offline phân tích số điện thoại, căn cước, họ tên, biển số xe, số nhà, tài khoản – mật khẩu, hôn phối và luận chọn số theo sách "Phong Thủy Số".

## Cấu trúc
- `app/index.html` – toàn bộ ứng dụng (1 file, chạy offline). **Chỉ cần sửa file này**, khi build sẽ tự chép sang EXE và APK.
- `electron/` – đóng gói Windows (.exe).
- `android/` – đóng gói Android (.apk, WebView).
- `.github/workflows/build.yml` – GitHub Actions tự build.

## Build
1. Tạo repo mới trên GitHub, tải toàn bộ thư mục này lên (giữ nguyên thư mục `.github`).
2. Mỗi lần đẩy code lên nhánh `main`, Actions tự build. Hoặc vào tab **Actions → Build EXE + APK → Run workflow**.
3. Sau khoảng 5–10 phút, vào **Releases** tải:
   - `PhongThuySo-Portable.exe` – chạy ngay trên PC, không cần cài.
   - `PhongThuySo-Setup.exe` – bộ cài cho PC.
   - `PhongThuySo.apk` – cài trên Android (cho phép "cài ứng dụng không rõ nguồn gốc").

## Mật khẩu
- Mật khẩu sử dụng mặc định = mật khẩu admin.
- Đổi mật khẩu sử dụng: nhấn giữ nút tròn xám bên phải khoảng 5 giây → nhập mật khẩu admin, mật khẩu mới, xác nhận → OK.
- Mật khẩu chỉ lưu dạng mã băm (SHA-256) trên từng máy; đổi ở máy nào áp dụng cho máy đó.
- APK được ký bằng `android/app/release.keystore` cố định nên các bản sau cài đè được lên bản trước.
