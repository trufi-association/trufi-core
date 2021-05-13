import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({Key key, @required this.dateConf})
      : assert(dateConf != null),
        super(key: key);

  final DateTimeConf dateConf;

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  static const _styleOptions = TextStyle(fontSize: 16);
  final _nowDate = DateTime.now().roundDown(delta: const Duration(minutes: 15));
  DateTimeConf tempDateConf;

  @override
  void initState() {
    tempDateConf = widget.dateConf;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    // TODO translate the 3 text elements
    return Container(
      height: MediaQuery.of(context).size.height *
          (MediaQuery.of(context).orientation == Orientation.portrait
              ? 0.4
              : 0.6),
      color: theme.backgroundColor,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  localization.commonCancel,
                  textAlign: TextAlign.left,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop(const DateTimeConf(null));
                },
                child: const Text(
                  "Leaving now",
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    tempDateConf.copyWith(date: tempDateConf.date ?? _nowDate),
                  );
                },
                child: Text(localization.commonOK),
              ),
            ],
          ),
          const Divider(height: 0, thickness: 1),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(20, 5, 5, 0),
                  decoration: BoxDecoration(
                    color: tempDateConf.isArriveBy
                        ? theme.backgroundColor
                        : theme.primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        tempDateConf = tempDateConf.copyWith(isArriveBy: false);
                      });
                    },
                    child: Text(
                      "Departure",
                      style: _styleOptions.copyWith(
                        color: tempDateConf.isArriveBy
                            ? theme.textTheme.bodyText1.color
                            : theme.textTheme.subtitle1.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.fromLTRB(5, 5, 20, 0),
                  decoration: BoxDecoration(
                    color: !tempDateConf.isArriveBy
                        ? theme.backgroundColor
                        : theme.primaryColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        tempDateConf = tempDateConf.copyWith(isArriveBy: true);
                      });
                    },
                    child: Text(
                      "Arrival",
                      style: _styleOptions.copyWith(
                        color: !tempDateConf.isArriveBy
                            ? theme.textTheme.bodyText1.color
                            : theme.textTheme.subtitle1.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              onDateTimeChanged: (picked) {
                tempDateConf = tempDateConf.copyWith(date: picked);
              },
              use24hFormat: true,
              initialDateTime: tempDateConf.date != null
                  ? tempDateConf.date
                      .roundDown(delta: const Duration(minutes: 15))
                  : _nowDate,
              minimumDate: _nowDate.subtract(const Duration(minutes: 15)),
              maximumDate: _nowDate.add(const Duration(days: 30)),
              minuteInterval: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class DateTimeConf {
  const DateTimeConf(
    this.date, {
    this.isArriveBy = false,
  });

  final DateTime date;
  final bool isArriveBy;

  DateTimeConf copyWith({
    DateTime date,
    bool isArriveBy,
  }) {
    return DateTimeConf(
      date ?? this.date,
      isArriveBy: isArriveBy ?? this.isArriveBy,
    );
  }
}

extension on DateTime {
  DateTime roundDown({Duration delta = const Duration(seconds: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch - millisecondsSinceEpoch % delta.inMilliseconds);
  }
}
