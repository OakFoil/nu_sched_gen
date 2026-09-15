import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/avilable_sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables_without_optimizations.g.dart';

@Riverpod(keepAlive: true)
Future<Set<TimeTable>> timeTablesWithoutOptimizations(Ref ref) async {
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

  return timeTables;
}
