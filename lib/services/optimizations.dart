import 'package:collection/collection.dart';
import 'package:nu_sched_gen/models/optimization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'optimizations.g.dart';

@Riverpod(keepAlive: true)
class Optimizations extends _$Optimizations {
  @override
  List<Optimization<dynamic>> build() {
    return [
      Optimization("Days", MinOrMax.min, (timeTable) => timeTable.days.length),
      Optimization(
        "Week Days Diff",
        MinOrMax.min,
        (timeTable) => timeTable.weekDaysDiff.sum,
      ),
      Optimization(
        "Days Durations Sum",
        MinOrMax.min,
        (timeTable) => timeTable.daysDurationsInMinutes.sum,
      ),
      Optimization(
        "Max Day Duration",
        MinOrMax.min,
        (timeTable) => timeTable.daysDurationsInMinutes.max,
      ),
      Optimization(
        "Max End Time",
        MinOrMax.min,
        (timeTable) => timeTable.maxDayEnd,
      ),
      Optimization(
        "Min Start Time",
        MinOrMax.max,
        (timeTable) => timeTable.minDayStart,
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
