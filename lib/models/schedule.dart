import 'package:collection/collection.dart';
import 'package:common_flutter/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/time_slot.dart';
import 'package:nu_sched_gen/utils.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

enum Building {
  tarekKhalil,
  main,
  online;

  @override
  String toString() => ["Tarek Khalil", "Main", "Onlilne"][index];
}

@Freezed(toJson: false)
sealed class Schedule extends ConflictsWith<Schedule>
    with _$Schedule
    implements Comparable<Schedule> {
  @override
  get timeSlots => {timeSlot};

  @override
  int compareTo(Schedule other) => timeSlot.compareTo(other.timeSlot);

  const Schedule._();

  const factory Schedule({
    required Building? building,
    required String? floorId,
    required String room,
    required TimeSlot timeSlot,
  }) = ScheduleData;

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    building: Schedule.bldgNameToBuilding(json['bldgName']),
    floorId: json['floorId'],
    room: json['roomId'],
    timeSlot: TimeSlot.fromJson(json),
  );

  static Building? bldgNameToBuilding(String bldgName) => switch (bldgName) {
    "" => null,
    "Online" => Building.online,
    _ => Building.values[int.parse(bldgName.last) - 1],
  };

  static final Map<String, int> _floorNameToFloor = {
    for (final (index, value) in ["B", "G", "F", "S", "R"].indexed)
      value: index - 1,
  };

  static final Map<int, String> _floorToFloorName = {
    for (final MapEntry(key: floorName, value: floor)
        in _floorNameToFloor.entries)
      floor: floorName,
  };

  int get duration => timeSlot.end.toMinute - timeSlot.start.toMinute;

  int? get floor {
    if (floorId != null && floorId!.isNotEmpty) {
      return _floorNameToFloor[floorId![0]]!;
    }
    if (room.isNotEmpty) {
      if (room == "Online") return null;
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
          building == Building.tarekKhalil && floor != null && floor! <= 0
      ? _floorToFloorName[floor]!
      : floor.toString();
}

extension IterableScheduleUtils on Iterable<Schedule> {
  Map<String, Schedule> get allRooms {
    final today = DateTime.now().weekday;
    final mockTime = TimeOfDay(hour: 23, minute: 59);
    final Set<String> seenRooms = {};

    return {
      for (final schedule in this)
        if (schedule.room.isNotEmpty &&
            schedule.timeSlot.day != today &&
            seenRooms.add(schedule.room))
          schedule.room: schedule.copyWith(
            timeSlot: schedule.timeSlot.copyWith(
              day: today,
              start: mockTime,
              end: mockTime,
            ),
          ),
    };
  }

  Map<Building?, Map<String, Map<String, List<Schedule>>>> get findStudyRooms {
    final date = DateTime.now(), time = TimeOfDay.fromDateTime(date);
    final schedulesToday = where(
      (schedule) =>
          schedule.room.isNotEmpty &&
          schedule.timeSlot.day == date.weekday &&
          !(schedule.timeSlot.end.compareTo(time) == -1),
    );
    final schedulesTodayRooms = schedulesToday.map(
      (scheduleToday) => scheduleToday.room,
    );
    final schedules = allRooms.values
        .where((schedule) => !schedulesTodayRooms.contains(schedule.room))
        .followedBy(schedulesToday)
        .sortedBy((schedule) => schedule.timeSlot.start)
        .reversed;
    final Map<Building?, Map<String, Map<String, List<Schedule>>>>
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
