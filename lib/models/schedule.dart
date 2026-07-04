import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
@immutable
class Schedule extends Equatable implements Comparable<Schedule> {
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

  @override
  int compareTo(Schedule other) {
    /* Days start with Monday = 1 and end with Sunday = 7
    Make them start with Saturday = 0 and end with Friday = 6 */
    final dayComparison = ((day + 1) % 7).compareTo((other.day + 1) % 7);
    final startComparison = start.compareTo(other.start);
    final endComparison = end.compareTo(other.end);

    final comparisons = [dayComparison, startComparison, endComparison];

    return comparisons.firstWhere(
      (comparison) => comparison != 0,
      orElse: () => comparisons.last,
    );
  }
}

extension IterableScheduleUtils on Iterable<Schedule> {
  bool get containsConflicts {
    final schedules = [...this];

    schedules.sort((scheduleA, scheduleB) {
      final dayComparison = scheduleA.day.compareTo(scheduleB.day);
      final startComparison = scheduleA.start.compareTo(scheduleB.start);

      return dayComparison != 0 ? dayComparison : startComparison;
    });

    for (var i = 0; i < schedules.length - 1; i++) {
      final current = schedules[i];
      final next = schedules[i + 1];

      if (current.day == next.day && current.conflictsWith(next)) return true;
    }

    return false;
  }

  bool get containsConflictsSlow =>
      any((a) => any((b) => a != b && a.conflictsWith(b)));
}
