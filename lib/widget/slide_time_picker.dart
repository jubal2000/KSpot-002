import 'dart:math';
import 'package:flutter/material.dart';
import 'package:progressive_time_picker/painters/time_picker_painter.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';

/// Returns a widget which displays a circle to be used as a picker.
///
/// Required arguments are init and end to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
class SlideTimePicker extends StatefulWidget {
  /// the initial time
  final PickedTime initTime;

  /// the end time
  final PickedTime endTime;

  /// the number of primary sectors to be painted
  /// will be painted using selectionColor
  final int? primarySectors;

  /// the number of secondary sectors to be painted
  /// will be painted using baseColor
  final int? secondarySectors;

  /// an optional widget that would be mounted inside the circle
  final Widget? child;

  /// height of the canvas, default at 220
  final double? height;

  /// width of the canvas, default at 220
  final double? width;

  /// callback function when init and end change
  final SelectionChanged<PickedTime> onSelectionChange;

  /// callback function when init and end finish
  final SelectionChanged<PickedTime> onSelectionEnd;

  /// used to decorate the our widget
  final TimePickerDecoration? decoration;

  /// used to enabled or disabled Selection of Init Handler
  final bool isInitHandlerSelectable;

  /// used to enabled or disabled Selection of End Handler
  final bool isEndHandlerSelectable;

  SlideTimePicker({
    Key? key,
    required this.initTime,
    required this.endTime,
    required this.onSelectionChange,
    required this.onSelectionEnd,
    this.child,
    this.decoration,
    this.height,
    this.width,
    this.primarySectors,
    this.secondarySectors,
    this.isInitHandlerSelectable = true,
    this.isEndHandlerSelectable = true,
  }) : super(key: key);

  @override
  SlideTimePickerState createState() => SlideTimePickerState();
}

class SlideTimePickerState extends State<SlideTimePicker> {
  int _init = 0;
  int _end = 0;

  initData() {
    _init = pickedTimeToDivision(
        pickedTime: widget.initTime,
        clockTimeFormat: ClockTimeFormat.TWENTYFOURHOURS,
        clockIncrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
    _end = pickedTimeToDivision(
        pickedTime: widget.endTime,
        clockTimeFormat: ClockTimeFormat.TWENTYFOURHOURS,
        clockIncrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
  }

  refreshData(PickedTime startTime, PickedTime endTime) {
    setState(() {
      _init = pickedTimeToDivision(
          pickedTime: startTime,
          clockTimeFormat: ClockTimeFormat.TWENTYFOURHOURS,
          clockIncrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
      _end = pickedTimeToDivision(
          pickedTime: endTime,
          clockTimeFormat: ClockTimeFormat.TWENTYFOURHOURS,
          clockIncrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  TimePickerDecoration getDefaultPickerDecorator() {
    var startBox = TimePickerHandlerDecoration(
      color: Colors.lightBlue[900]!.withOpacity(0.6),
      shape: BoxShape.circle,
      icon:
      Icon(Icons.filter_tilt_shift, size: 30, color: Colors.lightBlue[700]),
      useRoundedPickerCap: true,
    );

    var endBox = TimePickerHandlerDecoration(
      color: Colors.lightBlue[900]!.withOpacity(0.8),
      shape: BoxShape.circle,
      icon:
      Icon(Icons.filter_tilt_shift, size: 40, color: Colors.lightBlue[700]),
      useRoundedPickerCap: true,
    );

    var sweepDecoration = TimePickerSweepDecoration(
      pickerStrokeWidth: 12,
      pickerGradient: SweepGradient(
        startAngle: 3 * pi / 2,
        endAngle: 7 * pi / 2,
        tileMode: TileMode.repeated,
        colors: [Colors.red.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
      ),
    );

    var primarySectorDecoration = TimePickerSectorDecoration(
        color: Colors.blue, width: 2, size: 8, useRoundedCap: false);

    var secondarySectorDecoration = primarySectorDecoration.copyWith(
      color: Colors.lightBlue.withOpacity(0.5),
      width: 1,
      size: 6,
    );

    return TimePickerDecoration(
      sweepDecoration: sweepDecoration,
      baseColor: Colors.lightBlue[200]!.withOpacity(0.2),
      primarySectorsDecoration: primarySectorDecoration,
      secondarySectorsDecoration: secondarySectorDecoration,
      initHandlerDecoration: startBox,
      endHandlerDecoration: endBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 220,
      width: widget.width ?? 220,
      child: TimePickerPainter(
        init: _init,
        end: _end,
        primarySectors: widget.primarySectors ?? 0,
        secondarySectors: widget.secondarySectors ?? 0,
        child: widget.child ?? Container(),
        onSelectionChange: (newInit, newEnd, status) {
          var inTime = formatTime(time: newInit, incrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
          var outTime = formatTime(time: newEnd, incrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);

          widget.onSelectionChange(inTime, outTime, status);

          setState(() {
            _init = newInit;
            _end = newEnd;
          });
        },
        onSelectionEnd: (newInit, newEnd, status) {
          var inTime = formatTime(time: newInit, incrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);
          var outTime = formatTime(time: newEnd, incrementTimeFormat: ClockIncrementTimeFormat.SIXTYMIN);

          widget.onSelectionEnd(inTime, outTime, status);
        },
        pickerDecoration: widget.decoration ?? getDefaultPickerDecorator(),
        isInitHandlerSelectable: widget.isInitHandlerSelectable,
        isEndHandlerSelectable: widget.isEndHandlerSelectable,
      ),
    );
  }
}
