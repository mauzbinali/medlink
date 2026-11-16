// ignore_for_file: prefer_initializing_formals

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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
    if (!isAvailable || kIsWeb) return null;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return null;
    }
    // APNs registration can still be pending just after permission is granted.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await _fcm.getAPNSToken() == null) {
      return null;
    }

    final token = await _fcm.getToken();
    if (token != null && userId != null) {
      await saveToken(userId: userId, token: token);
    }

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
