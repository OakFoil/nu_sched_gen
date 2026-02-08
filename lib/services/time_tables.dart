import 'package:collection/collection.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
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
    final Set<TimeTable> timeTables = TimeTable.allPossibleTimeTables(
      courseCodes: coursesCart,
      allSections: sections,
    ).toSet();
    final minDaysLength = timeTables
        .map((timeTable) => timeTable.days.length)
        .minOrNull;
    final Set<TimeTable> timeTablesWithLeastDays = minDaysLength == null
        ? timeTables
        : timeTables
              .where((timeTable) => timeTable.days.length <= minDaysLength)
              .toSet();
    final minSumOfWeekDaysDiff = timeTablesWithLeastDays
        .map((timeTable) => timeTable.weekDaysDiff.sum)
        .minOrNull;
    final Set<TimeTable> timeTablesWithLeastDaysAndOrderedDays =
        minSumOfWeekDaysDiff == null
        ? timeTablesWithLeastDays
        : timeTablesWithLeastDays
              .where(
                (timeTable) =>
                    timeTable.weekDaysDiff.sum <= minSumOfWeekDaysDiff,
              )
              .toSet();
    final minEnd = timeTablesWithLeastDaysAndOrderedDays
        .map(
          (timeTable) =>
              timeTable.schedules.map((schedule) => schedule.end).max,
        )
        .minOrNull;
    final Set<TimeTable> timeTablesWithLeastDaysAndOrderedDaysAndMinEnd =
        minEnd == null
        ? timeTablesWithLeastDaysAndOrderedDays
        : timeTablesWithLeastDaysAndOrderedDays
              .where(
                (timeTable) => timeTable.schedules.every(
                  (schedule) => schedule.end.compareTo(minEnd) <= 0,
                ),
              )
              .toSet();
    final maxStart = timeTablesWithLeastDaysAndOrderedDaysAndMinEnd
        .map(
          (timeTable) =>
              timeTable.schedules.map((schedule) => schedule.start).min,
        )
        .maxOrNull;
    final timeTablesWithLeastDaysAndOrderedDaysAndMinEndAndMaxStart =
        maxStart == null
        ? timeTablesWithLeastDaysAndOrderedDaysAndMinEnd
        : timeTablesWithLeastDaysAndOrderedDaysAndMinEnd.where(
            (timeTable) => timeTable.schedules.every(
              (schedule) => schedule.start.compareTo(maxStart) >= 0,
            ),
          );
    return timeTablesWithLeastDaysAndOrderedDaysAndMinEndAndMaxStart
        .where((timeTable) => !timeTable.schedules.containsConflicts)
        .toSet();
  }
}
