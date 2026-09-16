import 'package:nu_sched_gen/models/optimization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'optimizations.g.dart';

@Riverpod(keepAlive: true)
class Optimizations extends _$Optimizations {
  @override
  List<Optimization<dynamic>> build() {
    return [
      Optimization.days,
      Optimization.weekDaysDiff,
      Optimization.daysDurationsSum,
      Optimization.maxDayDuration,
      Optimization.maxEndTime,
      Optimization.minStartTime,
    ];
  }

  void moveBefore(int movedIndex, int toAddBeforeIndex) {
    final newState = [...state];

    final moved = newState.removeAt(movedIndex);
    newState.insert(toAddBeforeIndex, moved);

    state = newState;
  }
}
