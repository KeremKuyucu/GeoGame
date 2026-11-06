# Tech Context: GeoGame

## 1. Technologies & SDKs
- **Framework**: Flutter 3.x (`sdk: flutter`)
- **Language**: Dart 3.x (`sdk: '>=3.4.3 <4.0.0'`)
- **Backend as a Service**: Supabase (`supabase_flutter: ^2.17.2`)
  - Postgres database for leaderboards, user stats, and country discovery logs.
  - Supabase Auth (Email/Password, Google OAuth).
- **Monetization**: Google Mobile Ads (`google_mobile_ads: ^9.1.0`)
  - Banner, Interstitial, and Rewarded video ads.
- **Persistent Storage**: `shared_preferences: ^2.5.5`
- **Spatial Mathematics**: `vector_math: ^2.2.0`
- **Desktop Deep Linking**: `app_links: ^7.2.1`
- **Application Metadata**: `package_info_plus: ^10.2.2`
- **UI & Theming**: `theme_mode_builder: ^2.0.0`, `salomon_bottom_bar: ^3.3.2`

## 2. Development & Tooling
- **Static Analysis**: `flutter_lints: ^6.0.0` with strict zero-suppression rules.
- **Unit & Widget Testing**: `flutter_test` suite under `test/` covering models and core services.
- **CI / CD Pipeline**: GitHub Actions (`.github/workflows/release.yml`):
  - Automated Android signing and release bundling (`.aab`).
  - Google Play Store upload automation via Python service account script.
  - Windows installer compilation via Inno Setup 6 and Authenticode signing with `signtool.exe`.
  - Web production deployment to Vercel via Vercel CLI.
  - Automated release notes generation via Gemini API integration.

## 3. Asset Pipeline
- `assets/geojson/`: World geographic boundaries, country borders, centroids, and polygon definitions.
- `assets/lang/`: JSON localization files for 7 supported languages (`eng`, `tur`, `deu`, `fra`, `spa`, `por`, `rus`).
- `assets/flags/`: National flag vector and raster assets.
- `assets/images/`: Game mode artwork, splash screen assets, logos, and UI banners.

## 4. Technical Constraints
- Must maintain sound null safety across all modules.
- Must avoid UI thread blocking during GeoJSON parsing by caching parsed paths in memory.
- Mobile Ads SDK calls must be guarded to safely no-op on Windows and Web environments.
- Windows Inno Setup build requires proper search paths and parameterized certificate signing secrets.

