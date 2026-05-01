# 📱 Daily Routine Planner

## 📌 Overview

Daily Routine Planner is a Flutter-based mobile app that helps users organize and manage their daily tasks efficiently. It allows users to plan their morning, afternoon, and evening activities and track their progress — with real-time sync and authentication powered by Firebase.

---

## ✨ Features

* 🕒 Organize tasks by time (Morning / Afternoon / Evening)
* ✅ Mark tasks as completed
* 📊 Track daily progress
* 📝 Add notes and reminders
* 🔐 User Authentication (Login / Signup via Firebase Auth)
* ☁️ Real-time data sync with Firebase Firestore
* 💾 Tasks saved to cloud — accessible from any device
* 🎨 Simple and clean user interface

---

## 🛠️ Tech Stack

* Flutter (Dart)
* Material UI
* Firebase Authentication
* Firebase Firestore (Cloud Database)
* Firebase Core

---

## 📦 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project
2. Add an Android/iOS app and download the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
3. Place the file in the correct directory:
    - Android: `android/app/google-services.json`
    - iOS: `ios/Runner/GoogleService-Info.plist`
4. Make sure the following dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: latest_version
  firebase_auth: latest_version
  cloud_firestore: latest_version
```

---

## 📂 Project Structure
lib/
├── main.dart
├── screens/
├── widgets/
├── services/
│    ├── auth_service.dart
│    └── firestore_service.dart


---

## 🚀 How to Run

```bash
flutter pub get
flutter run
```

> Make sure you have added your `google-services.json` before running.

---

