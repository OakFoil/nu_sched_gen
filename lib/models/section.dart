import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/models/slot.dart';

@immutable
class Section extends Equatable implements ConflictsWith<Section> {
  final Slot lecture;
  final Slot? tutorial, lab;
  Set<Slot> get slots => [lecture, tutorial, lab].nonNulls.toSet();
  String get courseCode => lecture.courseCode;
  int get sectionNumber => lecture.sectionNumber;
  Set<Schedule> get schedules => [
    lecture.schedules,
    tutorial?.schedules,
    lab?.schedules,
  ].nonNulls.flattened.toSet();
  int get seatsLeft =>
      [lecture.seatsLeft, tutorial?.seatsLeft, lab?.seatsLeft].nonNulls.min;

  @override
  List<Object?> get props => [lecture, tutorial, lab];

  const Section({required this.lecture, this.tutorial, this.lab});

  @override
  bool conflictsWith(Section section) =>
      schedules.followedBy(section.schedules).containsConflicts;

  static Iterable<Section> allPossibleSections(Iterable<Slot> slots) {
    final lectures = slots.where((a) => a.type == SlotType.Lecture);
    return lectures
        .map((Slot lecture) {
          final matchingSlots = lecture.matchingSlots(slots);
          final tutorials = matchingSlots.where(
            (a) => a.type == SlotType.Tutorial,
          );
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
                    (lab) =>
                        Section(lecture: lecture, tutorial: tutorial, lab: lab),
                  ),
                )
                .flattened;
          }
        })
        .flattened
        .where((section) => !(section.schedules.containsConflicts));
  }
}
