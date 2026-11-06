# Historical Engine Features Log for GeoGame

This document tracks all engine and application features across the lifetime of the GeoGame project, categorized by functional subsystem and release milestones. In accordance with Rule 3.1, feature additions are maintained separately from bug fixes in categorized tables.

---

## 1. Game Modes & Spatial Mechanics

| Subsystem / Mode | Introduced / Updated | Core Capabilities & Technical Implementation |
| :--- | :--- | :--- |
| **Capital Guessing** (`/game/capital`) | Initial Release | Multiple-choice capital city identification for countries. Uses dynamic scoring based on speed and accuracy. Driven by `assets/geojson/` and localized string tables. |
| **Flag Recognition** (`/game/flag`) | Initial Release | Vector and raster flag asset rendering with multiple-choice country matching. Eliminates hardcoded mappings via `Country` metadata. |
| **Distance & Bearing** (`/game/distance`) | v1.5.0 / Updated v1.6.0 | Interactive distance and azimuth estimation. Computes real-time Haversine geodesic distance in kilometers and compass bearing relative to target coordinates. |
| **Borderline Mode** (`/game/borderline`) | v1.5.0 | Shared border verification. Evaluates topological adjacency matrices between countries loaded from GeoJSON border structures. |
| **BorderPath Navigation** (`/game/borderpath`) | v1.6.0 | Graph-traversal pathfinding challenge. Players connect start and target nations via contiguous land borders with step-count tracking and state validation. |
| **Find Map (Polygon Pin)** (`/game/findmap`) | v1.6.0 | Interactive GeoJSON boundary rendering. Evaluates player coordinate taps against spatial polygon bounding boxes and ray-casting point-in-polygon tests. |
| **Coat of Arms** (`/game/coatofarms`) | v1.6.5 | National emblem identification game mode. Loads vector and raster heraldic emblems dynamically from asset catalogs. |

---

## 2. Core Services & Architecture Infrastructure

| Subsystem | Version | Technical Capabilities & Architectural Details |
| :--- | :--- | :--- |
| **Authentication Service** (`AuthService`) | v1.0.0 – v1.6.17 | Supabase Authentication integration supporting email/password, guest access, and external OAuth provider handshakes via deep-link interception (`app_links`). |
| **Leaderboard & Cloud Sync** (`GameService`) | v1.0.0 – v1.7.0 | Supabase Postgres backend integration. Calculates and records player XP, mode-specific scores, and country collection completion metrics with UTF-8 payload safety. |
| **GeoJSON Spatial Service** (`GeoJsonService`) | v1.0.0 | High-performance parsing and memory caching of geographic boundary polygons, centroids, and border adjacency graphs. |
| **Monetization Engine** (`AdService`) | v1.6.0 – v1.6.16 | Google Mobile Ads integration supporting banner ads, full-screen interstitial transitions, and rewarded ad placements with safe platform fallbacks. |
| **Rewarded Multiplier** (`BonusService`) | v1.6.13 | 2x score multiplier granted upon successful completion of rewarded advertisement callbacks, persisted across round conclusions. |
| **Telemetry & Observability** (`TelemetryService`) | v1.6.18 – v1.7.0 | Structured event logging and session analytics. Dynamic app version resolution via `package_info_plus` without static memory leakage. |
| **Multi-Language Engine** (`LocalizationService`) | Initial Release | Asset-driven 7-language translation engine (`tur`, `eng`, `deu`, `fra`, `spa`, `por`, `rus`) with runtime locale switching and persistent preferences. |
| **Offline Resilience** (`SplashScreenController`, `ProfileOfflineView`) | v1.6.15 – v1.6.17 | Offline detection and graceful degradation. Bypasses blocking authentication network queries when disconnected, enabling offline gameplay. |

---

## 3. UI/UX & Platform Shell

| Component | Version | Functional Scope |
| :--- | :--- | :--- |
| **Main Scaffold & Navigation** (`MainScaffold`, `CustomNavbar`) | v1.6.13 – v1.7.0 | Adaptive shell navigation utilizing `salomon_bottom_bar` alongside an expandable side drawer for quick access to settings and profiles. |
| **Theme System** (`ThemeModeBuilder`, `SettingsController`) | v1.6.17 | Three-tier theme management supporting Light, Dark, and System-adaptive brightness with persistence in `SharedPreferences`. |
| **Profile & Stats Viewer** (`ProfileViewWidget`) | v1.6.17 – v1.7.0 | Player statistic presentation displaying cumulative XP, ranking tiers, unlocked countries, and privacy boundaries for non-owner profiles. |
| **Responsive Screen Composition** | v1.6.0 – v1.7.0 | Adaptive layout scaling ensuring compatibility across Android phone/tablet viewports, Windows desktop resolutions, and Web browsers. |

---

## 4. Build, Packaging & CI/CD Pipeline

| Pipeline Stage | Implementation | Capabilities |
| :--- | :--- | :--- |
| **Android Release Pipeline** | GitHub Actions (`.github/workflows/release.yml`) | Automated keystore decryption, Gradle build execution with R8 tree-shaking, App Bundle (`.aab`) generation, and Play Store publishing. |
| **Windows Desktop Deployment** | Inno Setup 6 + SignTool | Parameterized Windows executable packaging, Authenticode certificate signing, and installer artifact generation. |
| **Web Production Hosting** | Vercel CLI | Headless build of Flutter Web targets with custom base-href routing, gzip/brotli compression, and environment secret injection. |
| **Automated Release Notes** | Python script (`.github/workflows/`) | Automated changelog synthesis leveraging Gemini API integration, producing multilingual deployment summaries for app store tracks. |

