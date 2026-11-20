import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trufi_core_utils/trufi_core_utils.dart';

/// #1065: the questions an external link asks before it replaces the app's
/// screens.
void main() {
  group('LeaveConfirmations.confirm', () {
    test('lets the screens go when nobody asks', () async {
      expect(await LeaveConfirmations().confirm(), isTrue);
    });

    test('asks the newest question first and stops at the first no', () async {
      final confirmations = LeaveConfirmations();
      final asked = <String>[];
      confirmations
        ..add(() async {
          asked.add('older');
          return true;
        })
        ..add(() async {
          asked.add('newer');
          return false;
        });

      expect(await confirmations.confirm(), isFalse);
      expect(asked, ['newer']);
    });

    test('lets the screens go when every question does', () async {
      final confirmations = LeaveConfirmations();
      final asked = <String>[];
      confirmations
        ..add(() async {
          asked.add('older');
          return true;
        })
        ..add(() async {
          asked.add('newer');
          return true;
        });

      expect(await confirmations.confirm(), isTrue);
      expect(asked, ['newer', 'older']);
    });

    test('a removed question is not asked', () async {
      final confirmations = LeaveConfirmations();
      Future<bool> no() async => false;
      confirmations
        ..add(no)
        ..remove(no);

      expect(await confirmations.confirm(), isTrue);
    });

    test(
      'a question removed while another one is being asked is skipped',
      () async {
        final confirmations = LeaveConfirmations();
        final asked = <String>[];
        Future<bool> older() async {
          asked.add('older');
          return false;
        }

        confirmations
          ..add(older)
          ..add(() async {
            asked.add('newer');
            // The screen of the older question closes meanwhile.
            confirmations.remove(older);
            return true;
          });

        // Its screen is gone: there is nothing left to ask about.
        expect(await confirmations.confirm(), isTrue);
        expect(asked, ['newer']);
      },
    );
  });

  group('LeaveConfirmations.maybeOf', () {
    testWidgets('reads the one provided above', (tester) async {
      final provided = LeaveConfirmations();
      LeaveConfirmations? read;
      await tester.pumpWidget(
        Provider<LeaveConfirmations>.value(
          value: provided,
          child: Builder(
            builder: (context) {
              read = LeaveConfirmations.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(read, same(provided));
    });

    testWidgets('is null when none is provided', (tester) async {
      LeaveConfirmations? read = LeaveConfirmations();
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            read = LeaveConfirmations.maybeOf(context);
            return const SizedBox();
          },
        ),
      );

      expect(read, isNull);
    });
  });
}
