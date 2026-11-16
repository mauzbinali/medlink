import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/state/app_state.dart';

enum UserRole { patient, doctor, admin }

const _unchangedRole = Object();

final firebaseEnabledProvider = Provider<bool>(
  (ref) => Firebase.apps.isNotEmpty,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final authFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

extension UserRoleLabel on UserRole {
  String get label {
    return switch (this) {
      UserRole.patient => 'Patient',
      UserRole.doctor => 'Doctor',
      UserRole.admin => 'Admin',
    };
  }

  String get firestoreValue => name;
}

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.role,
    this.name = 'Mauz Patient',
    this.email = 'demo@medlink.app',
    this.isEmailVerified = true,
    this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final UserRole? role;
  final String name;
  final String email;
  final bool isEmailVerified;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Object? role = _unchangedRole,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: identical(role, _unchangedRole) ? this.role : role as UserRole?,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      error: error,
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  String? _sessionUid;
  bool get _firebaseEnabled => ref.read(firebaseEnabledProvider);
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  FirebaseFirestore get _db => ref.read(authFirestoreProvider);

  @override
  AuthState build() {
    if (_firebaseEnabled) {
      final subscription = _auth.authStateChanges().listen((user) {
        if (user == null || (_sessionUid != null && user.uid != _sessionUid)) {
          _sessionUid = null;
          ref.invalidate(appControllerProvider);
          state = const AuthState(isLoading: false, isAuthenticated: false);
        }
      });
      ref.onDispose(subscription.cancel);
    }
    return const AuthState(isLoading: false, isAuthenticated: false);
  }

  Future<void> restoreSession() async {
    ref.invalidate(appControllerProvider);
    state = const AuthState(isLoading: true, isAuthenticated: false);
    if (_firebaseEnabled) {
      try {
        // Wait for Firebase's persisted credential, never a preferences identity.
        final user = await _auth.authStateChanges().first;
        if (user == null) {
          state = const AuthState(isLoading: false, isAuthenticated: false);
          return;
        }
        await _loadFirebaseUser(user);
      } catch (_) {
        state = const AuthState(
          isLoading: false,
          isAuthenticated: false,
          error: 'Could not verify your session. Please sign in again.',
        );
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString('role');
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final isEmailVerified = prefs.getBool('emailVerified') ?? true;
    final role = _roleFromName(roleName);

    if (email == null) {
      state = const AuthState(isLoading: false, isAuthenticated: false);
      return;
    }

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      role: role,
      email: email,
      name: name ?? state.name,
      isEmailVerified: isEmailVerified,
      error: null,
    );
  }

  Future<void> _loadFirebaseUser(User user) async {
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed == null) throw StateError('Session expired');
    // Email verification in rules uses the ID token, not the cached User flag.
    await refreshed.getIdToken(true);
    final doc = await _db
        .collection('users')
        .doc(refreshed.uid)
        .get(const GetOptions(source: Source.server));
    final data = doc.data();
    if (data == null || data['isActive'] != true) {
      throw StateError('Account is missing or inactive');
    }
    if (_auth.currentUser?.uid != refreshed.uid) {
      throw StateError('Account changed while loading the profile');
    }
    if (_sessionUid != refreshed.uid) ref.invalidate(appControllerProvider);
    _sessionUid = refreshed.uid;
    state = AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: _roleFromName(data['role'] as String?),
      name: data['name'] as String? ?? refreshed.displayName ?? '',
      email: refreshed.email ?? '',
      isEmailVerified: refreshed.emailVerified,
    );
  }

  Future<void> login({required String email, required String password}) async {
    ref.invalidate(appControllerProvider);
    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        role: null,
        error: 'Enter your email and password.',
      );
      return;
    }

    state = const AuthState(isLoading: true, isAuthenticated: false);
    try {
      if (_firebaseEnabled) {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = credential.user;
        if (user == null) throw StateError('Missing Firebase user');
        await _loadFirebaseUser(user);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        email: email,
      );
      await _persistSession();
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        role: null,
        error: _friendlyFirebaseMessage(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        role: null,
        error: 'Login failed. Please try again.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    ref.invalidate(appControllerProvider);
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        role: null,
        error: 'Complete all fields and use a 6+ character password.',
      );
      return;
    }

    state = const AuthState(isLoading: true, isAuthenticated: false);
    try {
      String uid = 'demo-user';
      if (_firebaseEnabled) {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (credential.user == null) throw StateError('Missing Firebase user');
        uid = credential.user!.uid;
        _sessionUid = uid;
        await credential.user?.updateDisplayName(name);
        await credential.user?.sendEmailVerification();
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'role': null,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: null,
        name: name,
        email: email,
        isEmailVerified: !_firebaseEnabled,
      );
      await _persistSession();
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _friendlyFirebaseMessage(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Registration failed. Please try again.',
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'Enter your email address first.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      if (_firebaseEnabled) {
        await _auth.sendPasswordResetEmail(email: email);
      }
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> resendVerificationEmail() async {
    if (_firebaseEnabled) {
      await _auth.currentUser?.sendEmailVerification();
    }
  }

  Future<void> refreshEmailVerification() async {
    if (_firebaseEnabled) {
      try {
        final user = _auth.currentUser;
        if (user == null) throw StateError('Session expired');
        await _loadFirebaseUser(user);
      } catch (_) {
        state = const AuthState(isLoading: false, isAuthenticated: false);
      }
    } else {
      state = state.copyWith(isEmailVerified: true, error: null);
    }
  }

  Future<void> selectRole(UserRole role) async {
    if (!state.isAuthenticated ||
        state.isLoading ||
        !state.isEmailVerified ||
        (_firebaseEnabled && (role == UserRole.admin || state.role != null))) {
      state = state.copyWith(error: 'This role cannot be self-assigned.');
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      if (_firebaseEnabled) {
        final user = _auth.currentUser;
        if (user == null) throw StateError('Session expired');
        await _db.collection('users').doc(user.uid).update({
          'role': role.firestoreValue,
        });
        await _loadFirebaseUser(user);
      } else {
        state = state.copyWith(role: role, isLoading: false);
        await _persistSession();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not select role.');
    }
  }

  String landingRoute() {
    if (!state.isAuthenticated) return AppRoutes.onboarding;
    if (!state.isEmailVerified) return AppRoutes.emailVerification;
    return switch (state.role) {
      UserRole.patient => AppRoutes.patientHome,
      UserRole.doctor => AppRoutes.doctorDashboard,
      UserRole.admin => AppRoutes.adminDashboard,
      null => AppRoutes.roleSelection,
    };
  }

  Future<void> _persistSession() async {
    if (_firebaseEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', state.email);
    await prefs.setString('name', state.name);
    if (state.role != null) {
      await prefs.setString('role', state.role!.firestoreValue);
    } else {
      await prefs.remove('role');
    }
    await prefs.setBool('emailVerified', state.isEmailVerified);
  }

  UserRole? _roleFromName(String? value) {
    return switch (value) {
      'patient' => UserRole.patient,
      'doctor' => UserRole.doctor,
      'admin' => UserRole.admin,
      _ => null,
    };
  }

  String _friendlyFirebaseMessage(FirebaseException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'This email is already registered.',
      'weak-password' => 'Use a stronger password.',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => error.message ?? 'Firebase request failed.',
    };
  }

  Future<void> logout() async {
    _sessionUid = null;
    ref.invalidate(appControllerProvider);
    state = const AuthState(isLoading: false, isAuthenticated: false);
    if (_firebaseEnabled) await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('role');
    await prefs.remove('emailVerified');
    state = const AuthState(isLoading: false, isAuthenticated: false);
  }
}
