import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/models/time_table.dart';

part 'optimization.freezed.dart';

enum MinOrMax {
  min,
  max;

  T? apply<T extends Comparable<T>>(Iterable<T> valuesToOptimize) =>
      switch (this) {
        MinOrMax.min => valuesToOptimize.minOrNull,
        MinOrMax.max => valuesToOptimize.maxOrNull,
      };

  MinOrMax get other => switch (this) {
    MinOrMax.min => MinOrMax.max,
    MinOrMax.max => MinOrMax.min,
  };
}

@freezed
sealed class Optimization<T extends Comparable<T>> with _$Optimization<T> {
  const Optimization._();

  const factory Optimization(
    String name,
    MinOrMax minOrMax,
    T Function(TimeTable) getValueToOptimize,
  ) = OptimizationData;

  Iterable<TimeTable> apply(Iterable<TimeTable> timeTables) {
    if (timeTables.isEmpty) return timeTables;

    final annotatedTimeTables = timeTables.map(
      (timeTable) => (timeTable, getValueToOptimize(timeTable)),
    );
    final optimizedValue = minOrMax.apply(
      annotatedTimeTables.map((annotatedTimeTable) => annotatedTimeTable.$2),
    );

    return annotatedTimeTables
        .where((annotatedTimeTable) => annotatedTimeTable.$2 == optimizedValue)
        .map((annotatedTimeTable) => annotatedTimeTable.$1);
  }

  T? getWorst(Iterable<TimeTable> timeTables) =>
      minOrMax.other.apply(timeTables.map(getValueToOptimize));

  static final days = Optimization(
    "Days",
    MinOrMax.min,
    (timeTable) => timeTable.days.length,
  );
  static final weekDaysDiff = Optimization(
    "Week Days Diff",
    MinOrMax.min,
    (timeTable) => timeTable.weekDaysDiff.sum,
  );
  static final daysDurationsSum = Optimization(
    "Days Durations Sum",
    MinOrMax.min,
    (timeTable) => Duration(minutes: timeTable.daysDurationsInMinutes.sum),
  );
  static final maxDayDuration = Optimization(
    "Max Day Duration",
    MinOrMax.min,
    (timeTable) => Duration(minutes: timeTable.daysDurationsInMinutes.max),
  );
  static final maxEndTime = Optimization(
    "Max End Time",
    MinOrMax.min,
    (timeTable) => timeTable.maxDayEnd,
  );
  static final minStartTime = Optimization(
    "Min Start Time",
    MinOrMax.max,
    (timeTable) => timeTable.minDayStart,
  );
}
