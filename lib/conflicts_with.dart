import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nu_sched_gen/models/schedule.dart';

@immutable
abstract class ConflictsWith<T> extends Equatable {
  const ConflictsWith();

  Iterable<Schedule> get schedules;

  bool get containsConflicts => schedules.containsConflicts;
  bool get containsConflictsSlow => schedules.containsConflictsSlow;
  bool conflictsWith(T value) => schedules
      .followedBy((value as ConflictsWith<T>).schedules)
      .containsConflicts;
}
