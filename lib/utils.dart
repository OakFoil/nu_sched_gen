import 'package:flutter/material.dart';

extension NullUtils<T> on T? {
  String get toStringOrDash => this == null ? "-" : toString();
}

extension DurationUtils on Duration {
  String format() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }
}

extension TimeOfDayUtils on TimeOfDay {
  int get toMinute => hour * 60 + minute;
}
