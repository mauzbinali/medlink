# MedLink Audit Report

MedLink is a portfolio prototype, not a production clinical system. The changes
below improve correctness and access control, but do not establish a deployed,
fully synchronized backend. Use synthetic data until the release blockers and
device verification are complete.

The review covered application Dart source (screens, widgets, state, routing,
authentication, models and services), Android/iOS configuration, Firebase rules,
package configuration, tests and project documentation. Generated build outputs
and third-party package source were not treated as application source.

## Implemented Corrections

### Authentication and Access Control

- Firebase sessions use authenticated/server identity instead of trusting cached
  preference roles. Missing roles and inactive accounts fail closed.
- Role changes are accepted locally only after successful server writes. Public
  role selection cannot grant admin access; provisioned admins remain supported.
- Login/logout clear stale role information, and logout resets per-account state.
- Route guards check authentication, email verification, and portal role access.
- Firestore rule sources restrict clinical/payment access to participants or
  authorized administrators, constrain role changes, preserve record ownership,
  and restrict payment-state changes. Doctor catalog bindings/approval require
  administration; health-tip Storage writes are no longer open to every user.
- These are source-code changes, not proof of deployed security or a completed
  provisioning process. Rule validation and deployment remain release gates.

### Appointments, Reviews, and Payment Records

- Booking rejects duplicate appointments, overlapping local slots, past dates,
  elapsed times, and invalid time-slot strings.
- Status changes respect allowed transitions. Rescheduling returns a booking to
  pending confirmation and checks conflicts rather than preserving confirmation.
- Reviews require completed appointments, a valid finite rating, and no existing
  local review for the appointment.
- Choosing an online payment method leaves payment pending; selection does not
  fabricate a successful charge.
- Cancelling an unpaid booking does not create a refund: the pending payment
  record becomes failed and the appointment's payment label becomes cancelled.
  Paid demo bookings can record a simulated refund with consistent receipt state;
  no actual money is moved.
- `Appointment.copyWith` can update payment status without losing other fields.
- Appointment persistence is awaited before its payment record is saved, avoiding
  a dependent payment write after appointment-write failure. Sync failures produce
  visible error notifications rather than silently claiming remote success.

### Services, Documents, and Platform Configuration

- Optional notification failures no longer abort startup. Local notifications
  skip unsupported targets and request Android runtime permission.
- Messaging checks permission and APNs readiness and no longer creates an unused
  foreground subscription. Firebase bootstrap avoids duplicate initialization.
- Storage upload paths reject invalid segments and use unique object names to
  avoid overwriting files with the same original filename.
- PDFs reject mismatched doctor IDs. Prescription tables span pages, repeat
  headers, and include each medicine's instructions. Receipts identify demo status
  and are not proof of payment.
- Android camera hardware is optional, and broad image-library permission has
  been removed for the system picker workflow.
- iOS deployment settings now target iOS 15, matching the resolved Firebase SDK.
  Dependency upgrades were not required.

## UI Corrections

Current changes make specialty/online query parameters functional, select online
booking mode from the requested link, suppress call controls for clinic visits,
keep reschedule dates in calendar bounds, and make the reschedule sheet scrollable.
Admin patient search is functional. Doctor profile fields no longer display a
fake save-success action for edits that are not persisted.
Availability supports day/start/end selection rather than adding only Monday
slots. Dashboard counts and approval labels reflect the local data, and Today
and weekly metrics use their named date ranges. Hanging up a mock call no longer
automatically creates a prescription.

Phone dashboard overflows were corrected in both themes. Booking and rescheduling
display date and slot-conflict errors. The light/dark dashboard, query, search,
rescheduling, and error-feedback widget tests pass. Native-device interaction
and accessibility testing remain necessary.

## Remaining Release Blockers

1. **Remote state:** persistence remains write-only without complete remote
   hydration/listeners. Seed data and local state are not durable multi-user
   synchronization. Test restart, account switching, and cross-device behavior.
   Doctor identity must scope dashboard data; availability remains screen-local,
   doctor profile is read-only, and favorites/chat/health-tip operations still
   need durable storage wiring. Charts include illustrative data.
2. **Reports:** there is no actual report picker/upload flow connected to the UI,
   attachment metadata, authorized retrieval, or cleanup lifecycle.
3. **Payments:** there is no gateway, verified settlement, webhook, or real refund.
   Client payment records and PDFs must never authorize money movement.
4. **Video:** consultation video is intentionally mock UI; no real media/signaling
   service is supplied.
5. **Security rollout:** validate hardened rules with emulator tests, configure
   deployment, migrate required ownership fields, and provision admins through a
   privileged operator/backend. Public self-signup is not admin provisioning.
6. **Server invariants:** local booking/review checks and ordered client writes
   do not prove cross-device uniqueness, atomicity, rollback, or idempotent retry.
   Transactional enforcement and end-to-end tests remain necessary.
7. **Notifications:** complete authenticated token association, rotation/logout
   cleanup, APNs-readiness retry, trusted sending, foreground/background display,
   and tap routing. Project configuration alone does not enable these workflows.
8. **Build and device proof:** release signing, Firebase native setup, APNs
   entitlements, physical-device permissions/delivery, Android release artifacts,
   and iOS archives have not been fully verified. Android still uses debug signing
   for release builds. iOS builds require macOS/Xcode.
9. **Data handling:** finish privacy, consent, retention, deletion, and operational
   review before using real clinical data.

## Additional Limitations

- Backend schemas, serialization, and migrations need complete integration tests.
  Some model lists remain caller-mutable despite their final fields.
- Google Fonts has no bundled font assets; offline typography needs provisioning
  and device tests. Built-in PDF fonts do not support all scripts; embed suitable
  licensed fonts for non-Latin text. Very large table cells need input limits.
- Web is a scaffold, not full mobile feature parity. The Storage helper uses
  `dart:io` File and web messaging lacks options, worker, and VAPID setup.
- Many dependency constraints are open. Preserve the application lockfile for
  reproducibility; running an upgrade is not part of these corrections.

## Verification Status

The complete Flutter test suite passes all 48 tests, covering authentication,
route guards, appointment/payment state, persistence sequencing/failures,
models/services, PDF generation, and presentation smoke tests.

The Android debug APK built successfully using `flutter build apk --debug --no-pub`.
The existing Firebase Storage Kotlin Gradle compatibility warning remains; it
did not prevent this build. Release signing and an iOS archive were not tested.
`flutter analyze --no-pub` reports no issues.

These checks do not prove deployed
rule safety, remote data isolation, native permission behavior, real payments,
or working telemedicine. No complete release-build/device proof is available yet.
See `FIREBASE_SETUP.md` and `RELEASE_CHECKLIST.md` for the remaining setup and gates.
