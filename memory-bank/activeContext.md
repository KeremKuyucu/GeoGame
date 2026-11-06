# Active Context: GeoGame

## Current Status
- **App Version**: `v1.7.0+25` (Dart `>=3.4.3 <4.0.0`, Flutter 3.x)
- **Primary Focus**: Comprehensive Memory Bank initialization and synchronous Knowledge Base alignment across all historical and current engine codebases, in full compliance with `AI_GUIDELINES.md`.

## Recent Activities & Commits
- **v1.7.0 Release Milestones**:
  - `cbcc125`: Fixed profile privacy defect by hiding country statistics when viewing other players' profiles.
  - `6f87309`: Refactored `TelemetryService` to eliminate static memory caching for application version and user ID.
  - `a933deb`: Cleaned up legacy `childMode` configuration remnants from `AppSettings`.
  - `20d4d32`: Integrated `package_info_plus` for runtime version and build resolution.
  - `93fe3ce`: Added automated CI release notes generator powered by Gemini API.
  - `b0c0030`: Integrated telemetry service, navigation drawer widget, and Vercel web deployment configuration.
- **AI Agent Guidelines**: Implemented strict engineering invariants in `AI_GUIDELINES.md` (null safety, SRP, doc-comments score $\ge 8/10$, linter zero-suppression policy, Turkish communication).

## Active Decisions & Considerations
- **Memory Bank & Knowledge Base Sync**: Knowledge base has been initialized with full retroactive logs (`knowledge/history/bug_fixes.md`, `knowledge/history/engine_features.md`, `knowledge/game_modes.md`, `knowledge/core_services.md`, `knowledge/architecture.md`).
- **Static Analysis Compliance**: Analyzer exclude rules in `analysis_options.yaml` exclude generated platform artifacts (`build/**`, `android/**`, `web/**`, `windows/**`) while strictly verifying all `lib/` and `test/` Dart source files.

## Immediate Next Steps
1. Maintain synchronized logs in `knowledge/history/` on every feature addition or bug fix without delay.
2. Ensure every subsequent Dart code change passes the complete verification suite (`flutter analyze`, `dart format`, `flutter test`).
3. Adhere strictly to the Screen-Controller-Service-Model architecture when extending gameplay or service features.

