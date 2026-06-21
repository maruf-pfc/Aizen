# Aizen Ecosystem ⚡

Aizen is a massive, premium, local-first productivity ecosystem. It features a clean, high-density, minimalist user interface inspired by compact layouts like Bitwarden and Telegram, customized with an AMOLED Dark theme and full Material 3 styling.

---

## 🛠️ Technology Stack
- **Framework**: Flutter (v3.35.1) & Dart (v3.9.0)
- **State Management**: flutter_bloc & equatable
- **Typography**: Google Fonts (Lexend) for clean, high-density interface readability
- **Branding**: Custom, premium abstract geometric emblem launcher icon
- **Persistence**: shared_preferences
- **Testing**: flutter_test, bloc_test, and mocktail
- **Deployment**: Docker & Nginx (Web serving), GitHub Actions (CI/CD / APK release compiler)

---

## 📂 Feature Architecture
Aizen follows a **Feature-First Layered Architecture** structure. Code for each module is located in `lib/features/<module_name>/` and structured into three layers:
1. **Domain Layer**: Entities, repository contracts, and use cases.
2. **Data Layer**: Models, local data sources, and repository implementations.
3. **Presentation Layer**: BLoCs, custom tickers, contextual widgets, and pages.

For a comprehensive guide, view the [Aizen Documentation Index](docs/README.md).

---

## 🚀 Getting Started

### 1. Local Development
Ensure you have the Flutter SDK (channel stable, v3.35.x) installed on your system:

```bash
# Clone the repository
git clone https://github.com/blackstart-labs/Aizen.git
cd Aizen

# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Launch the application
flutter run
```

### 2. Testing Suite
Aizen implements strict unit, bloc, and widget tests:

```bash
# Run the entire test suite
flutter test
```

### 3. Docker Deployments (Web Serve)
Aizen is containerized for simple server deployment using Docker:

```bash
# Build the Docker image
docker build -t blackstart-labs/aizen:latest .

# Run the container (access web panel at http://localhost:8080)
docker run -d -p 8080:80 blackstart-labs/aizen:latest
```

---

## 📦 Active Modules

### 1. Stopwatch Module (v1.0.0)
- **High-Precision**: Centisecond-resolution display.
- **Data Persistence**: Survives app process kills by calculating time intervals using system clock offsets:
  $$\text{elapsedTime} + (\text{DateTime.now()} - \text{startTime})$$
- **High-Performance**: Ticker-driven leaf widgets update numbers independently from the parent BLoC.
- **Lap Table**: Shows split durations and cumulative times; highlights the fastest lap in mint green and the slowest lap in coral red.
- **Detailed Docs**: Refer to [Stopwatch Module Specifications](docs/features/stopwatch.md).

### 2. Device Info System Module (v1.2.0)
- **Deep Hardware Specs**: Queries and exposes CPU core count (`Platform.numberOfProcessors`), system memory, model, manufacturer, and kernel architecture.
- **Reactive Battery Stream**: Listens to battery status updates in real-time, displaying charge percentages, charging status, temperature, and health indicators.
- **Segmented Storage Graph**: Custom multi-segment UI progress indicator showing Used (violet) and Free (green) storage breakdowns in GBs.
- **Detailed Docs**: Refer to [Device Info Module Specifications](docs/features/device_info.md).
