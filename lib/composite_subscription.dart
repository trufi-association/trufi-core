import 'dart:async';

class CompositeSubscription {
  List<StreamSubscription> _subscriptions = [];

  void cancel() {
    for (var n in this._subscriptions) {
      n.cancel();
    }
    this._subscriptions = [];
  }

  CompositeSubscription add(StreamSubscription subscription) {
    this._subscriptions.add(subscription);
    return this;
  }

  bool remove(StreamSubscription subscription) {
    var index = this._subscriptions.indexOf(subscription);
    if (index != -1) {
      this._subscriptions.removeAt(index);
      subscription.cancel();
      return true;
    } else {
      return false;
    }
  }

  bool contains(StreamSubscription subscription) {
    return this._subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return this._subscriptions;
  }
}
