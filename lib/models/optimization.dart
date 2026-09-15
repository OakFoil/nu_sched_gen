import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/models/time_table.dart';

part 'optimization.freezed.dart';

enum MinOrMax { min, max }

@freezed
sealed class Optimization<T extends Comparable<T>> with _$Optimization<T> {
  const Optimization._();

  const factory Optimization(
    String name,
    MinOrMax minOrMax,
    T Function(TimeTable) getValueToOptimize,
  ) = OptimizationData;

  T applyMinOrMax(Iterable<T> valuesToOptimize) => switch (minOrMax) {
    MinOrMax.min => valuesToOptimize.min,
    MinOrMax.max => valuesToOptimize.max,
  };

  Iterable<TimeTable> apply(Iterable<TimeTable> timeTables) {
    if (timeTables.isEmpty) return timeTables;

    final annotatedTimeTables = timeTables.map(
      (timeTable) => (timeTable, getValueToOptimize(timeTable)),
    );
    final optimizedValue = applyMinOrMax(
      annotatedTimeTables.map((annotatedTimeTable) => annotatedTimeTable.$2),
    );

    return annotatedTimeTables
        .where((annotatedTimeTable) => annotatedTimeTable.$2 == optimizedValue)
        .map((annotatedTimeTable) => annotatedTimeTable.$1);
  }
}
