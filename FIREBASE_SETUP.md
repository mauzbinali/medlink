# MedLink Firebase Setup

Firebase is optional for local demo startup. Adding configuration does not replace
seed data/local state with a complete backend. Use synthetic data only.

## Required files

- Android: place `google-services.json` in `android/app/` and configure/apply the
  Google Services Gradle plugin. Current Gradle files do not apply that plugin;
  copying JSON alone is insufficient.
- iOS: add `GoogleService-Info.plist` to the Runner target and bundled resources
  in Xcode; copying into the directory alone is insufficient.
- Register the actual Android application ID and iOS bundle identifier first.

## Firebase services to enable

- Authentication: Email/password provider
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

## Intended Firestore Collections

This list describes intended data domains, not complete persisted workflows or
guaranteed rules/schema coverage:

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

## Rules and Deployment

`firebase/firestore.rules` and `firebase/storage.rules` are source files, not
evidence of deployed or tested security. Firebase CLI project/deployment
configuration is not supplied. Configure project selection and explicit rules
paths before deployment. Hardened rule sources and ownership restrictions still
require emulator tests before they can be trusted with real data.
Admins must be provisioned through a trusted operator/backend, never public signup.

## Remaining Integration

- Persistence is write-only with no complete remote hydration/listeners. Seed
  data/local state remain; configuration alone does not restore remote records.
- Models are domain/display objects, not a complete backend serialization,
  ownership, and migration contract.
- The Storage helper is not connected to a real report picker, attachment
  metadata, authorized retrieval, or deletion lifecycle.
- There is no payment gateway, verified settlement, webhook, or real refund.
  Client payment records and receipts are demo artifacts, not proof of payment.
- Video calls are intentionally mocked; no media/signaling backend is supplied.
- Startup requests an FCM token without a user ID. Login association, token
  rotation, logout removal, APNs-readiness retry, foreground/background handling,
  tap routing, and trusted sending remain to be implemented.
- iOS push requires signing, Push Notifications entitlement, APNs credentials,
  and Background Modes/Remote notifications. `Info.plist` alone is insufficient.
- Web push needs explicit options, a service worker, and VAPID configuration;
  the current messaging helper intentionally skips web.
- Server-validated booking uniqueness and status transitions need transactions
  and end-to-end tests. See `AUDIT_REMAINING_ITEMS.md`.
