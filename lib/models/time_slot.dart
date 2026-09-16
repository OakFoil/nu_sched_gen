import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/utils.dart';

part 'time_slot.freezed.dart';
part 'time_slot.g.dart';

@Freezed(toJson: false)
sealed class TimeSlot extends ConflictsWith<TimeSlot>
    with _$TimeSlot
    implements Comparable<TimeSlot> {
  @override
  Set<TimeSlot> get timeSlots => {this};
  @override
  bool conflictsWith(TimeSlot other) =>
      day == other.day &&
      start.compareTo(other.end) < 0 &&
      other.start.compareTo(end) < 0;

  @override
  int compareTo(TimeSlot other) {
    /* Days start with Monday = 1 and end with Sunday = 7
    Make them start with Saturday = 0 and end with Friday = 6 */
    final dayComparison = ((day + 1) % 7).compareTo((other.day + 1) % 7);
    final startComparison = start.compareTo(other.start);
    final endComparison = end.compareTo(other.end);

    return [
      dayComparison,
      startComparison,
      endComparison,
    ].firstWhere((comparison) => comparison != 0, orElse: () => 0);
  }

  const TimeSlot._();

  const factory TimeSlot({
    @JsonKey(
      name: "scheduledStartTime",
      fromJson:
          TimeSlot // have to add TimeSlot. so generated code also adds Schedule.
              .timeListToTimeOfDay,
    )
    required TimeOfDay start,
    @JsonKey(name: "scheduledEndTime", fromJson: TimeSlot.timeListToTimeOfDay)
    required TimeOfDay end,
    @JsonKey(name: "scheduledDays", fromJson: TimeSlot.daysListToDay)
    required int day,
  }) = TimeSlotData;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  static TimeOfDay timeListToTimeOfDay(List<dynamic> value) {
    final [hour, minute, _] = value;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static int daysListToDay(List<dynamic> value) {
    var [day] = value;
    if (day == 0) day = 7; // Sunday

    return day;
  }

  int get duration => end.toMinute - start.toMinute;
}

extension IterableTimeSlotUtils on Iterable<TimeSlot> {
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
