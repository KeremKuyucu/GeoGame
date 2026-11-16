# Release Template

Use this file as a template when writing release notes for GeoGame.
Copy the template below and fill in the placeholders.
File name: `RELEASE_X.X.X.md`

---

## [Short Release Title]

> **⚠️ Breaking Changes**
> - [Breaking change description]

### 🚀 Features & Improvements

* **[Feature/Improvement Name]:**
  [Description of the feature or improvement]

* **[Feature/Improvement Name]:**
  [Description of the feature or improvement]

### 🐛 Bug Fixes

* [Bug fix description]
* [Bug fix description]

---

# Example

## Architecture Refactoring & Build Automation

> **⚠️ Breaking Changes**
> - Minimum supported Android SDK bumped from API 21 to API 24.

### 🚀 Features & Improvements

* **Authentication System Refactoring:**
  Separated UI logic from core authentication service with new `AuthUIService` and `AuthScreen` components.

* **Enhanced Build Automation:**
  - Interactive platform selection menu with keyboard navigation
  - GitHub Release automation with smart detection

* **Security Improvements:**
  Android signing credentials moved to external `key.properties` file.

### 🐛 Bug Fixes

* Fixed update notification not appearing on Android devices
* Resolved import dependency issues

---

# Emoji Reference

| Emoji | Usage |
|-------|-------|
| 🚀 | Features & improvements |
| 🐛 | Bug fixes |
| ⚠️ | Breaking changes |
| 🔒 | Security |
| ⚡ | Performance |
| 🎨 | UI/UX changes |
| 🔧 | Configuration |
| 📝 | Documentation |
| 🌐 | Localization |
