import 'package:alarm_app/controller/alarm_state.dart';
import 'package:alarm_app/models/alarm_model.dart';
import 'package:alarm_app/view/editscreen/add_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditAlarmScreen extends StatelessWidget {
  final Alarm? alarm;

  const AddEditAlarmScreen({super.key, this.alarm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alarm != null ? 'Edit Alarm' : 'Add Alarm'),
        actions: [
          if (alarm != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: AddEditAlarmForm(
        alarm: alarm,
        onSave:
            (time, label, repeat) => _saveAlarm(context, time, label, repeat),
        onDelete: () => _deleteAlarm(context),
      ),
    );
  }

  void _saveAlarm(
    BuildContext context,
    DateTime time,
    String label,
    RepeatType repeat,
  ) {
    final ref = ProviderScope.containerOf(context).read(alarmProvider.notifier);

    if (alarm != null) {
      final updatedAlarm = alarm!.copyWith(
        time: time,
        label: label,
        repeat: repeat,
      );
      ref.updateAlarm(updatedAlarm);
    } else {
      ref.addAlarm(time, label, repeat);
    }

    Navigator.pop(context);
  }

  void _deleteAlarm(BuildContext context) {
    final ref = ProviderScope.containerOf(context).read(alarmProvider.notifier);
    ref.deleteAlarm(alarm!.id);
    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this alarm?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAlarm(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
