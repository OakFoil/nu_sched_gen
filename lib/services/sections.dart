import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/services/repositories/slots.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sections.g.dart';

@Riverpod(keepAlive: true)
class Sections extends _$Sections {
  @override
  Future<Map<String, Set<Section>>> build() async {
    final slots = await ref.watch(slotsProvider.future);

    return Section.allSectionsPerCourseCode(slots);
  }
}
