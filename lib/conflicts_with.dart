import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nu_sched_gen/models/schedule.dart';

@immutable
abstract class ConflictsWith<T> extends Equatable {
  Set<Schedule> get schedules;

  bool get containsConflicts => schedules.containsConflicts;
  bool get containsConflictsSlow => schedules.containsConflictsSlow;
  bool conflictsWith(T value) => {
    this,
    value as ConflictsWith<T>,
  }.map((a) => a.schedules).flattened.containsConflicts;
}
