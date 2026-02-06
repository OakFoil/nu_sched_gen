import 'package:equatable/equatable.dart';

mixin ConflictsWith<T> on Equatable {
  bool conflictsWith(T value);
}

extension IterableConflictsWithUtils<T extends ConflictsWith> on Iterable<T> {
  bool get containsConflicts =>
      any((a) => any((b) => a != b && a.conflictsWith(b)));
  Iterable<T> combineIfItDoesntConflict(T value) {
    final combinationResult = followedBy({value});
    return combinationResult.containsConflicts ? this : combinationResult;
  }

  Iterable<T> combineWhileRemovingConflictingItems(Iterable<T> values) =>
      values.fold(this, (acc, value) => acc.combineIfItDoesntConflict(value));
}
