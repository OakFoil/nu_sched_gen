import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/section.dart';

@immutable
class TimeTable extends Equatable implements ConflictsWith<TimeTable> {
  final Set<Section> sections;

  @override
  List<Object?> get props => [sections];

  const TimeTable(this.sections);

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.union(timeTable.sections));

  @override
  bool conflictsWith(value) => sections.containsConflicts;

  static Iterable<TimeTable> allPossibleTimeTables({
    required Iterable<String> courseCodes,
    required Iterable<Section> allSections,
  }) {
    final allPossibleSectionsPerCourseCode = courseCodes.map(
      (courseCode) =>
          allSections.where((section) => section.courseCode == courseCode),
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
