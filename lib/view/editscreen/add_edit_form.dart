import 'package:alarm_app/controller/alarm_state.dart';
import 'package:alarm_app/utils/stringresources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/alarm_model.dart';

class AddEditAlarmForm extends ConsumerStatefulWidget {
  final Alarm? alarm;
  final Function(DateTime, String, RepeatType) onSave;
  final Function() onDelete;

  const AddEditAlarmForm({
    super.key,
    this.alarm,
    required this.onSave,
    required this.onDelete,
  });

  @override
  ConsumerState<AddEditAlarmForm> createState() => _AddEditAlarmFormState();
}

class _AddEditAlarmFormState extends ConsumerState<AddEditAlarmForm> {
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

    widget.onSave(scheduledTime, _labelController.text.trim(), _repeat);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmState = ref.watch(alarmProvider);
    final isSaving =
        alarmState is AlarmAddingState || alarmState is AlarmUpdatingState;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time'),
            subtitle: Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 18),
            ),
            onTap: _selectTime,
          ),
          const Divider(),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: StringsResource.label,
              hintText: 'Enter alarm label',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _label = value),
          ),
          const SizedBox(height: 20),
          const Text(
            StringsResource.repeat,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RadioListTile<RepeatType>(
                  title: const Text(
                    maxLines: 1,
                    StringsResource.once,
                    style: TextStyle(fontSize: 8),
                  ),
                  value: RepeatType.once,
                  groupValue: _repeat,
                  onChanged: (value) => setState(() => _repeat = value!),
                ),
              ),
              Expanded(
                child: RadioListTile<RepeatType>(
                  title: const Text(
                    maxLines: 1,
                    StringsResource.daily,
                    style: TextStyle(fontSize: 8),
                  ),
                  value: RepeatType.daily,
                  groupValue: _repeat,
                  onChanged: (value) => setState(() => _repeat = value!),
                ),
              ),
              Expanded(
                child: RadioListTile<RepeatType>(
                  title: const Text(
                    maxLines: 1,
                    StringsResource.weekly,
                    style: TextStyle(fontSize: 8),
                  ),
                  value: RepeatType.weekly,
                  groupValue: _repeat,
                  onChanged: (value) => setState(() => _repeat = value!),
                ),
              ),
            ],
          ),
          const Spacer(),
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
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
    );
  }
}
