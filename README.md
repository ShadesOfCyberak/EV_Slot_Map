# 🚗 EV Charging Station App

This project is a **Flutter-based mobile application** for managing and visualizing **EV charging stations**.  
It provides real-time updates on charging slot availability, user location mapping, and admin functionalities for station management.  

---

## 📌 Features

- 🗺️ **Interactive Map**: Displays available charging stations with markers.  
- 🟢 **Slot Availability Indicators**:  
  - Green = Available  
  - Blue = Partially Available  
  - Red = Full  
- 📍 **User Location Centering**: Automatically centers the map to the user’s current location.  
- ⚡ **Admin Controls**:  
  - Add new stations by dropping a marker on the map.  
  - Manage charging slot availability.  
- 🔄 **Real-Time Updates** for slot changes.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)  
- **Language**: Dart  
- **Map Library**: [maplibre_gl](https://pub.dev/packages/maplibre_gl)  
- **Location Services**: [geolocator](https://pub.dev/packages/geolocator)  

---

##   📂 Project Structure

- lib/
-  ├── main.dart # Entry point of the app
-  ├── screens/ # UI Screens (Station List, Map Screen, Admin Panel, etc.)
-  ├── widgets/ # Reusable UI components
-  ├── models/ # Data models for stations, slots, etc.
-  └── services/ # Location, API, and state management logic

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed  
- Android Studio / VS Code with Flutter extension  

### Installation
```bash
# Clone the repository
git clone https://github.com/ShadesOfCyberak/EV_Slot_Map.git

# Navigate into the project
cd ev-charging-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```
