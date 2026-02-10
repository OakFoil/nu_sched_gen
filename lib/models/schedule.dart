import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
@immutable
class Schedule extends Equatable {
  @JsonKey(name: "roomId")
  final String room;
  @JsonKey(
    name: "scheduledStartTime",
    fromJson: timeListToTimeOfDay,
    includeToJson: false,
  )
  final TimeOfDay start;
  @JsonKey(
    name: "scheduledEndTime",
    fromJson: timeListToTimeOfDay,
    includeToJson: false,
  )
  final TimeOfDay end;
  @JsonKey(name: "scheduledDays", fromJson: daysListToDay)
  final int day;
  Set<Schedule> get schedules => {this};

  @override
  List<Object?> get props => [room, start, end, day];

  const Schedule({
    required this.room,
    required this.start,
    required this.end,
    required this.day,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  static TimeOfDay timeListToTimeOfDay(List<dynamic> value) {
    final [hour, minute, _] = value;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static int daysListToDay(List<dynamic> value) {
    var [a] = value;
    if (a == 0) a = 7; // Sunday
    return a;
  }

  bool conflictsWith(Schedule schedule) {
    final Schedule(day: day1, start: start1, end: end1) = this;
    final Schedule(day: day2, start: start2, end: end2) = schedule;
    if (day1 != day2) return false;
    if (start1.compareTo(end2) >= 0) return false;
    if (start2.compareTo(end1) >= 0) return false;
    return true;
  }
}

extension IterableScheduleUtils on Iterable<Schedule> {
  bool get containsConflicts {
    final Map<int, Set<Schedule>> groupedSchedules = groupSetsBy(
      (schedule) => schedule.day,
    );
    final Iterable<List<Schedule>> groupedAndSortedSchedules = groupedSchedules
        .values
        .map((schedules) => schedules.sortedBy((schedule) => schedule.start));
    return groupedAndSortedSchedules
        .map((schedulesWithSameDay) {
          for (var i = 0; i < schedulesWithSameDay.length - 1; i++) {
            if (schedulesWithSameDay[i].conflictsWith(
              schedulesWithSameDay[i + 1],
            )) {
              return true;
            }
          }
          return false;
        })
        .any((a) => a);
  }

  bool get containsConflictsSlow =>
      any((a) => any((b) => a != b && a.conflictsWith(b)));
}
