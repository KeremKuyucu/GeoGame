# GeoGame Architectural Architecture & Engineering Standards

This document establishes the structural patterns, layer boundaries, and quality requirements of the GeoGame engine.

---

## 1. Architectural Layers: Screen-Controller-Service-Model (SCSM)

```
[ UI / Presentation ]
      │
      ├──> Screens (`lib/screens/`)      ── View composition, layout, stateless widgets
      │         │
      │         ▼
      ├──> Controllers (`lib/screens/`)  ── Screen-level state, event handlers, lifecycle management
      │         │
      │         ▼
[ Domain & Infrastructure ]
      ├──> Services (`lib/services/`)    ── Business logic, network, storage, math, third-party SDKs
      │         │
      │         ▼
      └──> Models (`lib/models/`)        ── Immutable data structures, JSON serialization
```

### Layer Responsibilities

#### 1. Models (`lib/models/`)
- Plain Dart objects with immutable fields (`final`).
- Factory constructors for JSON serialization/deserialization.
- No UI dependencies (`package:flutter/material.dart` is prohibited except for specific UI configuration models like `GameMetadata`).

#### 2. Services (`lib/services/`)
- Stateless or singleton service providers.
- Encapsulate external libraries (`supabase_flutter`, `google_mobile_ads`, `shared_preferences`).
- Provide clean, typed asynchronous APIs returning domain models or records.
- Must never interact directly with Flutter widget contexts or trigger UI navigation.

#### 3. Controllers (`lib/screens/**/`)
- Dedicated controllers paired 1:1 with corresponding screens (e.g., `CapitalController` for `CapitalGame`).
- Manage input controllers (`TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`).
- Invoke service methods, update reactive state, and expose presentation-ready data.
- **Mandatory Lifecycle**: Implement `dispose()` to cleanly release all allocated controllers and subscriptions.

#### 4. Screens & Widgets (`lib/screens/`, `lib/widgets/`)
- Declarative Flutter widget trees.
- Minimal or zero business logic in `build()` methods.
- Massive widgets must be broken into private helper widgets or dedicated atomic components in `lib/widgets/`.

---

## 2. Memory Leak Prevention & Lifecycle Rules

1. **Explicit Disposal**:
   Any resource extending `ChangeNotifier` (`TextEditingController`, `ScrollController`, `AnimationController`, `FocusNode`) or stream subscriptions (`StreamSubscription`, `Timer`) MUST be disposed or cancelled in the owning `State.dispose()`.
2. **Const Constructor Mandate**:
   All static UI nodes must use `const` constructors to facilitate compile-time widget caching and eliminate redundant layout and painting passes.
3. **Local Subtree State**:
   Avoid invoking `setState()` on high-level root widgets. State changes should be localized to leaf widgets or controlled subtrees.

---

## 3. Strict Linter & Quality Standards

- **Zero Tolerance for Ignore Directives**:
  `// ignore:` and `// ignore_for_file:` directives are strictly prohibited across the entire codebase. All compiler warnings and static analyzer hints must be addressed at their root cause.
- **Sound Null Safety**:
  Codebase operates under 100% sound null safety. Force unwrapping (`!`) without mathematically provable invariants is banned. Safe navigation (`?.`) and null-coalescing (`??`) must be used defensively.
- **Doc-Comment Quality**:
  All public classes, methods, and properties must feature `///` doc-comments with high descriptive clarity (quality score $\ge 8/10$).

