import 'dart:async';

class CompositeSubscription {
  List<StreamSubscription> _subscriptions = [];

  void cancel() {
    for (final n in _subscriptions) {
      n.cancel();
    }
    _subscriptions = [];
  }

  CompositeSubscription add(StreamSubscription subscription) {
    _subscriptions.add(subscription);
    return this;
  }

  bool remove(StreamSubscription subscription) {
    final index = _subscriptions.indexOf(subscription);
    if (index != -1) {
      _subscriptions.removeAt(index);
      subscription.cancel();
      return true;
    } else {
      return false;
    }
  }

  bool contains(StreamSubscription subscription) {
    return _subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return _subscriptions;
  }
}
