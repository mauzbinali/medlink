import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_service.dart';
import 'messaging_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final messagingServiceProvider = Provider<MessagingService>(
  (ref) => MessagingService(),
);
