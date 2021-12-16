import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({Key? key, required this.dateConf})
      : assert(dateConf != null),
        super(key: key);

  final DateTimeConf dateConf;

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker>
    with SingleTickerProviderStateMixin {
  static const _styleOptions = TextStyle(fontSize: 16);
  final _nowDate = DateTime.now()
      .roundDown(delta: const Duration(minutes: 15))
      .add(const Duration(minutes: 15));
  TabController? _controller;
  late DateTimeConf tempDateConf;
  DateTime? initialDateTime;

  @override
  void initState() {
    tempDateConf = widget.dateConf;
    initialDateTime =
        tempDateConf.date != null && tempDateConf.date!.isAfter(_nowDate)
            ? tempDateConf.date!.roundDown(delta: const Duration(minutes: 15))
            : _nowDate;
    super.initState();
    _controller = TabController(
        length: 3, initialIndex: tempDateConf.isArriveBy! ? 2 : 1, vsync: this);
    _controller!.addListener(() {
      if (_controller!.index == 0) {
        setState(() {
          Navigator.of(context).pop(const DateTimeConf(null));
        });
      } else if (_controller!.index == 1) {
        setState(() {
          tempDateConf = tempDateConf.copyWith(isArriveBy: false);
        });
      } else if (_controller!.index == 2) {
        setState(() {
          tempDateConf = tempDateConf.copyWith(isArriveBy: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    return Container(
      height: MediaQuery.of(context).size.height *
          (MediaQuery.of(context).orientation == Orientation.portrait
              ? 0.35
              : 0.6),
      color: theme.backgroundColor,
      child: Column(
        children: [
          TabBar(
            labelPadding: const EdgeInsets.only(top: 18, bottom: 10),
            controller: _controller,
            indicatorWeight: 3,
            tabs: [
              Text(
                localization.commonLeavingNow,
                style: _styleOptions.copyWith(
                  color: theme.textTheme.bodyText1!.color,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                localization.commonDeparture,
                style: _styleOptions.copyWith(
                  color: tempDateConf.isArriveBy!
                      ? Colors.grey[700]
                      : theme.textTheme.bodyText2!.color,
                  fontWeight: tempDateConf.isArriveBy!
                      ? FontWeight.w400
                      : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                localization.commonArrival,
                style: _styleOptions.copyWith(
                  color: !tempDateConf.isArriveBy!
                      ? Colors.grey[700]
                      : theme.textTheme.bodyText2!.color,
                  fontWeight: !tempDateConf.isArriveBy!
                      ? FontWeight.w400
                      : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              key: UniqueKey(),
              onDateTimeChanged: (picked) {
                tempDateConf = tempDateConf.copyWith(date: picked);
                initialDateTime = picked;
              },
              use24hFormat: true,
              initialDateTime: initialDateTime,
              minimumDate: _nowDate,
              maximumDate: _nowDate.add(const Duration(days: 30)),
              minuteInterval: 15,
            ),
          ),
          const Divider(height: 0, thickness: 1),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: SafeArea(
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        localization.commonCancel.toUpperCase(),
                        style: theme.textTheme.bodyText1,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  thickness: 1,
                ),
                Expanded(
                  child: SafeArea(
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          tempDateConf.copyWith(
                              date: tempDateConf.date ?? _nowDate),
                        );
                      },
                      child: Text(
                        localization.commonOK.toUpperCase(),
                        style: theme.textTheme.bodyText2,
                      ),
                    ),
                  ),
                ),
              ],
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

  final DateTime? date;
  final bool? isArriveBy;

  DateTimeConf copyWith({
    DateTime? date,
    bool? isArriveBy,
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
