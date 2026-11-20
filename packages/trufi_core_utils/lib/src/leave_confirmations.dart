import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// The questions to ask the rider before the app's screens are replaced from
/// outside them.
///
/// A screen that holds something the rider must not lose without being asked
/// (a navigation in progress, whose exit button asks first) adds its question
/// while it is on screen and removes it when it goes. Code that replaces the
/// app's screens on its own, such as an external link opened while the app
/// runs, awaits [confirm] and goes ahead only when it returns true.
///
/// `TrufiApp` provides one above its screens; [maybeOf] reads it.
class LeaveConfirmations {
  final List<Future<bool> Function()> _questions = [];

  /// Adds [question], asked by [confirm] until it is [remove]d. It completes
  /// with true to let the screens go.
  void add(Future<bool> Function() question) => _questions.add(question);

  /// Removes a question added with [add].
  void remove(Future<bool> Function() question) => _questions.remove(question);

  /// Asks the questions, the newest first, and stops at the first one that
  /// completes with false. True when every question let the screens go, and
  /// when there is none. A question removed while another one is being asked
  /// (its screen closed meanwhile) is skipped.
  Future<bool> confirm() async {
    for (final question in _questions.reversed.toList()) {
      if (!_questions.contains(question)) continue;
      if (!await question()) return false;
    }
    return true;
  }

  /// The one provided above [context], or null when there is none (an app
  /// that does not run on `TrufiApp`).
  static LeaveConfirmations? maybeOf(BuildContext context) =>
      Provider.of<LeaveConfirmations?>(context, listen: false);
}
