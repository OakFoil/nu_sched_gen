import 'package:flutter/foundation.dart';
import 'package:nu_sched_gen/models/time_slot.dart';

@immutable
abstract class ConflictsWith<T> {
  const ConflictsWith();

  Iterable<TimeSlot> get timeSlots;

  bool conflictsWith(T other) => timeSlots
      .followedBy((other as ConflictsWith<T>).timeSlots)
      .containsConflicts;
  @nonVirtual
  bool get containsConflicts => timeSlots.containsConflicts;
  @nonVirtual
  bool get containsConflictsSlow => timeSlots.containsConflictsSlow;
}

extension IterableConflictsWithUtils<T extends ConflictsWith<T>>
    on Iterable<T> {
  bool get containsConflicts => expand((a) => a.timeSlots).containsConflicts;

  bool get containsConflictsSlow =>
      expand((a) => a.timeSlots).containsConflictsSlow;
}
