import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService() : _notifications = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings: settings);
  }

  Future<void> showLocal({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'appointments',
      'Appointments',
      channelDescription: 'Appointment reminders and status updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
