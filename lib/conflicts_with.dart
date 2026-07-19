import 'package:flutter/foundation.dart';
import 'package:nu_sched_gen/models/schedule.dart';

@immutable
abstract class ConflictsWith<T> {
  const ConflictsWith();

  Iterable<Schedule> get schedules;

  bool conflictsWith(T other) => schedules
      .followedBy((other as ConflictsWith<T>).schedules)
      .containsConflicts;
  @nonVirtual
  bool get containsConflicts => schedules.containsConflicts;
  @nonVirtual
  bool get containsConflictsSlow => schedules.containsConflictsSlow;
}
