# MedLink Release Checklist

These are prerequisites, not claims of completed functionality. The prototype
is not ready for production clinical data or payment processing.

## Backend Release Blockers

- Review hardened rule sources; prove role immutability and participant
  isolation with Firebase emulator tests before deployment.
- Provision admins through a trusted operator/backend, never public self-signup.
- Define owner/participant IDs, schema validation, and migration contracts.
- Implement remote hydration/listeners; replace seed data in production flows.
- Test restart, sign-out, account switching, offline, and cross-device behavior.
- Enforce booking conflicts and status transitions transactionally on the server.
- Wire a real report picker, upload, metadata, authorized retrieval, and cleanup.
- Integrate a gateway and verified webhooks before real payments/refunds.
  Client payment status or a PDF receipt is not proof of payment.
- Keep video explicitly identified as mock until real media/signaling exists.
- Complete privacy, consent, retention, deletion, and operational review.

## Firebase

- Add `android/app/google-services.json`
- Add `ios/Runner/GoogleService-Info.plist`
- Run `flutterfire configure`
- Update `FirebaseBootstrap.initialize()` to use generated Firebase options
- Configure Firebase CLI project selection and explicit rules deployment paths
- Deploy `firebase/firestore.rules`
- Deploy `firebase/storage.rules`

## Android

- Wire Gradle to read private release signing credentials; merely adding
  `android/key.properties` is insufficient. Do not ship debug-signed releases.
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

- Register patients/doctors; provision admin accounts through a privileged process
- Book, reschedule, cancel, and complete appointments
- Verify payment records and receipts
- Generate and share prescription PDFs
- Upload and attach medical records
- Confirm doctor approval/suspension behavior
- Confirm FCM token registration after login
- Implement/test token refresh, logout removal, and delayed APNs-readiness retry
- Implement/test trusted notification sending, foreground/background handling,
  notification taps, and permission denial/revocation
- Verify fonts offline and embed suitable PDF fonts for non-Latin text
- Verify long prescriptions retain every medicine and its instructions across pages
- Run `flutter analyze`, `flutter test`, and separate backend emulator/device tests

See `AUDIT_REMAINING_ITEMS.md` for scope and remaining risks. Flutter unit tests
alone do not validate deployed security, real payments, or native delivery.
