import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/optimizations.dart';
import 'package:nu_sched_gen/services/avilable_sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables.g.dart';

@Riverpod(keepAlive: true)
class TimeTables extends _$TimeTables {
  @override
  Future<Set<TimeTable>> build() async {
    final coursesCart = ref.watch(coursesCartProvider);
    if (coursesCart.isEmpty) return {};
    final avilableSections = Map.of(
      await ref.watch(avilableSectionsProvider.future),
    );
    avilableSections.removeWhere(
      (courseCode, sections) => !coursesCart.contains(courseCode),
    );
    final timeTables = TimeTable.allPossibleTimeTables(
      avilableSections.values.toSet(),
    ).toSet();

    final optimizations = ref.watch(optimizationsProvider);
    final Iterable<TimeTable> optimizedTimeTables = optimizations.fold(
      timeTables,
      (accOptimizedTimeTables, f) => f.apply(accOptimizedTimeTables),
    );

    return optimizedTimeTables.toSet();
  }
}
