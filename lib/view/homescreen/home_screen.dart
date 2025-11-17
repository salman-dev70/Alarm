import 'package:alarm_app/controller/alarm_state.dart';
import 'package:alarm_app/providers/provider_objects.dart';
import 'package:alarm_app/services/notification_service.dart';
import 'package:alarm_app/view/editscreen/edit_Screen.dart';
import 'package:alarm_app/view/homescreen/alarm_list_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarms'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const AlarmListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // NotificationService().showImmediateTestNotification();
          NotificationService().testSimpleNotification();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const AddEditAlarmScreen()),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
