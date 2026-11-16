# MedLink

https://github.com/user-attachments/assets/dc3cd6cd-0cbf-4a08-b1cc-d485103ca55c

Flutter healthcare portfolio prototype with patient, doctor, and admin
experiences, appointment workflows, and prescription/receipt PDF generation.
It is not a production healthcare system. Use synthetic data only.

## Features

- Patient, Doctor, and Admin portals
- Authentication with role-based routing and Firebase-ready services
- Doctor search, specialty filters, and doctor profiles
- Appointment booking, rescheduling, and cancellation
- Doctor availability UI and appointment management
- Prescription creation, PDF generation, download, and sharing
- Medical record and report attachment demo screens
- Video consultation mock UI with chat
- Favorites, ratings, and reviews
- Notifications and health tips
- Responsive design with dark mode, animations, skeleton loading, and empty states

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- GoRouter for navigation
- Firebase Auth, Firestore, Storage, and Messaging
- Hive and Shared Preferences for local storage
- Flutter Animate, Lottie, Shimmer, and Google Fonts
- Table Calendar and FL Chart

## Screens

- Splash and onboarding
- Login, registration, forgot password, and role selection
- Patient home, specialties, doctor listing, doctor details, and booking
- My appointments, payments, prescriptions, and medical records
- Doctor dashboard, availability, patient details, and prescription editor
- Admin dashboard, user management, appointments, revenue, and health tips

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
