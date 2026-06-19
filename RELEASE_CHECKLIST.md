# MedLink Release Checklist

## Firebase

- Add `android/app/google-services.json`
- Add `ios/Runner/GoogleService-Info.plist`
- Run `flutterfire configure`
- Update `FirebaseBootstrap.initialize()` to use generated Firebase options
- Deploy `firebase/firestore.rules`
- Deploy `firebase/storage.rules`

## Android

- Configure release signing in `android/key.properties`
- Replace launcher icons
- Build with `flutter build appbundle --release`
- Test push notification permission on Android 13+

## iOS

- Open `ios/Runner.xcworkspace` on macOS
- Set signing team and bundle identifier
- Add push notification capability
- Add background remote notifications capability
- Build with `flutter build ios --release`

## QA Flow

- Register patient, doctor, and admin accounts
- Book, reschedule, cancel, and complete appointments
- Verify payment records and receipts
- Generate and share prescription PDFs
- Upload and attach medical records
- Confirm doctor approval/suspension behavior
- Confirm FCM token registration after login
