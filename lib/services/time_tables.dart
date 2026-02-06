import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables.g.dart';

@Riverpod(keepAlive: true)
class TimeTables extends _$TimeTables {
  @override
  Future<Set<TimeTable>> build() async {
    final coursesCart = ref.watch(coursesCartProvider);
    final sections = await ref.watch(sectionsProvider.future);
    return TimeTable.allPossibleTimeTables(
      courseCodes: coursesCart,
      allSections: sections,
    ).toSet();
  }
}
