import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/optimizations.dart';
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

    final optimizations = ref.watch(optimizationsProvider);
    final Iterable<TimeTable> optimizedTimeTables = optimizations.fold(
      timeTables,
      (accOptimizedTimeTables, f) => f.apply(accOptimizedTimeTables),
    );

    return optimizedTimeTables.toSet();
  }
}
