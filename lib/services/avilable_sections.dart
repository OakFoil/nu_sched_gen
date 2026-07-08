import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/services/registered_sections.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'avilable_sections.g.dart';

@Riverpod(keepAlive: true)
class AvilableSections extends _$AvilableSections {
  @override
  Future<Map<String, Set<Section>>> build() async {
    final registeredSections = ref.watch(registeredSectionsProvider);
    final allSectionsPerCourseCode = await ref.watch(
      allSectionsProvider.future,
    );
    final avilableSections = Map.of(allSectionsPerCourseCode);
    avilableSections.updateAll(
      (courseCode, sections) => sections
          .where((section) => section.seatsLeft > 0)
          .followedBy(
            registeredSections.where(
              (registeredSection) => registeredSection.courseCode == courseCode,
            ),
          )
          .toSet(),
    );
    avilableSections.removeWhere((courseCode, sections) => sections.isEmpty);

    return avilableSections;
  }
}
