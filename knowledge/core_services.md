# GeoGame Core Services Specification

This document details the service layer architecture of GeoGame. Following the Screen-Controller-Service-Model architecture, services encapsulate all business logic, data persistence, network communication, hardware APIs, and external SDK integrations.

---

## 1. Authentication Service (`AuthService`)
- **File**: `lib/services/auth_service.dart`
- **Scope**: User lifecycle management, session persistence, and credential validation.
- **Provider**: Supabase Auth (`supabase_flutter`).

### Key Capabilities
- **Email & Password**: Registration, login, password recovery, and session token renewal.
- **OAuth Providers**: Google Sign-In with web browser redirect flow and desktop protocol handler (`app_links`).
- **Guest Authentication**: Supports unauthenticated gameplay without blocking initialization.
- **Session Cache**: Automatically syncs authenticated user profile state into `AppState.currentUser`.

---

## 2. Game Logic & Cloud Sync Service (`GameService`)
- **File**: `lib/services/game_service.dart`
- **Scope**: Game session orchestration, country picking, spatial math, and cloud persistence.
- **Backend**: Supabase Postgres database (`scores`, `user_stats`, `leaderboards`).

### Key Capabilities
- **Session Management**: Initializes game pools filtered by active continent and difficulty settings.
- **Spatial Calculations**: Haversine distance and 8-point compass bearing calculations for distance mode.
- **Graph Pathfinding**: BFS shortest-path distance calculation over country border adjacency matrices for BorderPath mode.
- **Leaderboards**: Asynchronous fetching of global rankings, player position calculations, and high score commits with UTF-8 byte stream decoders to avoid encoding corruption.
- **Country Collection**: Tracks visited and successfully guessed countries per player account.

---

## 3. GeoJSON Spatial Parsing Service (`GeoJsonService`)
- **File**: `lib/services/geojson_service.dart`
- **Scope**: High-performance loading, decoding, and conversion of GeoJSON geographic features into Flutter graphics objects.

### Key Capabilities
- **Polygon Path Generation**: Parses GeoJSON `MultiPolygon` and `Polygon` coordinates, translating spherical coordinates to 2D canvas coordinates.
- **Cache Strategy**: In-memory caching of parsed `Map<String, Path>` objects to eliminate repetitive disk I/O and JSON parsing during screen navigation.
- **Simplified Map Layer**: Provides downsampled polygon geometries for responsive mobile performance.

---

## 4. Monetization & Advertisement Service (`AdService`)
- **File**: `lib/services/ad_service.dart`
- **Scope**: Google Mobile Ads SDK lifecycle management (`google_mobile_ads`).

### Key Capabilities
- **Banner Ads**: Non-intrusive adaptive banners placed at screen bottoms.
- **Interstitial Ads**: Transition advertisements shown between completed game sessions.
- **Rewarded Ads**: Video ad placement that awards a 2x score multiplier for the active game round upon completion.
- **Platform Guards**: Safe no-op execution on desktop (Windows) and Web targets where Mobile Ads SDK is inactive or unsupported.

---

## 5. Telemetry & Analytics Service (`TelemetryService`)
- **File**: `lib/services/telemetry_service.dart`
- **Scope**: Privacy-compliant session analytics, daily active user tracking, and error diagnostics.

### Key Capabilities
- **Hardware / Device Info**: Generates pseudonymous device tokens using `shared_preferences` and UUIDs.
- **Dynamic Versioning**: Queries `package_info_plus` at runtime for accurate application build numbers without static cache staleness.
- **Structured Dispatch**: Fire-and-forget telemetry events sent to remote collection endpoints.

---

## 6. Score Bonus Engine (`BonusService`)
- **File**: `lib/services/bonus_service.dart`
- **Scope**: Multiplier logic, daily reward streaks, and bonus validation.

### Key Capabilities
- **2x Multiplier**: Connects with `AdService` rewarded events to temporarily apply double score multipliers to subsequent game rounds.
- **Streak Tracking**: Tracks consecutive days of gameplay and adjusts XP multipliers accordingly.

---

## 7. Multilingual Localization Engine (`LocalizationService`)
- **File**: `lib/services/localization_service.dart`
- **Scope**: Translation asset loading and runtime string interpolation.

### Key Capabilities
- **Supported Locales**: 7 languages (`tur`, `eng`, `deu`, `fra`, `spa`, `por`, `rus`).
- **Asset Structure**: Key-value JSON dictionaries loaded from `assets/lang/{locale}.json`.
- **Dynamic Argument Substitution**: Replaces `{0}`, `{1}` placeholders dynamically at runtime.
- **Country Name Translation**: Resolves official and common country names into the active player language.

---

## 8. Preferences & Settings Persistence (`PreferencesService`)
- **File**: `lib/services/preferences_service.dart`
- **Scope**: Key-value settings storage (`shared_preferences`).

### Key Capabilities
- **Theme Selection**: Light, Dark, or System brightness.
- **Audio & Haptics**: Sound effects volume and haptic vibration feedback toggles.
- **Game Filters**: Active continent selections, input mode (Buttons vs. Text Field), and difficulty tiers.

---

## 9. Game Question Logging Service (`GameLogService`)
- **File**: `lib/services/game_log_service.dart`
- **Scope**: Historical question log tracking, correct/wrong answer tallies, and post-game review data.

---

## 10. Haptic Feedback Service (`HapticService`)
- **File**: `lib/services/haptic_service.dart`
- **Scope**: Physical device vibration patterns triggered on success or error answers.

