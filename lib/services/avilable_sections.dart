import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/services/registered_sections.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avilable_sections.g.dart';

@Riverpod(keepAlive: true)
Future<Map<String, Set<Section>>> avilableSections(Ref ref) async {
  final registeredSections = ref.watch(registeredSectionsProvider);
  final allSectionsPerCourseCode = await ref.watch(allSectionsProvider.future);

  return Section.availableSectionsPerCourseCode(
    allSectionsPerCourseCode,
    registeredSections,
  );
}
