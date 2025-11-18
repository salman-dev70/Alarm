import 'package:alarm_app/controller/alarm_state.dart';
import 'package:alarm_app/models/alarm_model.dart';
import 'package:alarm_app/utils/stringresources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditAlarmScreen extends ConsumerStatefulWidget {
  final Alarm? alarm;

  const AddEditAlarmScreen({super.key, this.alarm});

  @override
  ConsumerState<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends ConsumerState<AddEditAlarmScreen> {
  late TimeOfDay _selectedTime;
  late String _label;
  late RepeatType _repeat;

  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.alarm != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.time);
      _label = widget.alarm!.label;
      _repeat = widget.alarm!.repeat;
      _labelController.text = _label;
    } else {
      final now = DateTime.now();
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute + 1);
      _label = 'Alarm';
      _repeat = RepeatType.once;
      _labelController.text = _label;
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final scheduledTime =
        alarmTime.isBefore(now)
            ? alarmTime.add(const Duration(days: 1))
            : alarmTime;

    final ref = ProviderScope.containerOf(context).read(alarmProvider.notifier);

    if (widget.alarm != null) {
      // Update existing alarm
      final updatedAlarm = widget.alarm!.copyWith(
        time: scheduledTime,
        label: _labelController.text.trim(),
        repeat: _repeat,
      );
      ref.updateAlarm(updatedAlarm);
    } else {
      // Add new alarm
      ref.addAlarm(scheduledTime, _labelController.text.trim(), _repeat);
    }

    Navigator.pop(context);
  }

  void _deleteAlarm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Alarm"),
          content: const Text("Are you sure you want to delete this alarm?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final ref = ProviderScope.containerOf(
                  context,
                ).read(alarmProvider.notifier);
                ref.deleteAlarm(widget.alarm!.id);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final alarmState = ref.watch(alarmProvider);
    final isSaving =
        alarmState is AlarmAddingState || alarmState is AlarmUpdatingState;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? 'Update Alarm' : 'Add Alarm'),
        actions: [
          if (widget.alarm != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteAlarm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // ✅ ADD THIS
          child: Column(
            children: [
              // Time Picker
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: const Text('Time'),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectTime,
              ),

              const Divider(),
              const SizedBox(height: 16),

              // Label Input
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: StringsResource.label,
                  hintText: 'Enter alarm label',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                onChanged: (value) => setState(() => _label = value),
              ),

              const SizedBox(height: 24),

              // Repeat Options
              const Text(
                StringsResource.repeat,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  RadioListTile<RepeatType>(
                    title: const Text(StringsResource.once),
                    value: RepeatType.once,
                    groupValue: _repeat,
                    onChanged: (value) => setState(() => _repeat = value!),
                  ),
                  RadioListTile<RepeatType>(
                    title: const Text(StringsResource.daily),
                    value: RepeatType.daily,
                    groupValue: _repeat,
                    onChanged: (value) => setState(() => _repeat = value!),
                  ),
                  RadioListTile<RepeatType>(
                    title: const Text(StringsResource.weekly),
                    value: RepeatType.weekly,
                    groupValue: _repeat,
                    onChanged: (value) => setState(() => _repeat = value!),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveAlarm,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'SAVE ALARM',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}
