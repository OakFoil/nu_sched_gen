import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/models/section.dart';

@immutable
class TimeTable extends Equatable implements ConflictsWith<TimeTable> {
  final Set<Section> sections;
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

  const TimeTable(this.sections);

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.union(timeTable.sections));

  @override
  bool conflictsWith(value) => sections.containsConflicts;

  static Iterable<TimeTable> allPossibleTimeTables({
    required Set<String> courseCodes,
    required Iterable<Section> allSections,
    Iterable<Section> registeredSections = const {},
  }) {
    final Set<Section> allOpenSections = registeredSections
        .followedBy(allSections.where((section) => section.seatsLeft > 0))
        .toSet();
    final allPossibleSectionsPerCourseCode = courseCodes.map(
      (courseCode) =>
          allOpenSections.where((section) => section.courseCode == courseCode),
    );
    if (allPossibleSectionsPerCourseCode.isEmpty ||
        allPossibleSectionsPerCourseCode.any(
          (courseCodeSections) => courseCodeSections.isEmpty,
        )) {
      return Iterable.empty();
    }
    final Iterable<Iterable<TimeTable>> allPossibleTimeTablesPerCourseCode =
        allPossibleSectionsPerCourseCode.map(
          (courseSections) =>
              courseSections.map((section) => TimeTable({section})),
        );
    return allPossibleTimeTablesPerCourseCode.reduce(
      (accTimeTables, timeTables) => accTimeTables
          .map(
            (accTimeTable) => timeTables
                .map(
                  (timeTable) => accTimeTable.conflictsWith(timeTable)
                      ? null
                      : accTimeTable.mergeWith(timeTable),
                )
                .nonNulls,
          )
          .flattened,
    );
  }
}
