# Historical Bug Fixes Log for GeoGame

This document tracks all historical bug fixes across the lifetime of the GeoGame project, categorized chronologically by release version and date. In accordance with Rule 3.1, bug fixes are documented separately from feature additions.

---

## Release v1.7.0 Series (October 2026)

### Hide Country Stats on Foreign Profiles
- **Commit**: `cbcc125` (2026-10-26)
- **Subsystem**: User Profile (`lib/screens/profiles/profiles_controller.dart`, `lib/widgets/profile_view_widget.dart`)
- **Root Cause**: When a player viewed another user's profile from the global leaderboard, the UI attempted to display local country completion statistics that belonged to the logged-in user rather than the selected player, leading to misleading data.
- **Resolution**: Added profile ownership checks; hid local country collection stats when `isCurrentUser` is false, showing only public metrics (total score, rank, avatar, and badges).

### NDK ABI Filters Conflict with Flutter Split-per-ABI
- **Commit**: `ec7b16f` (2026-10-07)
- **Subsystem**: Android Build System (`android/app/build.gradle`)
- **Root Cause**: Explicit `ndk { abiFilters ... }` in `build.gradle` conflicted with Flutter's `--split-per-abi` release build flag, causing Gradle build failures during automated APK generation.
- **Resolution**: Removed hardcoded `abiFilters` block, allowing Flutter build engine to automatically partition ABI architectures (`armeabi-v7a`, `arm64-v8a`, `x86_64`) cleanly.

### Play Store Service Account JSON Validation and BOM Encoding
- **Commit**: `9bc44c0` (2026-10-02)
- **Subsystem**: CI / CD Deployment (`scripts/upload_play_store.py`, `.github/workflows/`)
- **Root Cause**: UTF-8 Byte Order Marks (BOM) in GitHub Secrets caused Python's JSON parser to crash when decoding Google Play Console API service account credentials.
- **Resolution**: Added explicit UTF-8 BOM sanitization and validation checks before initializing Google API client libraries.

---

## Release v1.6.15 Series (September 2026)

### Windows Authenticode Installer Signing & Password Handling
- **Commit**: `46b6276`, `704760d` (2026-09-30)
- **Subsystem**: CI / CD Windows Build (`.github/workflows/release.yml`)
- **Root Cause**: The Windows Inno Setup installer signing step failed due to missing certificate password injection from GitHub Secrets, and self-signed certificates were rejected by default store trust policies.
- **Resolution**: Passed `WINDOWS_PFX_PASSWORD` securely to `signtool.exe`, imported certificates into the temporary runner Root store, and added graceful fallback flags.

### Vercel Web Deployment Secret Encoding & Project Configuration
- **Commit**: `6fa7185`, `416b342`, `911dfd5`, `77bffbc` (2026-09-30)
- **Subsystem**: Web Hosting (`web/.vercel/project.json`, GitHub Actions)
- **Root Cause**: The third-party `vercel-action` failed to authenticate due to environment variable masking and corrupted base64 secret decoding in headless CI environments.
- **Resolution**: Replaced third-party GitHub Action with direct Vercel CLI commands, moved project configuration to `web/.vercel/project.json`, and inlined validated environment secrets.

### Release Notes Generator Console Encoding & Safety Timeouts
- **Commit**: `4713983`, `a673147` (2026-09-30)
- **Subsystem**: Release Automation (`scripts/generate_release_notes.py`)
- **Root Cause**: Windows PowerShell console encoding caused Unicode character errors when outputting multi-language release notes, and Google Play Console API uploads hung indefinitely on slow networks.
- **Resolution**: Enforced UTF-8 console streams and added an explicit 120-second connection timeout with 3-step exponential retry logic to the upload script.

### Offline Splash Launch & Unauthenticated Profile Flow
- **Commit**: `8d89e62` (2026-09-27)
- **Subsystem**: App Initialization (`lib/screens/splash_screen/`, `lib/screens/profiles/`)
- **Root Cause**: When launching the application with no internet connectivity, the splash screen hung trying to establish initial Supabase session handshakes, preventing offline gameplay.
- **Resolution**: Added network timeout guards in `SplashScreenController`; created dedicated offline and guest fallback views (`ProfileOfflineView`, `ProfileGuestView`) to allow immediate local play.

### Integration Test Asynchronous Startup & Error Boundary
- **Commit**: `46209f7`, `41a2a98` (2026-09-17)
- **Subsystem**: Integration Testing (`integration_test/`)
- **Root Cause**: Unhandled asynchronous startup errors in widget tests overwrote `FlutterError.onError`, obscuring root cause failures during CI test execution.
- **Resolution**: Preserved existing error handlers, added missing `integration_test` dependencies to `pubspec.yaml`, and resolved static analyzer hints.

### Inno Setup PowerShell Search Path Condition Syntax
- **Commit**: `f952479` (2026-09-17)
- **Subsystem**: Windows Build Scripts (`scripts/build_windows.ps1`)
- **Root Cause**: Unparenthesized compound condition in `Test-Path` caused evaluation errors when searching for the Inno Setup 6 binary across 32-bit and 64-bit Program Files directories.
- **Resolution**: Parenthesized path existence checks and added fallback executable discovery paths.

### Windows OAuth Authentication State Auto-Refresh
- **Commit**: `53c70c3` (2026-09-07)
- **Subsystem**: Authentication (`lib/screens/auth/auth_controller.dart`, `app_links`)
- **Root Cause**: After completing Google OAuth in an external desktop browser on Windows, returning to the application did not trigger a UI state refresh, leaving the login screen in a pending state.
- **Resolution**: Listened to deep link events via `app_links` protocol handler on Windows, automatically refreshing `AuthService` state upon receiving the auth redirect callback.

---

## Early Releases (v1.0.0 – v1.6.0)

### Distance Game Round Initialization Null Pointer
- **Commit**: `4ec5501` (2026-01-22)
- **Subsystem**: Distance Game Mode (`lib/screens/games/distance/distance_controller.dart`)
- **Root Cause**: Invoking `startNewRound()` when targeting overseas territories with missing coordinates threw an unhandled null assertion.
- **Resolution**: Added fallback coordinate resolution and validated latitude/longitude pairs before round initialization.

### Leaderboard API Character Encoding Corruption
- **Commit**: `c665943` (2025-06-07)
- **Subsystem**: Leaderboard Service (`lib/services/game_service.dart`)
- **Root Cause**: HTTP response body parsing defaulted to Latin-1, causing non-ASCII player usernames (Turkish, German, Russian characters) to render as mojibake.
- **Resolution**: Explicitly passed `utf8.decode(response.bodyBytes)` when deserializing JSON payloads.

### Country Geographical Data Coordinates Fix
- **Commit**: `429815e` (2025-06-07)
- **Subsystem**: Geographical Assets (`assets/geojson/`, `lib/models/countries.dart`)
- **Root Cause**: Several newly added island nations had inverted latitude and longitude entries, breaking distance and bearing math.
- **Resolution**: Corrected coordinate tuples and updated spatial index boundaries.
