import 'package:alarm_app/services/notification_service.dart';
import 'package:alarm_app/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// storage Provider
final StorageProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Notification Services
final NotificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
