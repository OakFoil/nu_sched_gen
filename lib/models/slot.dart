import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';

part 'slot.g.dart';

// ignore: constant_identifier_names
enum SlotType { Lecture, Tutorial, Lab, Practical, Project, Thesis }

@JsonSerializable()
@immutable
class Slot extends Equatable implements ConflictsWith<Slot> {
  @JsonKey(name: "eventSubType")
  final SlotType type;
  @JsonKey(name: "eventId")
  final String courseCode;
  @JsonKey(fromJson: instructorsToListOfString)
  final Set<String> instructors;
  final Set<Schedule>? schedules;
  final int seatsLeft;
  @JsonKey(name: "section")
  final String sectionNumberAndLetter;
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

  @override
  List<Object?> get props => [
    type,
    courseCode,
    instructors,
    schedules,
    seatsLeft,
    sectionNumberAndLetter,
  ];

  const Slot({
    required this.type,
    required this.courseCode,
    required this.instructors,
    required this.schedules,
    required this.seatsLeft,
    required this.sectionNumberAndLetter,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
  Map<String, dynamic> toJson() => _$SlotToJson(this);

  Iterable<Slot> matchingSlots(Iterable<Slot> slots) => slots.where(
    (slot) =>
        slot.courseCode == courseCode && slot.sectionNumber == sectionNumber,
  );

  @override
  bool conflictsWith(Slot slot) =>
      [schedules, slot.schedules].nonNulls.flattened.containsConflicts;

  static Set<String> instructorsToListOfString(List<dynamic>? value) =>
      Set.from(value?.map((a) => a["fullName"]).toSet() ?? {});
}
