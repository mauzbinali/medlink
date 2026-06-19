import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';

enum UserRole { patient, doctor, admin }

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
    UserRole? role,
    String? name,
    String? email,
    bool? isEmailVerified,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
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
  @override
  AuthState build() {
    return const AuthState(isLoading: false, isAuthenticated: false);
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final roleName = prefs.getString('role');
    final email = prefs.getString('email');
    final name = prefs.getString('name');
    final isEmailVerified = prefs.getBool('emailVerified') ?? true;
    final role = _roleFromName(roleName);

    if (email == null) return;

    state = state.copyWith(
      isAuthenticated: true,
      role: role,
      email: email,
      name: name ?? state.name,
      isEmailVerified: isEmailVerified,
      error: null,
    );
  }

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Enter your email and password.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      if (Firebase.apps.isNotEmpty) {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final user = credential.user;
        if (user != null) {
          await user.reload();
          final refreshed = FirebaseAuth.instance.currentUser;
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(refreshed?.uid)
              .get();
          final data = doc.data();
          state = state.copyWith(
            name:
                data?['name'] as String? ??
                refreshed?.displayName ??
                state.name,
            role: _roleFromName(data?['role'] as String?),
            isEmailVerified: refreshed?.emailVerified ?? false,
          );
        }
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
        error: _friendlyFirebaseMessage(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
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
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Complete all fields and use a 6+ character password.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      String uid = 'demo-user';
      if (Firebase.apps.isNotEmpty) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        uid = credential.user?.uid ?? uid;
        await credential.user?.updateDisplayName(name);
        await credential.user?.sendEmailVerification();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
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
        name: name,
        email: email,
        isEmailVerified: Firebase.apps.isNotEmpty ? false : true,
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
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> resendVerificationEmail() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    }
  }

  Future<void> refreshEmailVerification() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      state = state.copyWith(isEmailVerified: verified, error: null);
      await _persistSession();
    } else {
      state = state.copyWith(isEmailVerified: true, error: null);
    }
  }

  Future<void> selectRole(UserRole role) async {
    state = state.copyWith(role: role, isAuthenticated: true, error: null);
    if (Firebase.apps.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'role': role.firestoreValue,
        }, SetOptions(merge: true));
      }
    }
    await _persistSession();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', state.email);
    await prefs.setString('name', state.name);
    if (state.role != null) {
      await prefs.setString('role', state.role!.firestoreValue);
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
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('role');
    await prefs.remove('emailVerified');
    state = const AuthState(isLoading: false, isAuthenticated: false);
  }
}
