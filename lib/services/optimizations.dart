import 'package:collection/collection.dart';
import 'package:nu_sched_gen/models/optimization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'optimizations.g.dart';

@Riverpod(keepAlive: true)
class Optimizations extends _$Optimizations {
  @override
  List<Optimization<dynamic>> build() {
    return [
      Optimization("Days", (a) => a.min, (timeTable) => timeTable.days.length),
      Optimization(
        "Week Days Diff",
        (a) => a.min,
        (timeTable) => timeTable.weekDaysDiff.sum,
      ),
      Optimization(
        "Max End Time",
        (a) => a.min,
        (timeTable) => timeTable.maxDayEnd,
      ),
      Optimization(
        "Max Day Duration",
        (a) => a.min,
        (timeTable) => timeTable.maxDayDurationInMinutes,
      ),
    ];
  }

  void moveBefore(int movedIndex, int toAddBeforeIndex) {
    final newState = [...state];

    final moved = newState.removeAt(movedIndex);
    newState.insert(toAddBeforeIndex, moved);

    state = newState;
  }
}
