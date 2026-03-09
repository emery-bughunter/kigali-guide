# Kigali Directory

A Flutter mobile app for discovering and managing essential public services and leisure locations across Kigali, Rwanda. Users can browse places by category, search, view on a map, add their own listings, and manage them from a personal dashboard.

---

## Features

- Browse places by category (Hospitals, Police, Libraries, Restaurants, Parks, etc.)
- Full-text search across name, description, address, and district
- Interactive map view with pinned locations
- Add / edit / delete your own listings (saved to Firebase Firestore)
- Firebase Authentication (email & password)
- My Listings dashboard with real-time sync
- Distance-aware sorting using device GPS

---

## Project Structure

```
lib/
├── main.dart                  # App entry point & route definitions
├── firebase_options.dart      # Firebase project configuration
├── models/
│   ├── place.dart             # Place data model + Firestore serialisation
│   └── app_user.dart          # Authenticated user model
├── providers/
│   ├── places_provider.dart   # Places state (stream, filter, sort, CRUD)
│   └── auth_provider.dart     # Auth state wrapper
├── services/
│   ├── place_service.dart     # Firestore CRUD & real-time streams
│   ├── auth_service.dart      # Firebase Auth operations
│   ├── location_service.dart  # GPS & distance helpers
│   └── seed_service.dart      # Optional data seeding utility
├── screens/
│   ├── splash_screen.dart
│   ├── main_shell.dart        # Bottom-nav host
│   ├── auth/                  # Login & Register screens
│   ├── home/                  # Home dashboard
│   ├── places/                # Place list, detail, add/edit screens
│   ├── my_listings/           # Current user's listings
│   ├── map/                   # Flutter Map view
│   ├── profile/               # User profile
│   └── settings/              # App settings
├── widgets/                   # Reusable UI components
└── utils/                     # Theme, constants
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.11 |
| Dart SDK | ≥ 3.11 |
| Android Studio / Xcode | latest stable |
| Firebase project | with Firestore & Auth enabled |

---

## Running Locally

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd kigali-guide/assignment
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The app requires a Firebase project with **Cloud Firestore** and **Email/Password Authentication** enabled.

- Place your `google-services.json` inside `android/app/`
- Update `lib/firebase_options.dart` with your project's credentials (or run `flutterfire configure`)

### 4. Run the app

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run

# Run on a specific device
flutter run -d <device-id>
```

### 5. Build a release APK (Android)

```bash
flutter build apk --release
```

---

## Firestore Rules

Ensure your Firestore security rules allow authenticated reads/writes. A minimal development rule is already in `firestore.rules` at the project root.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialisation |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Database & real-time streams |
| `provider` | State management |
| `geolocator` | Device GPS |
| `flutter_map` + `latlong2` | Interactive map |
| `cached_network_image` | Efficient image loading |
| `shared_preferences` | Local settings storage |
| `url_launcher` | Open phone/website links |

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
