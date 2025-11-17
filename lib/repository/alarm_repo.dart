import 'package:alarm_app/providers/provider_objects.dart';
import 'package:alarm_app/utils/alarm_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository(
    ref.read(StorageProvider),
    ref.read(NotificationProvider),
  );
});

class AlarmRepository {
  final StorageService _storageService;
  final NotificationService _notificationService;

  AlarmRepository(this._storageService, this._notificationService);

  // Initialize services
  Future<void> initialize() async {
    try {
      await _storageService.init();
      await _notificationService.initialize();
    } catch (e) {
      throw AlarmRepositoryException('Failed to initialize services: $e');
    }
  }

  // Get all alarms
  List<Alarm> getAlarms() {
    try {
      return _storageService.getAlarms();
    } catch (e) {
      throw AlarmRepositoryException('Failed to get alarms: $e');
    }
  }

  // Add new alarm
  Future<void> addAlarm(Alarm alarm) async {
    try {
      await _storageService.addAlarm(alarm);

      if (alarm.isActive) {
        await _notificationService.scheduleAlarmNotification(
          id: alarm.id,
          title: 'Alarm',
          body: alarm.label,
          scheduledTime: alarm.time,
          repeat: alarm.repeat,
        );
      }
    } catch (e) {
      await _storageService.deleteAlarm(alarm.id);
      throw AlarmScheduleException('Failed to schedule alarm: $e');
    }
  }

  // Update existing alarm
  Future<void> updateAlarm(Alarm updatedAlarm) async {
    try {
      final alarms = _storageService.getAlarms();
      final existingAlarm = alarms.firstWhere(
        (alarm) => alarm.id == updatedAlarm.id,
        orElse: () => throw AlarmRepositoryException('Alarm not found'),
      );

      await _notificationService.cancelNotification(updatedAlarm.id);
      await _storageService.updateAlarm(updatedAlarm);

      if (updatedAlarm.isActive) {
        await _notificationService.scheduleAlarmNotification(
          id: updatedAlarm.id,
          title: 'Alarm',
          body: updatedAlarm.label,
          scheduledTime: updatedAlarm.time,
          repeat: updatedAlarm.repeat,
        );
      }
    } catch (e) {
      throw AlarmRepositoryException('Failed to update alarm: $e');
    }
  }

  // Delete alarm
  Future<void> deleteAlarm(String alarmId) async {
    try {
      await _notificationService.cancelNotification(alarmId);
      await _storageService.deleteAlarm(alarmId);
    } catch (e) {
      throw AlarmRepositoryException('Failed to delete alarm: $e');
    }
  }

  // Toggle alarm active/inactive
  Future<void> toggleAlarm(String alarmId, bool isActive) async {
    try {
      final alarms = _storageService.getAlarms();
      final alarmIndex = alarms.indexWhere((alarm) => alarm.id == alarmId);

      if (alarmIndex == -1) {
        throw AlarmRepositoryException('Alarm not found');
      }

      final alarm = alarms[alarmIndex];
      final updatedAlarm = alarm.copyWith(isActive: isActive);

      if (!isActive) {
        await _notificationService.cancelNotification(alarmId);
      } else {
        await _notificationService.scheduleAlarmNotification(
          id: alarm.id,
          title: 'Alarm',
          body: alarm.label,
          scheduledTime: alarm.time,
          repeat: alarm.repeat,
        );
      }

      await _storageService.updateAlarm(updatedAlarm);
    } catch (e) {
      throw AlarmRepositoryException('Failed to toggle alarm: $e');
    }
  }

  // ID generation
  String generateAlarmId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Ensure ID fits in 32-bit integer range
    return (timestamp % 2147483647).toString(); // 2^31 - 1
  }
}
