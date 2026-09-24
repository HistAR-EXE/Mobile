# TimeLens (HistAR) — Flutter mobile

Client Android/iOS gọi **cùng REST BE** với web FE (`/api/*`, JWT + refresh).

## Yêu cầu

- Flutter SDK 3.24+ (đã test 3.47)
- Android Studio / SDK (build AAB)
- BE HTTPS: mặc định `https://histar-postgre.onrender.com`

## Chạy local

```powershell
cd Mobile
copy .env.example .env   # nếu chưa có
flutter pub get
flutter run
```

Đăng nhập demo (nếu DB đã seed): `demo@histar.vn` / `Demo@2026`

## Cấu hình `.env`

| Key | Ý nghĩa |
|-----|---------|
| `API_BASE_URL` | BE origin (không trailing slash) |
| `MEDIA_BASE_URL` | Host ảnh `/media/...` (thường FE Vercel) |
| `WEB_APP_URL` | Deep-link verify email, admin, teacher, privacy |

## Application ID

`vn.histar.timelens` — đổi trong `android/app/build.gradle.kts` nếu team dùng package khác.

## Build release / CH Play

**Release signing:** `android/app/build.gradle.kts` uses the debug keystore when `android/key.properties` is missing. Do not upload that AAB. Create `upload-keystore.jks`, copy `android/key.properties.example` → `android/key.properties`, then build.

Android smoke before upload: [`../scripts/mobile-android-smoke.md`](../scripts/mobile-android-smoke.md).  
Play steps: [`../docs/GOOGLE_PLAY_CLOSED_TESTING.md`](../docs/GOOGLE_PLAY_CLOSED_TESTING.md).  
Data safety answers: [`../docs/PLAY_DATA_SAFETY_ANSWERS.md`](../docs/PLAY_DATA_SAFETY_ANSWERS.md).

1. Tạo keystore (một lần):

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Copy `android/key.properties.example` → `android/key.properties`, điền mật khẩu + đường dẫn jks.

3. Build AAB:

```powershell
cd Mobile
flutter build appbundle --release
```

File: `build/app/outputs/bundle/release/app-release.aab`

**Windows:** Nếu build Kotlin fail với `different roots` (pub cache `C:` vs project `D:`), repo đã set `kotlin.incremental=false` trong `android/gradle.properties`. Sau đổi keystore, dùng UTF-8 **without BOM** cho `key.properties`.

4. [Google Play Console](https://play.google.com/console) → tạo app → **Internal testing** → upload AAB → thêm tester email.

5. Privacy Policy URL (bắt buộc): `https://fe-lake-five.vercel.app/privacy` (sau khi deploy FE có trang `/privacy`).

### Data safety (Play Console)

Khai báo theo BE thực tế: email (auth), vị trí gần đúng (check-in GPS), tải ảnh/camera (QR). Không bán dữ liệu.

### Firebase Google Sign-In (optional Pha 2)

Thêm Android app `vn.histar.timelens` trong Firebase project `histar-a08c1`, tải `google-services.json` vào `android/app/`, thêm SHA-1 debug + release.

## Kiến trúc thư mục

```
lib/
  core/          env, dio ApiClient, theme, router, session
  features/      auth, locations, panorama, chat, gamification, billing, screens
  shared/        providers
```

## Tour 360

- Native: danh sách scene + ảnh panorama + chip scene-link từ API hotspots.
- Nút **Viewer đầy đủ**: WebView tới FE `/tour/360/{locationId}` (Photo Sphere Viewer đầy đủ).

## Outcome 1 (EXE201) checklist

- [ ] App chạy trên thiết bị thật, gọi API prod
- [ ] Luồng: login → explore/Củ Chi → Tour 360 → chat → quest hoặc check-in
- [ ] AAB trên Internal testing
- [x] Privacy URL public
- [ ] Video demo 5–7 phút

## Lệnh hữu ích

```powershell
flutter analyze
flutter test
flutter build apk --release   # APK sideload demo nhanh
```
