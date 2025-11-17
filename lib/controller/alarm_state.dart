import 'package:alarm_app/models/alarm_model.dart';
import 'package:alarm_app/repository/alarm_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final alarmProvider = StateNotifierProvider<AlarmNotifier, AlarmState>((ref) {
  return AlarmNotifier(ref.read(alarmRepositoryProvider));
});

class AlarmNotifier extends StateNotifier<AlarmState> {
  final AlarmRepository _alarmRepository;
  AlarmNotifier(this._alarmRepository) : super(AlarmLoadingState());

  // load all alarm

  void _loadAlarms() {
    try {
      final alarms = _alarmRepository.getAlarms();

      if (alarms.isEmpty) {
        state = const AlarmEmptyState();
      } else {
        state = AlarmLoadedState(alarms);
      }
    } catch (e) {
      state = AlarmErrorState('Failed to load alarms: $e');
    }
  }

  // initialize app

  Future<void> initialize() async {
    state = const AlarmLoadingState();
    try {
      await _alarmRepository.initialize();
      _loadAlarms();
    } catch (e) {
      state = AlarmErrorState(e.toString());
    }
  }

  // ADD alarm

  Future<void> addAlarm(DateTime time, String label, RepeatType repeat) async {
    state = const AlarmLoadingState();
    try {
      final now = DateTime.now();
      DateTime alarmTime = time;

      if (alarmTime.isBefore(now)) {
        alarmTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          time.hour,
          time.minute,
        );
        print(' Past time detected, adjusted to: $alarmTime');
      }
      final alarm = Alarm(
        id: _alarmRepository.generateAlarmId(),
        time: time,
        label: label.isEmpty ? "alarm" : label,
        repeat: repeat,
        createdAt: DateTime.now(),
      );
      await _alarmRepository.addAlarm(alarm);
      _loadAlarms();
    } catch (e) {
      state = AlarmErrorState('Failed to add alarm: $e');
    }
  }

  // update Alarm
  Future<void> updateAlarm(Alarm updateAlarm) async {
    state = const AlarmUpdatingState();
    try {
      await _alarmRepository.updateAlarm(updateAlarm);

      _loadAlarms();
    } catch (e) {
      state = AlarmErrorState(e.toString());
    }
  }

  // delete Alarm
  Future<void> deleteAlarm(String id) async {
    state = const AlarmDeletingState();
    try {
      await _alarmRepository.deleteAlarm(id);
      _loadAlarms();
    } catch (e) {
      state = AlarmErrorState(e.toString());
    }
  }

  // toogle alarm ======

  Future<void> toogleAlarm(String alarmId, bool isActive) async {
    try {
      await _alarmRepository.toggleAlarm(alarmId, isActive);
      _loadAlarms();
    } catch (e) {
      state = AlarmErrorState('Failed to toggle alarm: $e');
      rethrow;
    }
  }
}

sealed class AlarmState {
  const AlarmState();
}

// Loading State
class AlarmLoadingState extends AlarmState {
  const AlarmLoadingState();
}

// Loaded State with data
class AlarmLoadedState extends AlarmState {
  final List<Alarm> alarms;
  const AlarmLoadedState(this.alarms);
}

// Empty State (no alarms)
class AlarmEmptyState extends AlarmState {
  const AlarmEmptyState();
}

// Error State
class AlarmErrorState extends AlarmState {
  final String message;
  const AlarmErrorState(this.message);
}

// Adding State (when adding new alarm)
class AlarmAddingState extends AlarmState {
  const AlarmAddingState();
}

// Updating State (when updating alarm)
class AlarmUpdatingState extends AlarmState {
  const AlarmUpdatingState();
}

// Deleting State (when deleting alarm)
class AlarmDeletingState extends AlarmState {
  const AlarmDeletingState();
}
