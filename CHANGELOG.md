# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2025-12-22

### Added
- **Global Map Page**:
    - Implemented smooth flight movement animation using linear interpolation.
    - Added aircraft bearing/rotation to match flight direction.
    - Switched map theme to "CartoDB Light" for better visibility.
- **Alerts Page**:
    - Added comprehensive flight status tracking.
    - Now displays Scheduled, Cancelled, Departure, Arrival, and Delay alerts.
    - Implemented custom icons and colors for different alert types.

### Fixed
- **Android Build**:
    - Fixed `AndroidManifest.xml` errors regarding `<uses-permission>` tag placement.
    - Resolved `MissingPluginException` for location services by ensuring clean rebuilding of native dependencies.
- **Performance**:
    - Optimized `DashboardPage` to prevent redundant API calls on screen refresh.
    - Flights are now loaded only once on startup or when the list is empty.

### Changed
- **Dependencies**:
    - Added `flutter_map` for map visualization.
    - Added `latlong2` for coordinate handling.
    - Added `geolocator` for user location features.
