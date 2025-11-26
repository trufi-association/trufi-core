enum RealtimeStateTrufi { scheduled, updated, canceled, added, modified }

RealtimeStateTrufi getRealtimeStateByString(String? realtimeState) {
  return RealtimeStateExtension.names.keys.firstWhere(
    (key) => key.name == realtimeState,
    orElse: () => RealtimeStateTrufi.scheduled,
  );
}

extension RealtimeStateExtension on RealtimeStateTrufi {
  static const names = <RealtimeStateTrufi, String>{
    RealtimeStateTrufi.scheduled: 'SCHEDULED',
    RealtimeStateTrufi.updated: 'UPDATED',
    RealtimeStateTrufi.canceled: 'CANCELED',
    RealtimeStateTrufi.added: 'ADDED',
    RealtimeStateTrufi.modified: 'MODIFIED'
  };
  String get name => names[this] ?? 'SCHEDULED';
}
