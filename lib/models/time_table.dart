import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/section.dart';

@immutable
class TimeTable extends ConflictsWith<TimeTable> {
  final Iterable<Section> sections;

  @override
  get schedules => sections.map((section) => section.schedules).flattened;
  @override
  List<Object?> get props => [sections];

  const TimeTable(this.sections);

  Set<int> get days => schedules.map((schedule) => schedule.day).toSet();
  Set<int> get weekDaysDiff {
    final List<int> weekDays = {
      for (var i = 1; i <= 7; i++) i,
    }.difference(days).toList()..sort();

    return {
      for (var i = 0; i < weekDays.length - 1; i++)
        weekDays[i + 1] - weekDays[i],
    };
  }

  TimeOfDay get maxDayEnd => schedules.map((schedule) => schedule.end).max;
  TimeOfDay get minDayStart => schedules.map((schedule) => schedule.start).min;

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.followedBy(timeTable.sections));

  static Iterable<TimeTable> allPossibleTimeTables({
    required Map<String, Set<Section>> sectionsPerCourseCode,
    Set<Section> registeredSections = const {},
  }) {
    final openSectionsPerCourseCode = sectionsPerCourseCode
        .map(
          (courseCode, courseCodeSections) => MapEntry(
            courseCode,
            courseCodeSections
                .where((section) => section.seatsLeft > 0)
                .followedBy(
                  registeredSections.where(
                    (registeredSection) =>
                        registeredSection.courseCode == courseCode,
                  ),
                ),
          ),
        )
        .values;

    if (openSectionsPerCourseCode.isEmpty ||
        openSectionsPerCourseCode.any(
          (courseCodeSections) => courseCodeSections.isEmpty,
        )) {
      return {};
    }

    final possibleTimeTablesPerCourseCode = openSectionsPerCourseCode.map(
      (courseCodeSections) =>
          courseCodeSections.map((section) => TimeTable({section})),
    );

    final allPossibleTimeTables = possibleTimeTablesPerCourseCode.reduce(
      (accTimeTables, timeTables) => accTimeTables
          .map(
            (accTimeTable) => timeTables
                .whereNot((timeTable) => accTimeTable.conflictsWith(timeTable))
                .map((timeTable) => accTimeTable.mergeWith(timeTable)),
          )
          .flattened,
    );

    assert(
      allPossibleTimeTables.every(
        (timeTable) => !timeTable.containsConflictsSlow,
      ),
    );

    return allPossibleTimeTables;
  }
}
