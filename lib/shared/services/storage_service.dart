import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  // ignore: prefer_initializing_formals
  StorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseStorage get _bucket => _storage ?? FirebaseStorage.instance;

  Future<String?> uploadMedicalFile({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    _validatePathSegment(userId, 'userId');
    _validatePathSegment(fileName, 'fileName');
    if (!isAvailable) return null;
    final id = const Uuid().v4();
    final ref = _bucket.ref('medical_records/$userId/${id}_$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  static void _validatePathSegment(String value, String name) {
    if (value.trim().isEmpty ||
        value == '.' ||
        value == '..' ||
        value.contains('/') ||
        value.contains('\\')) {
      throw ArgumentError.value(value, name, 'Must be a nonempty path segment');
    }
  }
}
