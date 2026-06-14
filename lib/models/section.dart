import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/models/slot.dart';

@immutable
class Section extends ConflictsWith<Section> {
  final Slot lecture;
  final Slot? tutorial, lab;

  @override
  Set<Schedule> get schedules =>
      slots.map((slot) => slot.schedules).flattened.toSet();
  @override
  List<Object?> get props => [lecture, tutorial, lab];

  Section({required this.lecture, this.tutorial, this.lab});

  Set<Slot> get slots => {lecture, tutorial, lab}.nonNulls.toSet();
  String get courseCode => lecture.courseCode;
  int get sectionNumber => lecture.sectionNumber;
  int get seatsLeft =>
      [lecture.seatsLeft, tutorial?.seatsLeft, lab?.seatsLeft].nonNulls.min;

  static Iterable<Section> allPossibleSectionsForLecture(
    Slot lecture,
    Set<Slot> slots,
  ) {
    assert(lecture.type == SlotType.Lecture);

    final matchingSlots = lecture.matchingSlots(slots);
    final tutorials = matchingSlots.where((a) => a.type == SlotType.Tutorial);
    final labs = matchingSlots.where((a) => a.type == SlotType.Lab);

    if (tutorials.isEmpty && labs.isEmpty) {
      return {Section(lecture: lecture)};
    } else if (tutorials.isNotEmpty && labs.isEmpty) {
      return tutorials.map(
        (tutotial) => Section(lecture: lecture, tutorial: tutotial),
      );
    } else if (tutorials.isEmpty && labs.isNotEmpty) {
      return labs.map((lab) => Section(lecture: lecture, lab: lab));
    } else {
      return tutorials
          .map(
            (tutorial) => labs.map(
              (lab) => Section(lecture: lecture, tutorial: tutorial, lab: lab),
            ),
          )
          .flattened;
    }
  }

  static Set<Section> allSections(Set<Slot> slots) {
    final lectures = slots.where((a) => a.type == SlotType.Lecture);

    return lectures
        .map((lecture) => allPossibleSectionsForLecture(lecture, slots))
        .flattened
        .whereNot((section) => section.containsConflicts)
        .toSet();
  }

  static Map<String, Set<Section>> allSectionsPerCourseCode(Set<Slot> slots) {
    final sections = allSections(slots);

    return sections.groupSetsBy((section) => section.courseCode);
  }
}
