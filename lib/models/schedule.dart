import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';

part 'schedule.g.dart';

@JsonSerializable()
@immutable
class Schedule extends Equatable implements ConflictsWith<Schedule> {
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
    final [a] = value;
    return a;
  }

  @override
  bool conflictsWith(Schedule schedule) {
    final Schedule(day: day1, start: start1, end: end1) = this;
    final Schedule(day: day2, start: start2, end: end2) = schedule;
    if (day1 != day2) return false;
    if (start1.compareTo(end2) >= 0) return false;
    if (start2.compareTo(end1) >= 0) return false;
    return true;
  }
}
