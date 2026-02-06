import 'package:flutter/material.dart';

class Constraint {
  TimeOfDay dayStart, dayEnd;
  Set<int> days;

  Constraint({
    this.dayStart = const TimeOfDay(hour: 8, minute: 30),
    this.dayEnd = const TimeOfDay(hour: 8, minute: 30),
    this.days = const {1, 2, 3, 4, 6, 7}, // no 5 (Friday)
  });
}
