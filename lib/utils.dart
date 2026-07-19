import 'package:flutter/material.dart';

extension NullUtils<T> on T? {
  String get toStringOrDash => this == null ? "-" : toString();
}

extension DurationUtils on Duration {
  String get format =>
      '${inHours.toString().padLeft(2, '0')}:${inMinutes.remainder(60).toString().padLeft(2, '0')}';
}

extension TimeOfDayUtils on TimeOfDay {
  int get toMinute => hour * 60 + minute;
}
