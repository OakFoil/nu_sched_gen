import 'package:flutter/material.dart';
import 'package:nu_sched_gen/models/constraints.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'constraints.g.dart';

@Riverpod(keepAlive: true)
class Constraints extends _$Constraints {
  @override
  Constraint build() => Constraint();

  void changeDayStart(TimeOfDay dayStart) {
    state.dayStart = dayStart;
  }
}
