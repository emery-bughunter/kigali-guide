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
├── main.dart                  # app main dart
├── firebase_options.dart      # firebase config file
├── models/
│   ├── place.dart             # 
│   └── app_user.dart          # authentification 
├── providers/
│   ├── places_provider.dart   # places state (stream, filter, sort, CRUD)
│   └── auth_provider.dart     # auth state wrapper
├── services/
│   ├── place_service.dart     # Firestore CRUD & real-time streams
│   ├── auth_service.dart      #  auth operations
│   ├── location_service.dart  # with gps loction
│   └── seed_service.dart      # a seeding utlility
├── screens/
│   ├── splash_screen.dart
│   ├── main_shell.dart        # Bottom-nav 
│   ├── auth/                  # Login & Register screens
│   ├── home/                  # Home dashboard
│   ├── places/                # Place list, detail, add/edit screens
│   ├── my_listings/           # Current user's listings
│   ├── map/                   # Flutter Map view
│   ├── profile/               # profile
│   └── settings/              # App settings
├── widgets/                   
└── utils/                     
```

## requirements to run app

 Flutter SDK | ≥ 3.11 
 Dart SDK | ≥ 3.11 
 Android Studio 
 Firebase project  with Firestore & Auth enabled 

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
## Packages used
firebase_core
firebase_auth 
cloud_firestore 
provider 
geolocator 
flutter_map + latlong2 
cached_network_image 
shared_preferences 
url_launcher
## demo video
```https://youtu.be/j1KPZVmV4XQ```
