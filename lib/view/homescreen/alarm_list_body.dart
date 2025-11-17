import 'package:alarm_app/controller/alarm_state.dart';

import 'package:alarm_app/view/homescreen/alarm_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmListBody extends ConsumerWidget {
  const AlarmListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmState = ref.watch(alarmProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        return Padding(
          padding:
              isLandscape
                  ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
                  : const EdgeInsets.all(16),
          child: _buildBodyContent(alarmState, () {
            ref.read(alarmProvider.notifier).initialize();
          }),
        );
      },
    );
  }

  Widget _buildBodyContent(AlarmState state, VoidCallback onPressed) {
    return switch (state) {
      AlarmLoadingState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading alarms...'),
          ],
        ),
      ),

      AlarmEmptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No alarms set',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text('Tap + to add an alarm', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),

      AlarmLoadedState(:final alarms) => ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return AlarmListItem(alarm: alarm);
        },
      ),

      AlarmErrorState(:final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error'),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onPressed;
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),

      _ => const SizedBox.shrink(),
    };
  }
}
