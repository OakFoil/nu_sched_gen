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

@Freezed(toJson: false)
sealed class Schedule extends ConflictsWith<Schedule>
    with _$Schedule
    implements Comparable<Schedule> {
  @override
  Set<Schedule> get schedules => {this};

  @override
  bool conflictsWith(Schedule other) =>
      day == other.day &&
      start.compareTo(other.end) < 0 &&
      other.start.compareTo(end) < 0;

  @override
  int compareTo(Schedule other) {
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

  const Schedule._();

  const factory Schedule({
    @JsonKey(name: "bldgName", fromJson: Schedule.bldgNameToBuilding)
    required Building building,
    @JsonKey(name: "floorId") required String? floorId,
    @JsonKey(name: "roomId") required String room,
    @JsonKey(
      name: "scheduledStartTime",
      fromJson:
          Schedule // have to add Schedule. so generated code also adds Schedule.
              .timeListToTimeOfDay,
    )
    required TimeOfDay start,
    @JsonKey(name: "scheduledEndTime", fromJson: Schedule.timeListToTimeOfDay)
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
    var [day] = value;
    if (day == 0) day = 7; // Sunday

    return day;
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
      if (double.tryParse(room) case final number?) {
        return (number / 100).toInt() - 1;
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

  Map<Building, Map<String, Map<String, List<Schedule>>>> get findStudyRooms {
    final date = DateTime.now(), time = TimeOfDay.fromDateTime(date);
    final schedulesToday = where(
      (schedule) =>
          schedule.room.isNotEmpty &&
          schedule.day == date.weekday &&
          !(schedule.end.compareTo(time) == -1),
    );
    final schedulesTodayRooms = schedulesToday.map(
      (scheduleToday) => scheduleToday.room,
    );
    final schedules = allRooms.values
        .where((schedule) => !schedulesTodayRooms.contains(schedule.room))
        .followedBy(schedulesToday)
        .sortedBy((schedule) => schedule.start)
        .reversed;
    final Map<Building, Map<String, Map<String, List<Schedule>>>>
    schedulesPerRoomPerFloorPerBuilding = {};

    for (final schedule in schedules) {
      schedulesPerRoomPerFloorPerBuilding
          .putIfAbsent(schedule.building, () => {})
          .putIfAbsent(schedule.floorName, () => {})
          .putIfAbsent(schedule.room, () => [])
          .add(schedule);
    }

    return schedulesPerRoomPerFloorPerBuilding;
  }
}
