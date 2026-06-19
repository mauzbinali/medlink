# MedLink Firebase Setup

MedLink runs in demo mode until Firebase project files are added.

## Required files

- Android: place `google-services.json` in `android/app/`
- iOS: place `GoogleService-Info.plist` in `ios/Runner/`

## Firebase services to enable

- Authentication: Email/password provider
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

## Firestore collections

- `users`
- `doctors`
- `appointments`
- `prescriptions`
- `medical_records`
- `reviews`
- `payments`
- `notifications`
- `health_tips`
- `favorites`

## FlutterFire configuration

After installing the FlutterFire CLI, run:

```bash
flutterfire configure --project your-firebase-project-id
```

This will generate `lib/firebase_options.dart`. If you use that file, update
`FirebaseBootstrap.initialize()` to call:

```dart
Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

## Current behavior

The app safely falls back to demo state when Firebase is missing. Once configured,
auth, Firestore writes, Storage uploads, and FCM token registration are ready to
be connected fully through the existing service layer.
