import 'package:trufi_core/models/enums/realtime_state.dart';

enum RealtimeState { scheduled, updated, canceled, added, modified }

RealtimeState getRealtimeStateByString(String realtimeState) {
  return RealtimeStateExtension.names.keys.firstWhere(
    (key) => key.name == realtimeState,
    orElse: () => RealtimeState.scheduled,
  );
}

extension RealtimeStateExtension on RealtimeState {
  static const names = <RealtimeState, String>{
    RealtimeState.scheduled: 'SCHEDULED',
    RealtimeState.updated: 'UPDATED',
    RealtimeState.canceled: 'CANCELED',
    RealtimeState.added: 'ADDED',
    RealtimeState.modified: 'MODIFIED',
  };
  String get name => names[this] ?? 'SCHEDULED';

  RealtimeStateTrufi toRealtimeState() {
    switch (this) {
      case RealtimeState.scheduled:
        return RealtimeStateTrufi.scheduled;
      case RealtimeState.updated:
        return RealtimeStateTrufi.updated;
      case RealtimeState.canceled:
        return RealtimeStateTrufi.canceled;
      case RealtimeState.added:
        return RealtimeStateTrufi.added;
      case RealtimeState.modified:
        return RealtimeStateTrufi.modified;
    }
  }
}
