import 'package:collection/collection.dart';
import 'package:common_flutter/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/utils.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

enum Building {
  tarekKhalil,
  main;

  @override
  String toString() => ["Tarek Khalil", "Main"][index];
}

@freezed
sealed class Schedule extends ConflictsWith<Schedule>
    with _$Schedule
    implements Comparable<Schedule> {
  @override
  Set<Schedule> get schedules => {this};

  @override
  bool conflictsWith(Schedule other) {
    final Schedule(day: day1, start: start1, end: end1) = this;
    final Schedule(day: day2, start: start2, end: end2) = other;

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
      orElse: () => 0,
    );
  }

  const Schedule._();

  const factory Schedule({
    @JsonKey(name: "bldgName", fromJson: Schedule.bldgNameToBuilding)
    required Building building,
    @JsonKey(name: "floorId") required String? floorId,
    @JsonKey(name: "roomId") required String room,
    @JsonKey(
      name: "scheduledStartTime",
      fromJson: Schedule
          .timeListToTimeOfDay, // have to add Schedule. so generated code also adds Schedule.
      includeToJson: false,
    )
    required TimeOfDay start,
    @JsonKey(
      name: "scheduledEndTime",
      fromJson: Schedule.timeListToTimeOfDay,
      includeToJson: false,
    )
    required TimeOfDay end,
    @JsonKey(name: "scheduledDays", fromJson: Schedule.daysListToDay)
    required int day,
  }) = ScheduleData;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  static Building bldgNameToBuilding(String bldgName) =>
      Building.values[int.parse(bldgName.last) - 1];

  static final Map<String, int> _floorNameToFloor = {
    for (final (index, value) in ["B", "G", "F", "S", "R"].indexed)
      value: index - 1,
  };

  static final Map<int, String> _floorToFloorName = {
    for (final MapEntry(key: floorName, value: floor)
        in _floorNameToFloor.entries)
      floor: floorName,
  };

  static TimeOfDay timeListToTimeOfDay(List<dynamic> value) {
    final [hour, minute, _] = value;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static int daysListToDay(List<dynamic> value) {
    var [a] = value;
    if (a == 0) a = 7; // Sunday

    return a;
  }

  int get duration => end.toMinute - start.toMinute;

  int get floor {
    if (floorId != null && floorId!.isNotEmpty) {
      return _floorNameToFloor[floorId![0]]!;
    }
    if (room.isNotEmpty) {
      if (RegExp(r'[A-Z]').hasMatch(room[0])) {
        return _floorNameToFloor[room[0]]!;
      }
      final firstDigit = double.tryParse(room);
      if (firstDigit != null) {
        return (firstDigit / 100).toInt() - 1;
      }
    }

    throw "Cannot Decode Floor";
  }

  String get floorName =>
      building == Building.main ||
          building == Building.tarekKhalil && floor <= 0
      ? _floorToFloorName[floor]!
      : floor.toString();
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

  Map<String, Schedule> get allRooms {
    final today = DateTime.now().weekday;
    final mockTime = TimeOfDay(hour: 23, minute: 59);
    final Set<String> seenRooms = {};

    return {
      for (final schedule in this)
        if (schedule.room.isNotEmpty &&
            schedule.day != today &&
            seenRooms.add(schedule.room))
          schedule.room: schedule.copyWith(
            day: today,
            start: mockTime,
            end: mockTime,
          ),
    };
  }

  Map<Building, Map<String?, Map<String, List<Schedule>>>> get findStudyRooms {
    final date = DateTime.now(), time = TimeOfDay.fromDateTime(date);
    final schedulesToday = where(
      (schedule) =>
          schedule.room.isNotEmpty &&
          schedule.day == date.weekday &&
          !(schedule.end.compareTo(time) == -1),
    ).sortedBy((schedule) => schedule.start).reversed;
    final schedules = schedulesToday.followedBy(
      allRooms.values.where(
        (schedule) =>
            !schedule.map((schedule) => schedule.room).contains(schedule.room),
      ),
    );
    final schedulesPerBuilding = schedules.groupListsBy(
      (schedule) => schedule.building,
    );
    final schedulesPerFloorPerBuilding = schedulesPerBuilding.map(
      (building, schedules) => MapEntry(
        building,
        schedules.groupListsBy((schedule) => schedule.floorName),
      ),
    );
    final schedulesPerRoomPerFloorPerBuilding = schedulesPerFloorPerBuilding
        .map(
          (building, schedulesPerFloor) => MapEntry(
            building,
            schedulesPerFloor.map(
              (floor, schedules) => MapEntry(
                floor,
                schedules.groupListsBy((schedule) => schedule.room),
              ),
            ),
          ),
        );

    return schedulesPerRoomPerFloorPerBuilding;
  }
}
