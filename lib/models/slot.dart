import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';

part 'slot.freezed.dart';
part 'slot.g.dart';

// ignore: constant_identifier_names
enum SlotType { Lecture, Tutorial, Lab, Practical, Project, Thesis }

@Freezed(toJson: false)
sealed class Slot extends ConflictsWith<Slot> with _$Slot {
  const Slot._();

  const factory Slot({
    @JsonKey(name: "eventSubType") required SlotType type,
    @JsonKey(name: "eventId") required String courseCode,
    @JsonKey(
      fromJson:
          Slot // have to add Slot. so generated code also adds Slot.
              .instructorsToListOfString,
    )
    required Set<String> instructors,
    @JsonKey(fromJson: Slot.nullSchedulesToEmptySchedules)
    required Set<Schedule> schedules,
    required int seatsLeft,
    @JsonKey(name: "section") required String sectionNumberAndLetter,
  }) = SlotData;

  int get sectionNumber => int.parse(
    sectionNumberAndLetter
        .split('')
        .takeWhile((a) => int.tryParse(a) != null)
        .join(),
  );
  String get sectionLetter => sectionNumberAndLetter
      .split('')
      .skipWhile((a) => int.tryParse(a) != null)
      .join();

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  Set<Slot> matchingSlots(Set<Slot> slots) => slots
      .where(
        (slot) =>
            slot.courseCode == courseCode &&
            slot.sectionNumber == sectionNumber,
      )
      .toSet();

  static Set<String> instructorsToListOfString(List<dynamic>? value) =>
      Set.from(value?.map((a) => a["fullName"]).toSet() ?? {});
  static Set<Schedule> nullSchedulesToEmptySchedules(List<dynamic>? values) =>
      values?.map((value) => Schedule.fromJson(value)).toSet() ?? {};
}
