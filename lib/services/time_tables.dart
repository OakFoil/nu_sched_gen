import 'package:collection/collection.dart';
import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables.g.dart';

@Riverpod(keepAlive: true)
class TimeTables extends _$TimeTables {
  @override
  Future<Set<TimeTable>> build() async {
    final sectionsPerCourseCode = await ref.watch(sectionsProvider.future);
    final timeTables = TimeTable.allPossibleTimeTables(
      sectionsPerCourseCode: sectionsPerCourseCode,
    ).toSet();

    final optimizations = [
      _composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.days.length,
      ),
      _composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.weekDaysDiff.sum,
      ),
      _composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.maxDayEnd,
      ),
      _composeOptimization(
        (a) => a.maxOrNull,
        (timeTable) => timeTable.minDayStart,
      ),
    ];
    final Iterable<TimeTable> optimizedTimeTables = optimizations.fold(
      timeTables,
      (accOptimizedTimeTables, f) => f(accOptimizedTimeTables),
    );

    return optimizedTimeTables.toSet();
  }
}

Iterable<TimeTable> Function(Iterable<TimeTable>)
_composeOptimization<T extends Comparable<T>>(
  T? Function(Iterable<T>) minOrMaxOrNull,
  T Function(TimeTable) getValueToOptimize,
) => (timeTables) {
  final annotatedTimeTables = timeTables.map(
    (timeTable) => (timeTable, getValueToOptimize(timeTable)),
  );
  final optimizedValue = minOrMaxOrNull(
    annotatedTimeTables.map((annotatedTimeTable) => annotatedTimeTable.$2),
  );

  return optimizedValue == null
      ? timeTables
      : annotatedTimeTables
            .where(
              (annotatedTimeTable) => annotatedTimeTable.$2 == optimizedValue,
            )
            .map((annotatedTimeTable) => annotatedTimeTable.$1);
};
