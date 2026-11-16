# MedLink

Flutter healthcare portfolio prototype with patient, doctor, and admin
experiences, appointment workflows, and prescription/receipt PDF generation.
It is not a production healthcare system. Use synthetic data only.

## Run and Check

Use a Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.
The committed `pubspec.lock` records the application dependency resolution;
do not upgrade dependencies merely to run the app.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Android and iOS are the primary targets. Web has a scaffold, but push setup and
file upload support are incomplete. iOS 15+ builds require macOS and Xcode.
Notification failures must not prevent the app from opening.

## Current Implementation

- Screens demonstrate discovery, booking, records, prescriptions, notifications,
  and payment records using seed data and local application state.
- Firebase initialization is optional for demo startup. Configuration alone does
  not turn local workflows into a complete backend.
- Persistence is write-only, without complete remote hydration/subscriptions.
  Restarting or changing devices does not restore the full remote workflow.
- Report names/attachments are not a working report picker and upload flow.
  A Storage helper exists but is not wired to those screens.
- Payment selection/status and receipts are demo records, not gateway charges,
  verified settlements, or real refunds. Online selections remain pending until
  a trusted payment integration confirms payment.
- Video consultation is intentionally a mock UI, not a working media session.
- Admin access must be provisioned by a trusted operator/backend, not public
  self-signup. Secure provisioning remains a release prerequisite.
- Push infrastructure is incomplete: login/token association, refresh/logout
  cleanup, background delivery, foreground display, and tap routing need wiring.

See [Firebase Setup](FIREBASE_SETUP.md), [Release Checklist](RELEASE_CHECKLIST.md),
and [Remaining Audit Items](AUDIT_REMAINING_ITEMS.md) before backend deployment.
