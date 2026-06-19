import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } on FirebaseException catch (error) {
      debugPrint('Firebase skipped: ${error.message}');
    } catch (error) {
      debugPrint('Firebase skipped: $error');
    }
  }
}
