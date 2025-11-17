class AlarmRepositoryException implements Exception {
  final String message;
  AlarmRepositoryException(this.message);

  @override
  String toString() => 'AlarmRepositoryException: $message';
}

class AlarmScheduleException implements Exception {
  final String message;
  AlarmScheduleException(this.message);

  @override
  String toString() => 'AlarmScheduleException: $message';
}
