import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/optimizations.dart';
import 'package:nu_sched_gen/services/time_tables_without_optimizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_tables.g.dart';

@Riverpod(keepAlive: true)
Future<Set<TimeTable>> timeTables(Ref ref) async {
  final timeTables = await ref.watch(
    timeTablesWithoutOptimizationsProvider.future,
  );

  final optimizations = ref.watch(optimizationsProvider);

  return timeTables.applyOptimizations(optimizations).toSet();
}
