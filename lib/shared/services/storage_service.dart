import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    if (!isAvailable) return null;
    final ref = _bucket.ref('medical_records/$userId/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
