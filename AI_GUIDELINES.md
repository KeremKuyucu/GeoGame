# Permanent AI Agent Instructions for GeoGame

> [!IMPORTANT]
> Loaded on EVERY session and turn. AI MUST strictly follow all instructions herein and in `knowledge/` without exception.

---

## 1. Modern Null Safety & Dart/Flutter Standards (MANDATORY)

- **Rule 1.1 (100% Sound Null Safety Mandate)**: The codebase MUST strictly enforce Dart sound null safety. Force unwrapping (`!`) is strictly forbidden without mathematically verified non-null invariants. Use safe navigation (`?.`), null-coalescing (`??`), and explicit defensive checks.
- **Rule 1.2 (Modern Flutter & Dart Idioms)**: Follow idiomatic Flutter 3.x / Dart 3.x best practices: declare immutable widgets (`@immutable`), use `final` local variables (`prefer_final_locals`), leverage pattern matching, and use `package:` imports exclusively (`always_use_package_imports`). Never use raw `print()` statements; use structured logging or telemetry.
- **Rule 1.3 (API Accuracy & Deprecated API Prohibition)**: Adhere strictly to the latest stable APIs of external packages (`supabase_flutter`, `google_mobile_ads`, `shared_preferences`, `url_launcher`, `package_info_plus`, `vector_math`). Deprecated Flutter widgets, outdated lifecycle hooks, or obsolete package signatures are forbidden.
- **Rule 1.4 (Breaking Changes & User Confirmation)**: Inform the user and request explicit confirmation before introducing breaking changes, altering database schemas (Supabase), modifying routing contracts, or upgrading core SDK/dependency versions.

---

## 2. Mandatory Triple-Slash (`///`) Documentation & Quality Score Rule (MANDATORY)

- **Rule 2.1 (Mandatory Doc-Comments)**: Every new/modified public class, mixin, enum, extension, top-level function, public method, and public property in `lib/` MUST include triple-slash (`///`) doc-comments.
- **Rule 2.2 (Documentation Quality Score Requirement)**: Doc-comments must internally score >=8/10. Lower scores are strictly unacceptable.
- **Rule 2.3 (Meaningful Technical Descriptions)**: Comments must explain purpose, parameters, return types, constraints, state side-effects, and usage context. Merely repeating item names is forbidden.
- **Rule 2.4 (English-Only Source Code & Code Comments Mandate)**: Source code, identifiers, classes, methods, logs, and comments (`///`, `//`) MUST be 100% English. Turkish inside source files is forbidden (except for localized dictionary asset strings in `assets/lang/tr.json`).
- **Rule 2.5 (Turkish Language Mandate for User Plans & Chat Interaction)**: User communication, plans (`implementation_plan.md`), and walkthroughs (`walkthrough.md`) MUST be written in Turkish for optimal clarity.

### Documentation Score Standard

```txt
0/10 = Missing documentation.
1/10 = Useless placeholder comment.
2/10 = Extremely vague and not technically helpful.
3/10 = Mostly repeats the item name.
4/10 = Mentions purpose but lacks useful context.
5/10 = Basic explanation, but incomplete.
6/10 = Understandable but missing constraints, behavior, or usage notes.
7/10 = Good enough for humans, but not strong enough for long-term AI context.
8/10 = Acceptable: clear purpose, parameters, state mutations, and relevant context.
9/10 = Strong: explains purpose, behavior, constraints, error handling, and lifecycle context.
10/10 = Excellent: future-proof, precise, technically rich, and useful for AI/human maintenance.
```

---

## 3. Persistent Knowledge Base & Memory Bank Synchronization (MANDATORY - Zero Postponement)

- **Rule 3.1 (Dual-Track Targeted Synchronous Documentation Execution)**: Synchronously update targeted docs BEFORE completing response:
  - **Bug Fixes**: Log in `knowledge/history/bug_fixes.md`. Never add bug fixes to feature tables.
  - **New Features**: Document in `knowledge/history/engine_features.md` in categorized tables.
  - **Session Progress**: Synchronize in `memory-bank/activeContext.md` & `progress.md`.
- **Rule 3.2 (Zero-Postponement Policy)**: "Will write later" or batching is strictly forbidden. Apply updates immediately in the same turn.
- **Rule 3.3 (Memory Bank Reading on Task Start)**: Read relevant memory bank and history files before starting any task.
- **Rule 3.4 (Dedicated Feature Documentation)**: Create or update a dedicated descriptive `.md` document under `knowledge/` for major new game modes or core service subsystems.

---

## 4. Modular Responsibility, SRP & Clean Boundaries (MANDATORY)

- **Rule 4.1 (Single Responsibility Per File - SRP)**: Every `.dart` file must have ONE specific responsibility. Strictly follow the Screen-Controller-Service-Model architecture:
  - `models/`: Immutable data structures and JSON serialization.
  - `screens/`: UI layout and widget composition only.
  - `controllers/`: Screen-level state management, event handling, and user actions.
  - `services/`: Shared business logic, database queries (Supabase), device I/O, and platform channels.
  - `widgets/`: Reusable, atomic UI components.
- **Rule 4.2 (Anti-God Object Mandate)**: Centralized "manager" classes controlling disconnected domains are strictly forbidden. Decompose large controllers into specialized services.
- **Rule 4.3 (File & Function Size Limits)**: Source files MUST NOT exceed 800 lines. Methods should be focused (<100 lines). Break massive `build()` methods into private sub-widgets or dedicated widget classes.
- **Rule 4.4 (Strict File Boundary Enforcement)**: Existing architectural boundaries are absolute. Never merge files, collapse modules, or centralize logic without explicit instruction.

---

## 5. Scope Isolation, Architecture Preservation & AI Behavior Lock (MANDATORY)

- **Rule 5.1 (Scope Isolation)**: Only modify the explicitly requested file or module. Unrequested changes or refactoring outside the target area are forbidden.
- **Rule 5.2 (No Implicit Refactoring)**: Reorganizing or rewriting code without instruction is forbidden. Existing architecture is stable and production-grade.
- **Rule 5.3 (AI Behavior Lock & Uncertainty Resolution)**: Never assume missing context or guess. If uncertain or facing ambiguity, ASK the user.

---

## 6. Comprehensive Quality, Formatting & Static Analysis Verification (MANDATORY)

- **Rule 6.1 (Multi-Tool Verification Suite)**: Whenever Dart source code or configurations (`.dart`, `pubspec.yaml`, `analysis_options.yaml`) are modified, execute before completion:
  1. `flutter analyze` (0 warnings / 0 errors / 0 hints).
  2. `dart format --output=none --set-exit-if-changed .` (100% compliant).
  3. `flutter test` (100% passed).
  *(Skip checks if only markdown files (`.md`) or documentation are modified).*
- **Rule 6.2 (Quantitative Performance & Resource Reporting)**: When modifying source code, report: widget rebuild efficiency, memory leak avoidance, and APK/binary size impact.
- **Rule 6.3 (Mandatory Verification Report Block)**: When source code changes are made, final response MUST include:
  - 🛠️ **Flutter Analyze**: 0 warnings / 0 errors / 0 hints
  - 🎨 **Dart Format**: 100% Compliant
  - 🧪 **Flutter Test**: All tests passed (X passed, 0 failed)
  - ⚡ **Performance Impact**: [Quantitative impact, e.g., "0.0% change, const optimized"]
  - 🧠 **Memory & Disposal**: [Controllers/Listeners disposed cleanly, zero leaks]
  - 📦 **Bundle Size Impact**: [Impact delta, e.g., "+0 KB"]
- **Rule 6.4 (Mandatory Controller & Service Testing)**: Whenever scoring logic, distance algorithms (Haversine vector math), GeoJSON parsers, or offline sync handlers are modified, unit tests MUST be written to verify edge cases (zero distance, disconnected network, invalid JSON, null user sessions).

---

## 7. Widget Lifecycle & Memory Leak Prevention (MANDATORY)

- **Rule 7.1 (Mandatory Controller Disposal)**: Every instantiated `TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`, `StreamSubscription`, and `Timer` MUST be cancelled and disposed inside `State.dispose()`.
- **Rule 7.2 (Const Constructor Mandate)**: Use `const` constructors wherever possible (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`) to enable Flutter compile-time widget tree caching and eliminate redundant layout passes.
- **Rule 7.3 (Rebuild Minimization)**: Avoid invoking `setState()` at the root widget level when a local subtree state update suffices. Keep stateful boundaries as close as possible to the changing leaf nodes.

---

## 8. Absolute Prohibition of Linter Warning Suppressions (`// ignore:` - MANDATORY)

- **Rule 8.1 (Universal Ban on Ignore Directives)**: Directives like `// ignore: ...` or `// ignore_for_file: ...` are universally banned without exception.
- **Rule 8.2 (Refactor Over Suppression)**: Resolve linting issues at their root cause: fix missing `const`, add required keys (`use_key_in_widget_constructors`), correct import paths, and handle nullability cleanly.
- **Rule 8.3 (Root-Cause Engineering)**: Resolve warnings at root cause; never sweep under the rug.

---

## 9. Data-Driven Game Mechanics & Magic String Prohibition (MANDATORY)

- **Rule 9.1 (Universal Ban on Hardcoded Country / Game Data)**: Game decisions, question generators, and score calculations MUST NEVER rely on hardcoded switch statements or magic string matching.
- **Rule 9.2 (100% Data-Driven Architecture)**: All geographical data, borders, capitals, flags, coats of arms, and translations must be driven dynamically from `assets/geojson/`, `assets/lang/`, `Country` models, or Supabase tables.
- **Rule 9.3 (Asset & Localization Independence)**: The game must function seamlessly across all 7 supported languages without breaking UI layouts, text overflow, or character encoding issues.

---

## 10. Neutral & Brand-Free Technical Documentation Standard (MANDATORY)

- **Rule 10.1 (No Third-Party Software / Brand Name-Dropping)**: Never reference third-party commercial software by name in comments, commits, or docs ("Unreal-style", "Wordle-clone" are forbidden in code docs; describe algorithmic patterns directly: e.g. "iterative distance and bearing feedback game").
- **Rule 10.2 (No Hype or Superlative Adjectives)**: Subjective marketing words ("AAA", "perfect", "flawless", "legendary", "world-class") are forbidden.
- **Rule 10.3 (Factual, Concise & Objective Engineering Language)**: Documentation and comments must describe only what the code does, inputs/outputs, spatial mathematics, and architectural purpose in objective engineering language.
