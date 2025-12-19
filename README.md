# Flight Tracker App

## Overview
Flight Tracker is a real-time flight tracking mobile application built with Flutter. It helps users monitor domestic and international flights, providing live updates on locations, delays, gate information, and more.

## Features
- **Real-time Flight Tracking**: View live status of flights.
- **Search**: Search by flight number, route, or airport.
- **Flight Details**: Comprehensive details including airline, gate, status, and times.
- **Favorites**: Save flights for quick access (Planned).
- **Notifications**: Alerts for delays and gate changes (Planned).
- **Modern UI**: specialized responsive design with smooth animations.

## Architecture
The project follows **Clean Architecture** with **MVVM** pattern using the `provider` package for state management.

### Layers:
1.  **Domain**: Pure Dart code containing Entities, UseCases, and Repository Interfaces. This layer is independent of external libraries.
2.  **Data**: Handles data retrieval. Contains Models (data transfer objects), Data Sources (API/Local), and Repository Implementations.
3.  **Presentation**: UI and State Management. Contains Widgets, Pages, and Providers (ViewModels).

### Tech Stack
-   **Flutter SDK**: Core framework.
-   **Provider**: State management.
-   **Google Fonts**: Typography.
-   **Animate Do**: Animations.
-   **Shimmer**: Loading effects.
-   **Flutter SVG**: Vector assets.

## API Service
Currently, the app uses a **Mock Service Layer** simulating the **AviationStack API**.
The structure is ready to easily swap the mock data source with a real HTTP client once the API key is available.

## Getting Started

1.  **Prerequisites**:
    -   Flutter SDK installed.
    -   VS Code or Android Studio.

2.  **Installation**:
    ```bash
    git clone <repo_url>
    cd flight_tracker
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

## Project Structure
```
lib/
├── core/           # Constants, Themes, Utilities
├── data/           # Remote Data Sources, Models, Repositories Implementation
├── domain/         # Entities, Repository Interfaces, Use Cases
├── presentation/   # UI Pages, Widgets, ViewModels (Providers)
└── main.dart       # Entry point
```

## Future Improvements
- Integrate real AviationStack API key.
- Setup Firebase Cloud Messaging (FCM) for push notifications.
- Implement local storage for "Favorites" flights.
# flight_tracker
