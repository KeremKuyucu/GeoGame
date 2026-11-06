# GeoGame Modes Technical Specification

This document provides a comprehensive technical overview of the 7 game modes supported in GeoGame. Each mode is designed around spatial, geographical, and heraldic knowledge, adhering to the data-driven architecture and Screen-Controller-Service-Model design principles.

---

## 1. Capital City Mode (`/game/capital`)

### Purpose & Concept
Tests player knowledge of world capitals by presenting a target nation and requesting the corresponding capital city name.

### Technical Architecture
- **Screen**: `lib/screens/games/capital/capital_screen.dart`
- **Controller**: `lib/screens/games/capital/capital_controller.dart`
- **Service Layer**: `lib/services/game_service.dart`
- **Models**: `Country`, `GameMetadata` (`GameType.capital`)

### Gameplay Flow & Mechanics
1. **Round Initialization**: `GameService.initializeGame(GameType.capital)` filters the eligible country pool based on user filter preferences (continents, difficulty) stored in `SettingsController`.
2. **Question Generation**: Selects `AppState.targetCountry` and generates multiple-choice options (`isButtonMode`) or waits for text input (`textController`).
3. **Validation**: Input is compared against `Country.capital` using case-insensitive, diacritic-insensitive normalization via `Country.matchesSearch()`.
4. **Scoring**: Correct answers increment streak counters and award base XP multiplied by active streak bonuses.

---

## 2. Flag Recognition Mode (`/game/flag`)

### Purpose & Concept
Tests visual recognition of national flags. Players identify the country corresponding to a displayed national flag.

### Technical Architecture
- **Screen**: `lib/screens/games/flag/flag_screen.dart`
- **Controller**: `lib/screens/games/flag/flag_controller.dart`
- **Widgets**: `lib/widgets/flag_loader.dart`
- **Models**: `Country`, `GameMetadata` (`GameType.flag`)

### Assets & Optimization
- **Asset Paths**: `assets/flags/{iso2.toLowerCase()}.png` or SVG equivalents.
- **Rendering**: Cached and scaled using `FlagLoader` to avoid UI jank during rapid round transitions.
- **Fallbacks**: Graceful loading indicators and placeholder emblems if an asset is unavailable.

---

## 3. Distance & Bearing Mode (`/game/distance`)

### Purpose & Concept
An iterative spatial deduction game where each guess provides spatial vector feedback: distance to the target in kilometers and directional compass bearing.

### Technical Architecture
- **Screen**: `lib/screens/games/distance/distance_screen.dart`
- **Controller**: `lib/screens/games/distance/distance_controller.dart`
- **Widgets**: `lib/widgets/distance_widgets.dart`
- **Models**: `GuessResultModel`, `Country`, `GameMetadata` (`GameType.distance`)

### Mathematical Foundation

#### 1. Haversine Great-Circle Distance
Computes the spherical distance between the guessed country's centroid $(lat_1, lon_1)$ and target country's centroid $(lat_2, lon_2)$:

$$\Delta\phi = \frac{(lat_2 - lat_1) \cdot \pi}{180}$$
$$\Delta\lambda = \frac{(lon_2 - lon_1) \cdot \pi}{180}$$
$$a = \sin^2\left(\frac{\Delta\phi}{2}\right) + \cos\left(\frac{lat_1 \cdot \pi}{180}\right) \cdot \cos\left(\frac{lat_2 \cdot \pi}{180}\right) \cdot \sin^2\left(\frac{\Delta\lambda}{2}\right)$$
$$c = 2 \cdot \text{atan2}\left(\sqrt{a}, \sqrt{1 - a}\right)$$
$$d = R \cdot c \quad (\text{where } R = 6371.0 \text{ km})$$

The resulting distance is rounded to the nearest kilometer.

#### 2. Forward Azimuth & 8-Point Compass Bearing
Computes the initial bearing from guess to target:

$$y = \sin(\Delta\lambda) \cdot \cos\left(\frac{lat_2 \cdot \pi}{180}\right)$$
$$x = \cos\left(\frac{lat_1 \cdot \pi}{180}\right) \cdot \sin\left(\frac{lat_2 \cdot \pi}{180}\right) - \sin\left(\frac{lat_1 \cdot \pi}{180}\right) \cdot \cos\left(\frac{lat_2 \cdot \pi}{180}\right) \cdot \cos(\Delta\lambda)$$
$$\theta = \left(\text{atan2}(y, x) \cdot \frac{180}{\pi} + 360\right) \pmod{360}$$

The degree is discretized into 8 cardinal/intercardinal compass sectors ($45^\circ$ each with $+22.5^\circ$ offset for centering):
$$\text{Sector Index} = \left\lfloor\frac{\theta + 22.5}{45}\right\rfloor \pmod 8$$
Mapped to: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.

---

## 4. Borderline Adjacency Mode (`/game/borderline`)

### Purpose & Concept
Tests knowledge of political borders and neighboring countries.

### Technical Architecture
- **Screen**: `lib/screens/games/borderline/borderline_screen.dart`
- **Controller**: `lib/screens/games/borderline/borderline_controller.dart`
- **Widgets**: `lib/widgets/borderline_widgets.dart`

### Mechanics
- Given a target country $C_{target}$, candidate nations $C_{candidate}$ are presented.
- Adjacency is verified against the `Country.borders` ISO-code list derived from GeoJSON topological boundary relations.
- Island nations with zero terrestrial borders are filtered from round generation to prevent deadlock.

---

## 5. BorderPath Navigation Mode (`/game/borderpath`)

### Purpose & Concept
A topological pathfinding game. Given a starting nation $A$ and destination nation $B$, the player must navigate from $A$ to $B$ step-by-step by selecting contiguous bordering countries.

### Technical Architecture
- **Screen**: `lib/screens/games/borderpath/borderpath_screen.dart`
- **Controller**: `lib/screens/games/borderpath/borderpath_controller.dart`
- **Widgets**: `lib/widgets/borderpath_widgets.dart`
- **Models**: `BorderPathGameData`

### Graph Algorithm & Level Generation
1. **Adjacency Graph**: Built dynamically from `Country.borders` across all terrestrial nations.
2. **Breadth-First Search (BFS)**:
   - Traverses the border graph from a randomly chosen start node.
   - Computes shortest path distances to all reachable nodes.
3. **Path Constraints**: Target node is selected such that the shortest path length satisfies $2 \le \text{dist} \le 5$.
4. **Validation**: Each user choice must exist within the current country's immediate border set. The round concludes when the target nation is reached.

---

## 6. Find Map (Interactive Polygon Pin) Mode (`/game/findmap`)

### Purpose & Concept
An interactive cartographic game where players must locate and tap a designated country on an interactive world map.

### Technical Architecture
- **Screen**: `lib/screens/games/findmap/findmap_screen.dart`
- **Controller**: `lib/screens/games/findmap/findmap_controller.dart`
- **Service**: `GeoJsonService.loadWorldMapSimplified()`
- **Math**: `vector_math_64` for transformation matrices

### Graphics & Spatial Indexing
1. **GeoJSON Vector Paths**: Country borders are converted into Flutter `Path` objects in Mercator/Equirectangular projection space.
2. **Bounding Box Cache**: Bounding boxes (`Rect`) are cached per country to allow $O(1)$ fast rejection before executing expensive `Path.contains(point)` checks.
3. **Small Country Markers**: Countries whose bounding area $\text{width} \times \text{height} < 2000.0$ are classified as microstates/small territories; circular visual markers and expanded touch targets are drawn to ensure touch accessibility on mobile viewports.
4. **Interactive Viewer Matrix**: Supports pan, pinch-to-zoom, and transforms screen touch events into world canvas coordinates via inverse matrix multiplication.

---

## 7. Coat of Arms Mode (`/game/coatofarms`)

### Purpose & Concept
Heraldic identification game where players identify countries by their national emblem or coat of arms.

### Technical Architecture
- **Screen**: `lib/screens/games/coat_of_arms/coat_of_arms_screen.dart`
- **Controller**: `lib/screens/games/coat_of_arms/coat_of_arms_controller.dart`
- **Widgets**: `lib/widgets/coat_of_arms_loader.dart`
- **Models**: `Country`, `GameMetadata` (`GameType.coatofarms`)

### Asset Pipeline
- Loaded from asset directories with fallback mechanisms.
- Supports high-resolution vector and raster renderings.
- Dynamic question generation ensures uniform country distribution across rounds.

