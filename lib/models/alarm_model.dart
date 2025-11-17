import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 0)
enum RepeatType {
  @HiveField(0)
  once,

  @HiveField(1)
  daily,

  @HiveField(2)
  weekly,
}

@HiveType(typeId: 1)
class Alarm {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime time;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final RepeatType repeat;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  final DateTime createdAt;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.repeat,
    this.isActive = true,
    required this.createdAt,
  });

  Alarm copyWith({
    String? id,
    DateTime? time,
    String? label,
    RepeatType? repeat,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      repeat: repeat ?? this.repeat,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
