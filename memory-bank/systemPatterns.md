# System Patterns: GeoGame

## 1. Architectural Architecture: SCSM

GeoGame strictly enforces the **Screen-Controller-Service-Model** pattern:

```
UI:           [ Screens ]  <───────>  [ Widgets ]
                   │
                   ▼
Controller:   [ Controllers ]
                   │
                   ▼
Domain:       [ Services ]
                   │
                   ▼
Data:         [ Models ]  <───────>  [ Assets / DB ]
```

### Key Principles
- **Screen**: Responsible solely for widget hierarchy, layout composition, and presentation.
- **Controller**: Manages screen-specific state, text/scroll controllers, dialog interactions, and UI lifecycles. All allocated controllers are disposed explicitly in `dispose()`.
- **Service**: Implements cross-cutting business logic, database queries (Supabase), device sensors, storage (`SharedPreferences`), spatial calculations, and third-party SDK calls.
- **Model**: Immutable data structures representing domain entities (`Country`, `GuessResultModel`, `GameMetadata`, `BorderPathGameData`).
- **Anti-God Object Mandate**: Disconnected domain logic is strictly decomposed into specialized services rather than aggregated into monolithic managers.

## 2. State & Data Flow Patterns
- **Application State (`AppState`)**: Holds globally relevant data such as country datasets, current target country, active country pools, and logged-in user profile.
- **Settings Controller (`SettingsController`)**: Coordinates user preferences (theme mode, audio volume, language locale, continent filters) and persists them synchronously to `PreferencesService`.
- **Data-Driven Execution**: No geographical, national, or rule data is hardcoded in conditional statements. All country data is parsed dynamically from GeoJSON files and localized string assets.

## 3. Spatial & Algorithmic Patterns
- **Haversine Vector Distance**: Used in `DistanceGame` to compute geodesic distance between latitude/longitude centroids.
- **Azimuth / Bearing Calculation**: Normalizes forward bearing angles into 8 cardinal/intercardinal compass directions.
- **Breadth-First Search (BFS)**: Applied to the country border adjacency graph in `BorderPathGame` to compute shortest-path distances and generate solvable pathfinding puzzles.
- **Point-in-Polygon & Ray-Casting**: Used in `FindMapGame` with bounding box pre-filtering to detect touch interactions inside country boundary paths.

## 4. Quality & Coding Invariants
- 100% Sound Null Safety with defensive checks (`?.`, `??`). Force unwrap (`!`) is strictly forbidden.
- Triple-slash doc-comments (`///`) on all public entities (target score $\ge 8/10$).
- Prohibited linter warning suppressions (`// ignore:` is completely banned).
- All source code, comments, identifiers, and logs are 100% English. User plans and chat interactions are Turkish.

