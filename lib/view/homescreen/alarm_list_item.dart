import 'package:alarm_app/controller/alarm_state.dart';
import 'package:alarm_app/utils/formatter.dart';
import 'package:alarm_app/utils/stringresources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alarm_model.dart';

class AlarmListItem extends ConsumerWidget {
  final Alarm alarm;

  const AlarmListItem({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedTime = FormatterUtil.formatTime(alarm.time);
    final formattedDate = FormatterUtil.formatDate(alarm.time);
    final repeatText =
        alarm.repeat == RepeatType.once
            ? 'Once'
            : alarm.repeat == RepeatType.daily
            ? 'Daily'
            : 'Weekly';

    return Dismissible(
      key: Key(alarm.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(StringsResource.confirmDelete),
              content: const Text(StringsResource.confirmationForDelete),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(StringsResource.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(StringsResource.delete),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        ref.read(alarmProvider.notifier).deleteAlarm(alarm.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          title: Text(alarm.label),
          subtitle: Text(repeatText),
          trailing: Switch(
            value: alarm.isActive,
            onChanged: (value) {
              ref.read(alarmProvider.notifier).toogleAlarm(alarm.id, value);
            },
          ),
        ),
      ),
    );
  }
}
