import 'dart:math';
import 'package:flutter/material.dart';

class ItemScrollPhysics extends ScrollPhysics {
  /// Creates physics for snapping to item.
  /// Based on PageScrollPhysics
  final double itemHeight;
  final double targetPixelsLimit;

  const ItemScrollPhysics({
    ScrollPhysics parent,
    this.itemHeight = 80,
    this.targetPixelsLimit = 3.0,
  })  : assert(itemHeight != null && itemHeight > 0),
        super(parent: parent);

  @override
  ItemScrollPhysics applyTo(ScrollPhysics ancestor) {
    return ItemScrollPhysics(
        parent: buildParent(ancestor), itemHeight: itemHeight);
  }

  double _getItem(ScrollPosition position) {
    final double maxScrollItem =
        (position.maxScrollExtent / itemHeight).floorToDouble();
    return min(max(0, position.pixels / itemHeight), maxScrollItem);
  }

  double _getPixels(ScrollPosition position, double item) {
    return item * itemHeight;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double item = _getItem(position);
    if (velocity < -tolerance.velocity) {
      item -= targetPixelsLimit;
    } else if (velocity > tolerance.velocity) item += targetPixelsLimit;
    return _getPixels(position, item.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a item boundary.
//    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
//        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
//      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target =
        _getTargetPixels(position as ScrollPosition, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

typedef SelectedIndexCallback = void Function(int);
typedef TimePickerCallback = void Function(DateTime);

class TimePickerSpinner extends StatefulWidget {
  final DateTime time;
  final int minutesInterval;
  final int secondsInterval;
  final bool is24HourMode;
  final bool isShowSeconds;
  final TextStyle highlightedTextStyle;
  final TextStyle normalTextStyle;
  final double itemHeight;
  final double itemWidth;
  final AlignmentGeometry alignment;
  final double spacing;
  final bool isForce2Digits;
  final TimePickerCallback onTimeChange;

  const TimePickerSpinner(
      {Key key,
      this.time,
      this.minutesInterval = 1,
      this.secondsInterval = 1,
      this.is24HourMode = true,
      this.isShowSeconds = false,
      this.highlightedTextStyle,
      this.normalTextStyle,
      this.itemHeight,
      this.itemWidth,
      this.alignment,
      this.spacing,
      this.isForce2Digits = false,
      this.onTimeChange})
      : super(key: key);

  @override
  _TimePickerSpinnerState createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  ScrollController hourController = ScrollController();
  ScrollController minuteController = ScrollController();
  ScrollController secondController = ScrollController();
  ScrollController apController = ScrollController();
  int currentSelectedHourIndex = -1;
  int currentSelectedMinuteIndex = -1;
  int currentSelectedSecondIndex = -1;
  int currentSelectedAPIndex = -1;
  DateTime currentTime;
  bool isHourScrolling = false;
  bool isMinuteScrolling = false;
  bool isSecondsScrolling = false;
  bool isAPScrolling = false;

  /// default settings
  TextStyle defaultHighlightTextStyle =
      const TextStyle(fontSize: 32, color: Colors.black);
  TextStyle defaultNormalTextStyle =
      const TextStyle(fontSize: 32, color: Colors.black54);
  double defaultItemHeight = 60;
  double defaultItemWidth = 45;
  double defaultSpacing = 20;
  AlignmentGeometry defaultAlignment = Alignment.centerRight;

  /// getter

  TextStyle _getHighlightedTextStyle() {
    return widget.highlightedTextStyle ?? defaultHighlightTextStyle;
  }

  TextStyle _getNormalTextStyle() {
    return widget.normalTextStyle ?? defaultNormalTextStyle;
  }

  int _getHourCount() {
    return widget.is24HourMode ? 24 : 12;
  }

  int _getMinuteCount() {
    return (60 / widget.minutesInterval).floor();
  }

  int _getSecondCount() {
    return (60 / widget.secondsInterval).floor();
  }

  double _getItemHeight() {
    return widget.itemHeight ?? defaultItemHeight;
  }

  double _getItemWidth() {
    return widget.itemWidth ?? defaultItemWidth;
  }

  double _getSpacing() {
    return widget.spacing ?? defaultSpacing;
  }

  AlignmentGeometry _getAlignment() {
    return widget.alignment ?? defaultAlignment;
  }

  bool isLoop(int value) {
    return value > 10;
  }

  DateTime getDateTime() {
    int hour = currentSelectedHourIndex - _getHourCount();
    if (!widget.is24HourMode && currentSelectedAPIndex == 2) hour += 12;
    final int minute = (currentSelectedMinuteIndex -
            (isLoop(_getMinuteCount()) ? _getMinuteCount() : 1)) *
        widget.minutesInterval;
    final int second = (currentSelectedSecondIndex -
            (isLoop(_getSecondCount()) ? _getSecondCount() : 1)) *
        widget.secondsInterval;
    return DateTime(currentTime.year, currentTime.month, currentTime.day, hour,
        minute, second);
  }

  @override
  void initState() {
    currentTime = widget.time ?? DateTime.now();

    currentSelectedHourIndex =
        (currentTime.hour % (widget.is24HourMode ? 24 : 12)) + _getHourCount();
    hourController = ScrollController(
        initialScrollOffset: (currentSelectedHourIndex - 1) * _getItemHeight());

    currentSelectedMinuteIndex =
        (currentTime.minute / widget.minutesInterval).floor() +
            (isLoop(_getMinuteCount()) ? _getMinuteCount() : 1);
    minuteController = ScrollController(
        initialScrollOffset:
            (currentSelectedMinuteIndex - 1) * _getItemHeight());
    //print(currentSelectedMinuteIndex);
    //print((currentSelectedMinuteIndex - 1) * _getItemHeight()!);

    currentSelectedSecondIndex =
        (currentTime.second / widget.secondsInterval).floor() +
            (isLoop(_getSecondCount()) ? _getSecondCount() : 1);
    secondController = ScrollController(
        initialScrollOffset:
            (currentSelectedSecondIndex - 1) * _getItemHeight());

    currentSelectedAPIndex = currentTime.hour >= 12 ? 2 : 1;
    apController = ScrollController(
        initialScrollOffset: (currentSelectedAPIndex - 1) * _getItemHeight());

    super.initState();

    if (widget.onTimeChange != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onTimeChange(getDateTime()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(minuteController.offset);
    final List<Widget> contents = [
      SizedBox(
        width: _getItemWidth(),
        height: _getItemHeight() * 3,
        child: spinner(
          hourController,
          _getHourCount(),
          currentSelectedHourIndex,
          1,
          (index) {
            currentSelectedHourIndex = index;
            isHourScrolling = true;
          },
          () => isHourScrolling = false,
          isScrolling: isHourScrolling,
          isForce2Digits: false,
        ),
      ),
      spacer(),
      SizedBox(
        width: _getItemWidth(),
        height: _getItemHeight() * 3,
        child: spinner(
          minuteController,
          _getMinuteCount(),
          currentSelectedMinuteIndex,
          widget.minutesInterval,
          (index) {
            currentSelectedMinuteIndex = index;
            isMinuteScrolling = true;
          },
          () => isMinuteScrolling = false,
          isScrolling: isMinuteScrolling,
          isForce2Digits: widget.isForce2Digits,
        ),
      ),
    ];

    if (widget.isShowSeconds) {
      contents.add(spacer());
      contents.add(SizedBox(
        width: _getItemWidth(),
        height: _getItemHeight() * 3,
        child: spinner(
          secondController,
          _getSecondCount(),
          currentSelectedSecondIndex,
          widget.secondsInterval,
          (index) {
            currentSelectedSecondIndex = index;
            isSecondsScrolling = true;
          },
          () => isSecondsScrolling = false,
          isScrolling: isSecondsScrolling,
          isForce2Digits: widget.isForce2Digits,
        ),
      ));
    }

    if (!widget.is24HourMode) {
      contents.add(spacer());
      contents.add(SizedBox(
        width: _getItemWidth(),
        height: _getItemHeight() * 3,
        child: apSpinner(),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: contents,
    );
  }

  Widget spacer() {
    return SizedBox(
      width: _getSpacing(),
      height: _getItemHeight() * 3,
    );
  }

  Widget spinner(
    ScrollController controller,
    int max,
    int selectedIndex,
    int interval,
    SelectedIndexCallback onUpdateSelectedIndex,
    VoidCallback onScrollEnd, {
    bool isScrolling,
    bool isForce2Digits,
  }) {
    /// wrapping the spinner with stack and add container above it when it's scrolling
    /// this thing is to prevent an error causing by some weird stuff like this
    /// flutter: Another exception was thrown: 'package:flutter/src/widgets/scrollable.dart': Failed assertion: line 469 pos 12: '_hold == null || _drag == null': is not true.
    /// maybe later we can find out why this error is happening

    final Widget _spinner = NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is UserScrollNotification) {
          if (scrollNotification.direction.toString() ==
              "ScrollDirection.idle") {
            if (isLoop(max)) {
              final int segment = (selectedIndex / max).floor();
              if (segment == 0) {
                onUpdateSelectedIndex(selectedIndex + max);
                controller.jumpTo(controller.offset + (max * _getItemHeight()));
              } else if (segment == 2) {
                onUpdateSelectedIndex(selectedIndex - max);
                controller.jumpTo(controller.offset - (max * _getItemHeight()));
              }
            }
            setState(() {
              onScrollEnd();
              if (widget.onTimeChange != null) {
                widget.onTimeChange(getDateTime());
              }
            });
          }
        } else if (scrollNotification is ScrollUpdateNotification) {
          setState(() {
            onUpdateSelectedIndex(
                (controller.offset / _getItemHeight()).round() + 1);
          });
        }
        return true;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          String text = '';
          if (isLoop(max)) {
            text = ((index % max) * interval).toString();
          } else if (index != 0 && index != max + 1) {
            text = (((index - 1) % max) * interval).toString();
          }
          if (!widget.is24HourMode &&
              controller == hourController &&
              text == '0') {
            text = '12';
          }
          if (isForce2Digits && text != '') {
            text = text.padLeft(2, '0');
          }
          return Container(
            height: _getItemHeight(),
            alignment: _getAlignment(),
            child: Text(
              text,
              style: selectedIndex == index
                  ? _getHighlightedTextStyle()
                  : _getNormalTextStyle(),
              textAlign: TextAlign.center,
            ),
          );
        },
        controller: controller,
        itemCount: isLoop(max) ? max * 3 : max + 2,
        physics: ItemScrollPhysics(itemHeight: _getItemHeight()),
        padding: EdgeInsets.zero,
      ),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Column(
            children: [
              const Spacer(),
              Container(height: 2, color: const Color(0xff747474)),
              SizedBox(height: widget.itemHeight - 2),
              Container(height: 2, color: const Color(0xff747474)),
              const Spacer(),
            ],
          ),
        ),
        Positioned.fill(child: _spinner),
        if (isScrolling)
          Positioned.fill(
              child: Container(
            color: Colors.black.withOpacity(0),
          ))
        else
          Container()
      ],
    );
  }

  Widget apSpinner() {
    final Widget _spinner = NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is UserScrollNotification) {
          if (scrollNotification.direction.toString() ==
              "ScrollDirection.idle") {
            isAPScrolling = false;
            if (widget.onTimeChange != null) {
              widget.onTimeChange(getDateTime());
            }
          }
        } else if (scrollNotification is ScrollUpdateNotification) {
          setState(() {
            currentSelectedAPIndex =
                (apController.offset / _getItemHeight()).round() + 1;
            isAPScrolling = true;
          });
        }
        return true;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          final String text = index == 1 ? 'AM' : (index == 2 ? 'PM' : '');
          return Container(
            height: _getItemHeight(),
            alignment: Alignment.center,
            child: Text(
              text,
              style: currentSelectedAPIndex == index
                  ? _getHighlightedTextStyle()
                  : _getNormalTextStyle(),
            ),
          );
        },
        controller: apController,
        itemCount: 4,
        physics: ItemScrollPhysics(
          itemHeight: _getItemHeight(),
          targetPixelsLimit: 1,
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Column(
            children: [
              const Spacer(),
              Container(height: 2, color: const Color(0xff747474)),
              SizedBox(height: widget.itemHeight - 2),
              Container(height: 2, color: const Color(0xff747474)),
              const Spacer(),
            ],
          ),
        ),
        Positioned.fill(child: _spinner),
        if (isAPScrolling) Positioned.fill(child: Container()) else Container()
      ],
    );
  }
}
