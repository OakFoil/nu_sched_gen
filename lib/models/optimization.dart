import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/models/time_table.dart';

part 'optimization.freezed.dart';

@freezed
sealed class Optimization<T extends Comparable<T>> with _$Optimization<T> {
  const Optimization._();

  const factory Optimization(
    String name,
    T Function(Iterable<T>) minOrMax,
    T Function(TimeTable) getValueToOptimize,
  ) = OptimizationData;

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
