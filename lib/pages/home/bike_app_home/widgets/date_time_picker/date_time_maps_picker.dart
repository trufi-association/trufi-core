import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trufi_core/l10n/trufi_localization.dart';
import 'package:trufi_core/pages/home/bike_app_home/widgets/date_time_picker/time_picker_spinner.dart';

class DateTimeMapsPicker extends StatefulWidget {
  const DateTimeMapsPicker({
    Key key,
    @required this.dateConf,
  }) : super(key: key);
  final DateTimeConf dateConf;

  @override
  _DateTimeMapsPickerState createState() => _DateTimeMapsPickerState();
}

class _DateTimeMapsPickerState extends State<DateTimeMapsPicker>
    with SingleTickerProviderStateMixin {
  DateTimeConf tempDateConf;
  final _nowDate = DateTime.now();

  @override
  void initState() {
    tempDateConf = widget.dateConf;
    if (tempDateConf?.date == null) {
      tempDateConf = tempDateConf.copyWith(date: _nowDate);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = TrufiLocalization.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Center(
      child: SizedBox(
        height: 550,
        width: 420,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      physics: isPortrait
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabButton(
                                text:
                                    localization.commonDeparture.toUpperCase(),
                                isPressed: !tempDateConf.isArriveBy,
                                onTap: () {
                                  setState(() {
                                    tempDateConf = tempDateConf.copyWith(
                                        isArriveBy: false);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: TabButton(
                                text: localization.commonArrival.toUpperCase(),
                                isPressed: tempDateConf.isArriveBy,
                                onTap: () {
                                  setState(() {
                                    tempDateConf =
                                        tempDateConf.copyWith(isArriveBy: true);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 50),
                          child: TimePickerSpinner(
                            key: ValueKey(
                                '${tempDateConf.date.minute}${tempDateConf.date.minute}'),
                            time: tempDateConf.date,
                            // is24HourMode: true,
                            normalTextStyle: theme.textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                            highlightedTextStyle:
                                theme.textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            spacing: 20,
                            alignment: Alignment.center,
                            itemHeight: 55,
                            itemWidth: 70,
                            isForce2Digits: true,
                            onTimeChange: (time) {
                              final timeUpdated = DateTime(
                                tempDateConf.date.year,
                                tempDateConf.date.month,
                                tempDateConf.date.day,
                                time.hour,
                                time.minute,
                              );
                              setState(() {
                                tempDateConf =
                                    tempDateConf.copyWith(date: timeUpdated);
                              });
                            },
                          ),
                        ),
                        const Divider(height: 0),
                        SizedBox(
                          height: 70,
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    tempDateConf = tempDateConf.copyWith(
                                        date: tempDateConf.date.subtract(
                                      const Duration(days: 1),
                                    ));
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(left: 16),
                                  minimumSize: const Size(50, 70),
                                  alignment: Alignment.centerLeft,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xff747474),
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: tempDateConf.date,
                                      firstDate:
                                          DateTime(tempDateConf.date.year - 1),
                                      lastDate:
                                          DateTime(tempDateConf.date.year + 5),
                                      builder:
                                          (BuildContext context, Widget child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: theme.accentColor,
                                            ),
                                          ),
                                          child: child,
                                        );
                                      },
                                    );
                                    if (selectedDate != null) {
                                      final dateUpdated = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day,
                                        tempDateConf.date.hour,
                                        tempDateConf.date.minute,
                                      );
                                      setState(() {
                                        tempDateConf = tempDateConf.copyWith(
                                            date: dateUpdated);
                                      });
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Text(
                                      DateFormat('E d. MMM  yyyy', languageCode)
                                          .format(tempDateConf.date),
                                      style: theme.textTheme.subtitle1.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    tempDateConf = tempDateConf.copyWith(
                                        date: tempDateConf.date.add(
                                      const Duration(days: 1),
                                    ));
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.only(right: 10),
                                  minimumSize: const Size(50, 70),
                                  alignment: Alignment.centerRight,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xff747474),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 0),
                        SizedBox(
                          height: 90,
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  tempDateConf = tempDateConf.copyWith(
                                      date: DateTime.now());
                                });
                              },
                              child: Text(
                                // TODO translate Reset to current time
                                "Auf aktuelle Uhrzeit zurücksetzen",
                                style: theme.textTheme.bodyText2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                        child: Text(
                          localization.commonCancel,
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(
                            tempDateConf.copyWith(
                                date: tempDateConf.date ?? _nowDate),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              theme.accentColor),
                        ),
                        child: Text(
                          localization.commonOK,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  static const _styleOptions = TextStyle(fontSize: 16);

  const TabButton({
    Key key,
    @required this.isPressed,
    @required this.text,
    @required this.onTap,
  }) : super(key: key);

  final String text;
  final bool isPressed;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 45,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
                  color: Colors.transparent,
                  child: Text(
                    text.toUpperCase(),
                    style: _styleOptions.copyWith(
                      color: isPressed
                          ? theme.textTheme.bodyText2.color
                          : const Color(0xff747474),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: isPressed
                ? theme.textTheme.bodyText2.color
                : const Color(0xff747474),
            height: 2,
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
