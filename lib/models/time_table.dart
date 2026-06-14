import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/models/section.dart';

@immutable
class TimeTable extends ConflictsWith<TimeTable> {
  final Set<Section> sections;

  @override
  Set<Schedule> get schedules =>
      sections.map((section) => section.schedules).flattened.toSet();
  @override
  List<Object?> get props => [sections];

  TimeTable(this.sections);

  Set<int> get days => schedules.map((schedule) => schedule.day).toSet();
  Set<int> get weekDaysDiff {
    final List<int> weekDays = {
      for (var i = 1; i <= 7; i++) i,
    }.difference(days).toList();
    weekDays.sort();

    return {
      for (var i = 0; i < weekDays.length - 1; i++)
        weekDays[i + 1] - weekDays[i],
    };
  }

  TimeOfDay get maxDayEnd => schedules.map((schedule) => schedule.end).max;
  TimeOfDay get minDayStart => schedules.map((schedule) => schedule.start).min;

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.union(timeTable.sections));

  static Set<TimeTable> allPossibleTimeTables({
    required Map<String, Set<Section>> sectionsPerCourseCode,
    Set<Section> registeredSections = const {},
  }) {
    final Map<String, Set<Section>> openSectionsPerCourseCode =
        sectionsPerCourseCode.map(
          (courseCode, sections) => MapEntry(
            courseCode,
            sections.where((section) => section.seatsLeft > 0).toSet(),
          ),
        );

    if (openSectionsPerCourseCode.isEmpty ||
        openSectionsPerCourseCode.values.any(
          (courseCodeSections) => courseCodeSections.isEmpty,
        )) {
      return {};
    }

    final Map<String, Set<TimeTable>> possibleTimeTablesPerCourseCode =
        openSectionsPerCourseCode.map(
          (courseCode, sections) => MapEntry(
            courseCode,
            sections.map((section) => TimeTable({section})).toSet(),
          ),
        );

    final Set<TimeTable> allPossibleTimeTables = possibleTimeTablesPerCourseCode
        .values
        .reduce(
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
        (timeTable) => !timeTable.containsConflictsSlow,
      ),
    );

    return allPossibleTimeTables;
  }
}
