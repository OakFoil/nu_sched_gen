import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/slot.dart';

part 'section.freezed.dart';

@freezed
sealed class Section extends ConflictsWith<Section> with _$Section {
  @override
  get schedules => slots.expand((slot) => slot.schedules);

  const Section._();

  const factory Section({required Slot lecture, Slot? tutorial, Slot? lab}) =
      SectionData;

  Iterable<Slot> get slots => {lecture, tutorial, lab}.nonNulls;
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
    final tutorials = matchingSlots.where(
      (slot) => slot.type == SlotType.Tutorial,
    );
    final labs = matchingSlots.where((slot) => slot.type == SlotType.Lab);

    return switch ((tutorials.isEmpty, labs.isEmpty)) {
      (true, true) => {Section(lecture: lecture)},
      (false, true) => tutorials.map(
        (tutortial) => Section(lecture: lecture, tutorial: tutortial),
      ),
      (true, false) => labs.map((lab) => Section(lecture: lecture, lab: lab)),
      (false, false) => tutorials.expand(
        (tutorial) => labs.map(
          (lab) => Section(lecture: lecture, tutorial: tutorial, lab: lab),
        ),
      ),
    };
  }

  static Set<Section> allSections(Set<Slot> slots) {
    final lectures = slots.where((a) => a.type == SlotType.Lecture);

    return lectures
        .expand((lecture) => allPossibleSectionsForLecture(lecture, slots))
        .whereNot((section) => section.containsConflicts)
        .toSet();
  }

  static Map<String, Set<Section>> allSectionsPerCourseCode(Set<Slot> slots) =>
      allSections(slots).groupSetsBy((section) => section.courseCode);

  static Map<String, Set<Section>> availableSectionsPerCourseCode(
    Map<String, Set<Section>> allSections, [
    Set<Section> registeredSections = const {},
  ]) {
    final avilableSections = Map.of(allSections);
    avilableSections.updateAll(
      (courseCode, sections) => sections
          .where((section) => section.seatsLeft > 0)
          .followedBy(
            registeredSections.where(
              (registeredSection) => registeredSection.courseCode == courseCode,
            ),
          )
          .toSet(),
    );
    avilableSections.removeWhere((courseCode, sections) => sections.isEmpty);

    return avilableSections;
  }
}
