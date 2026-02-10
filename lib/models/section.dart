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
  Set<Slot> get slots => [lecture, tutorial, lab].nonNulls.toSet();
  String get courseCode => lecture.courseCode;
  int get sectionNumber => lecture.sectionNumber;
  @override
  Set<Schedule> get schedules => {
    lecture.schedules,
    tutorial?.schedules,
    lab?.schedules,
  }.nonNulls.flattened.toSet();
  int get seatsLeft =>
      [lecture.seatsLeft, tutorial?.seatsLeft, lab?.seatsLeft].nonNulls.min;

  @override
  List<Object?> get props => [lecture, tutorial, lab];

  Section({required this.lecture, this.tutorial, this.lab});

  static Set<Section> allPossibleSections(Set<Slot> slots) {
    final lectures = slots.where((a) => a.type == SlotType.Lecture);
    return lectures
        .map((lecture) => slots.allPossibleSectionsForLecture(lecture))
        .flattened
        .where((section) => !(section.schedules.containsConflicts))
        .toSet();
  }
}
