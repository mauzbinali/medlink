// Firestore SDK types are faked only to verify this controller's boundary.
// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medlink/core/routes/app_router.dart';
import 'package:medlink/core/routes/app_routes.dart';
import 'package:medlink/features/auth/application/auth_controller.dart';
import 'package:medlink/shared/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'firebase-user';
  @override
  String get email => 'server@example.com';
  @override
  String get displayName => 'Server User';
  @override
  bool get emailVerified => true;
  @override
  Future<void> reload() async {}
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'test-token';
}

class _Auth extends Fake implements FirebaseAuth {
  _Auth(this.user);
  final User? user;
  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => Stream.value(user);
}

class _Snapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  _Snapshot(this.value);
  final Map<String, dynamic>? value;
  @override
  Map<String, dynamic>? data() => value;
}

class _Document extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _Document(this.value);
  final Map<String, dynamic>? value;
  bool failUpdate = false;
  int writes = 0;
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    expect(options?.source, Source.server);
    return _Snapshot(value);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    writes++;
    if (failUpdate) {
      throw FirebaseException(plugin: 'firestore', code: 'permission-denied');
    }
    value!.addAll(Map<String, dynamic>.from(data));
  }
}

class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.document);
  final _Document document;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    expect(path, 'firebase-user');
    return document;
  }
}

class _Firestore extends Fake implements FirebaseFirestore {
  _Firestore(this.document);
  final _Document document;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'users');
    return _Collection(document);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late _Document document;

  AuthController setup({
    bool firebase = false,
    User? user,
    String? role,
    bool active = true,
  }) {
    document = _Document({
      'name': 'Trusted Name',
      'role': role,
      'isActive': active,
    });
    container = ProviderContainer(
      overrides: [
        firebaseEnabledProvider.overrideWithValue(firebase),
        firebaseAuthProvider.overrideWithValue(_Auth(user)),
        authFirestoreProvider.overrideWithValue(_Firestore(document)),
      ],
    );
    addTearDown(container.dispose);
    return container.read(authControllerProvider.notifier);
  }

  setUp(
    () => SharedPreferences.setMockInitialValues({
      'email': 'prefs@example.com',
      'name': 'Cached Admin',
      'role': 'admin',
      'emailVerified': true,
    }),
  );

  test('copyWith preserves omitted role and clears explicit null', () {
    const state = AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: UserRole.admin,
    );
    expect(state.copyWith().role, UserRole.admin);
    expect(state.copyWith(role: null).role, isNull);
  });

  test('demo restores admin and retains portfolio role switching', () async {
    final controller = setup();
    await controller.restoreSession();
    expect(controller.landingRoute(), AppRoutes.adminDashboard);
    await controller.selectRole(UserRole.patient);
    await controller.selectRole(UserRole.admin);
    expect(container.read(authControllerProvider).role, UserRole.admin);
  });

  test('Firebase without credential never trusts cached admin', () async {
    final controller = setup(firebase: true);
    await controller.restoreSession();
    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    expect(container.read(authControllerProvider).role, isNull);
    await controller.selectRole(UserRole.admin);
    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    expect(document.writes, 0);
  });

  test(
    'Firebase restores server identity and clears stale cached role',
    () async {
      final controller = setup(firebase: true, user: _User());
      await controller.restoreSession();
      final state = container.read(authControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.email, 'server@example.com');
      expect(state.role, isNull);
      expect(controller.landingRoute(), AppRoutes.roleSelection);
    },
  );

  test('Firebase admin comes from server, never self-selection', () async {
    final controller = setup(firebase: true, user: _User());
    await controller.restoreSession();
    await controller.selectRole(UserRole.admin);
    expect(container.read(authControllerProvider).role, isNull);
    expect(document.writes, 0);
  });

  test('provisioned admin can access admin landing', () async {
    final controller = setup(firebase: true, user: _User(), role: 'admin');
    await controller.restoreSession();
    expect(controller.landingRoute(), AppRoutes.adminDashboard);
  });

  test('role only changes after successful server write', () async {
    final controller = setup(firebase: true, user: _User());
    await controller.restoreSession();
    document.failUpdate = true;
    await controller.selectRole(UserRole.doctor);
    expect(container.read(authControllerProvider).role, isNull);
    expect(container.read(authControllerProvider).error, isNotNull);
    document.failUpdate = false;
    await controller.selectRole(UserRole.patient);
    expect(container.read(authControllerProvider).role, UserRole.patient);
    await controller.selectRole(UserRole.doctor);
    expect(container.read(authControllerProvider).role, UserRole.patient);
  });

  test('inactive account fails closed', () async {
    final controller = setup(firebase: true, user: _User(), active: false);
    await controller.restoreSession();
    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
  });

  test('demo login clears prior role and persisted role', () async {
    final controller = setup();
    await controller.restoreSession();
    await controller.login(email: 'new@example.com', password: 'password');
    expect(container.read(authControllerProvider).role, isNull);
    expect((await SharedPreferences.getInstance()).getString('role'), isNull);
  });

  test('logout clears auth, preferences, and per-account app state', () async {
    final controller = setup();
    await controller.restoreSession();
    final oldState = container.read(appControllerProvider);
    await controller.logout();
    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    expect(identical(container.read(appControllerProvider), oldState), isFalse);
    expect((await SharedPreferences.getInstance()).getString('email'), isNull);
  });

  test(
    'route guards handle auth, verification, role and portal boundaries',
    () {
      const anonymous = AuthState(isLoading: false, isAuthenticated: false);
      const patient = AuthState(
        isLoading: false,
        isAuthenticated: true,
        role: UserRole.patient,
      );
      expect(authRedirect(anonymous, '/admin/users'), AppRoutes.login);
      expect(authRedirect(anonymous, AppRoutes.register), isNull);
      expect(
        authRedirect(patient.copyWith(isEmailVerified: false), '/patient'),
        AppRoutes.emailVerification,
      );
      expect(
        authRedirect(patient.copyWith(role: null), '/doctor'),
        AppRoutes.roleSelection,
      );
      expect(authRedirect(patient, '/admin/users'), AppRoutes.patientHome);
      expect(
        authRedirect(patient, '/doctor/patients/123'),
        AppRoutes.patientHome,
      );
      expect(authRedirect(patient, '/patient/appointments/123'), isNull);
      expect(authRedirect(patient, '/appointments/123/chat'), isNull);
      expect(
        authRedirect(patient.copyWith(role: UserRole.doctor), '/patient'),
        AppRoutes.doctorDashboard,
      );
      expect(
        authRedirect(patient.copyWith(role: UserRole.admin), '/admin/users'),
        isNull,
      );
    },
  );
}
