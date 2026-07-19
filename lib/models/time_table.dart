import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/optimization.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/utils.dart';

part 'time_table.freezed.dart';

@freezed
sealed class TimeTable extends ConflictsWith<TimeTable> with _$TimeTable {
  @override
  get schedules => sections.map((section) => section.schedules).flattened;

  const TimeTable._();

  const factory TimeTable(Iterable<Section> sections) = TimeTableData;

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
  int get maxDayDurationInMinutes =>
      groupBy(schedules, (schedule) => schedule.day)
          .map(
            (day, schedules) => MapEntry(
              day,
              schedules.map((schedule) => schedule.end).max.toMinute -
                  schedules.map((schedule) => schedule.start).min.toMinute,
            ),
          )
          .values
          .max;

  TimeTable mergeWith(TimeTable timeTable) =>
      TimeTable(sections.followedBy(timeTable.sections));

  static Iterable<TimeTable> allPossibleTimeTables(
    Set<Set<Section>> avilableSectionsPerCourseCode,
  ) {
    if (avilableSectionsPerCourseCode.isEmpty ||
        avilableSectionsPerCourseCode.any(
          (courseCodeSections) => courseCodeSections.isEmpty,
        )) {
      return {};
    }

    final possibleTimeTablesPerCourseCode = avilableSectionsPerCourseCode.map(
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

extension IterableTimeTableUtils on Iterable<TimeTable> {
  Iterable<TimeTable> applyOptimizations(
    List<Optimization<dynamic>> optimizations,
  ) => optimizations.fold(
    this,
    (accOptimizedTimeTables, f) => f.apply(accOptimizedTimeTables),
  );
}
