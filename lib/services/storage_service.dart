import 'package:alarm_app/models/alarm_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _alarmBox = 'alarms_box';
  late Box<Alarm> _alarms;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    _alarms = await Hive.openBox<Alarm>(_alarmBox);
  }

  // Get Alarm
  List<Alarm> getAlarms() {
    final alarmsList = _alarms.values.toList();
    alarmsList.sort((a, b) => a.time.compareTo(b.time));
    return alarmsList;
  }

  // Add Alarm

  Future<void> addAlarm(Alarm alarm) async {
    await _alarms.put(alarm.id, alarm);
  }

  // update alarm
  Future<void> updateAlarm(Alarm alarm) async {
    await _alarms.put(alarm.id, alarm);
  }

  // delelte alarm
  Future<void> deleteAlarm(String id) async {
    await _alarms.delete(id);
  }

  // clear all
  Future<void> clearAll() async {
    await _alarms.clear();
  }
}
