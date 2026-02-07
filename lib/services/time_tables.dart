import 'package:collection/collection.dart';
import 'package:nu_sched_gen/models/schedule.dart';
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
    final Iterable<TimeTable> timeTables = TimeTable.allPossibleTimeTables(
      courseCodes: coursesCart,
      allSections: sections,
    );
    final days = timeTables
        .sortedBy((timeTable) => timeTable.schedules.numberOfDays)
        .firstOrNull
        ?.schedules
        .numberOfDays;
    return (days == null
            ? timeTables
            : timeTables.where(
                (timeTable) => timeTable.schedules.numberOfDays <= days,
              ))
        .toSet();
  }
}
