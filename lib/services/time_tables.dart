import 'package:collection/collection.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables.g.dart';

@Riverpod(keepAlive: true)
class TimeTables extends _$TimeTables {
  @override
  Future<Set<TimeTable>> build() async {
    final Map<String, Set<Section>> sectionsPerCourseCode = await ref.watch(
      sectionsProvider.future,
    );
    final Set<TimeTable> timeTables = TimeTable.allPossibleTimeTables(
      sectionsPerCourseCode: sectionsPerCourseCode,
    );

    final optimizations = [
      composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.days.length,
      ),
      composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.weekDaysDiff.sum,
      ),
      composeOptimization(
        (a) => a.minOrNull,
        (timeTable) => timeTable.maxDayEnd,
      ),
      composeOptimization(
        (a) => a.maxOrNull,
        (timeTable) => timeTable.minDayStart,
      ),
    ];
    final Set<TimeTable> optimizedTimeTables = optimizations.fold(
      timeTables,
      (accOptimizedTimeTables, f) => f(accOptimizedTimeTables).toSet(),
    );
    return optimizedTimeTables;
  }
}

Iterable<TimeTable> Function(Iterable<TimeTable>)
composeOptimization<T extends Comparable<T>>(
  T? Function(Iterable<T>) minOrMaxOrNull,
  T Function(TimeTable) getValueToOptimize,
) => (timeTables) {
  final optimizedValue = minOrMaxOrNull(
    timeTables.map((timeTable) => getValueToOptimize(timeTable)),
  );
  return optimizedValue == null
      ? timeTables
      : timeTables.where(
          (timeTable) => getValueToOptimize(timeTable) == optimizedValue,
        );
};
