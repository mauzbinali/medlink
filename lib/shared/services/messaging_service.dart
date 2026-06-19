// ignore_for_file: prefer_initializing_formals

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  MessagingService({FirebaseMessaging? messaging, FirebaseFirestore? firestore})
    : _messaging = messaging,
      _firestore = firestore;

  final FirebaseMessaging? _messaging;
  final FirebaseFirestore? _firestore;

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseMessaging get _fcm => _messaging ?? FirebaseMessaging.instance;
  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<String?> initialize({String? userId}) async {
    if (!isAvailable) return null;

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    final token = await _fcm.getToken();
    if (token != null && userId != null) {
      await saveToken(userId: userId, token: token);
    }

    FirebaseMessaging.onMessage.listen((message) {
      // Foreground push handling is intentionally light here; local display
      // can be layered on by NotificationService when Firebase is configured.
    });

    return token;
  }

  Future<void> saveToken({
    required String userId,
    required String token,
  }) async {
    if (!isAvailable) return;
    await _db.collection('users').doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
