import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/models/time_table.dart';

part 'optimization.freezed.dart';

enum MinOrMax {
  min,
  max;

  T apply<T extends Comparable<T>>(Iterable<T> valuesToOptimize) =>
      switch (this) {
        MinOrMax.min => valuesToOptimize.min,
        MinOrMax.max => valuesToOptimize.max,
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
}
