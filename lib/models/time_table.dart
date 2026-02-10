import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/models/section.dart';

@immutable
class TimeTable extends ConflictsWith<TimeTable> {
  final Set<Section> sections;
  @override
  Set<Schedule> get schedules =>
      sections.map((section) => section.schedules).flattened.toSet();
  Set<int> get days => schedules.map((schedule) => schedule.day).toSet();
  Set<int> get weekDaysDiff {
    final List<int> weekDays = {
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    }.difference(days).toList().sortedBy((a) => a);
    final List<int> weekDaysWithoutLast = List.from(weekDays);
    weekDaysWithoutLast.length = weekDaysWithoutLast.length - 1;
    return weekDaysWithoutLast
        .mapIndexed((index, a) => weekDays[index + 1] - a - 1)
        .toSet();
  }

  @override
  List<Object?> get props => [sections];

  TimeTable(this.sections);

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.union(timeTable.sections));

  static Set<TimeTable> allPossibleTimeTables({
    required Set<String> courseCodes,
    required Set<Section> allSections,
    Set<Section> registeredSections = const {},
  }) {
    final Set<Section> allOpenSections = registeredSections.union(
      allSections.where((section) => section.seatsLeft > 0).toSet(),
    );
    final Set<Set<Section>> allPossibleSectionsPerCourseCode = courseCodes
        .map(
          (courseCode) => allOpenSections
              .where((section) => section.courseCode == courseCode)
              .toSet(),
        )
        .toSet();
    if (allPossibleSectionsPerCourseCode.isEmpty ||
        allPossibleSectionsPerCourseCode.any(
          (courseCodeSections) => courseCodeSections.isEmpty,
        )) {
      return {};
    }
    final Set<Set<TimeTable>> allPossibleTimeTablesPerCourseCode =
        allPossibleSectionsPerCourseCode
            .map(
              (courseSections) =>
                  courseSections.map((section) => TimeTable({section})).toSet(),
            )
            .toSet();
    final Set<TimeTable> allPossibleTimeTables =
        allPossibleTimeTablesPerCourseCode.reduce(
          (accTimeTables, timeTables) => accTimeTables
              .map(
                (accTimeTable) => timeTables
                    .whereNot(
                      (timeTable) => accTimeTable.conflictsWith(timeTable),
                    )
                    .map((timeTable) => accTimeTable.mergeWith(timeTable)),
              )
              .flattened
              .toSet(),
        );
    assert(
      allPossibleTimeTables.every(
        (timeTable) =>
            setEquals(
              timeTable.sections.map((section) => section.courseCode).toSet(),
              courseCodes,
            ) &&
            !timeTable.schedules.containsConflictsSlow,
      ),
    );
    return allPossibleTimeTables;
  }
}
