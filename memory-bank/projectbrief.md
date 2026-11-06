# Project Brief: GeoGame

## 1. Overview
GeoGame is a cross-platform geographical trivia and spatial deduction game developed with Flutter and Dart. It offers an engaging, educational experience across Android, Windows Desktop, and Web platforms.

## 2. Core Objectives
- **Spatial Education & Geography Gaming**: Provide diverse game modes testing capital cities, flags, continental borders, heraldic coats of arms, great-circle distances, and topological pathfinding.
- **Cross-Platform Parity**: Deliver a uniform, high-performance UI across mobile devices, desktop screens, and modern web browsers.
- **100% Data-Driven Architecture**: Eliminate hardcoded game tables and magic strings; drive all gameplay from GeoJSON spatial files, localized dictionaries, and dynamic data models.
- **Offline & Low-Bandwidth Resilience**: Provide graceful fallbacks and offline modes when internet connectivity or remote database services are unavailable.
- **Multi-Language Accessibility**: Support 7 primary world languages natively with runtime localization switching.

## 3. Key Target Platforms
- **Android**: Google Play Store release with adaptive icons, App Bundles (`.aab`), R8 optimizations, and Google Mobile Ads.
- **Windows Desktop**: Inno Setup 6 installer with Authenticode signing and desktop protocol handlers for external OAuth.
- **Web**: Progressive Web App hosted on Vercel with responsive touch and mouse navigation.

## 4. Engineering Invariants
- 100% Sound Null Safety with defensive validation.
- Screen-Controller-Service-Model (SCSM) architectural separation.
- Zero suppression directives (`// ignore:` is strictly prohibited).
- Triple-slash doc-comments scoring $\ge 8/10$ across all public APIs.

