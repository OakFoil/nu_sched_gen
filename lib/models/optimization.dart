import 'package:flutter/material.dart';
import 'package:nu_sched_gen/models/time_table.dart';

@immutable
class Optimization<T extends Comparable<T>> {
  final String name;
  final T Function(Iterable<T>) minOrMax;
  final T Function(TimeTable) getValueToOptimize;

  const Optimization(this.name, this.minOrMax, this.getValueToOptimize);

  Iterable<TimeTable> apply(Iterable<TimeTable> timeTables) {
    if (timeTables.isEmpty) return timeTables;

    final annotatedTimeTables = timeTables.map(
      (timeTable) => (timeTable, getValueToOptimize(timeTable)),
    );
    final optimizedValue = minOrMax(
      annotatedTimeTables.map((annotatedTimeTable) => annotatedTimeTable.$2),
    );

    return annotatedTimeTables
        .where((annotatedTimeTable) => annotatedTimeTable.$2 == optimizedValue)
        .map((annotatedTimeTable) => annotatedTimeTable.$1);
  }
}
