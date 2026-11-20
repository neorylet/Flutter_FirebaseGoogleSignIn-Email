# task_9

A new Flutter project with Firebase authentication.

## Firebase Setup

This app requires Firebase configuration files to work properly. Without these, the app will show a black screen on startup.

### Required Steps:

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com)

2. **Add Android app:**
   - Package name: `com.example.task_9`
   - Download `google-services.json`
   - Place it in `android/app/`

3. **Add iOS app (if building for iOS):**
   - Bundle ID: `com.example.task9`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

4. **Enable Authentication** in Firebase Console:
   - Go to Authentication > Sign-in method
   - Enable Email/Password
   - Enable Google Sign-in (optional)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
