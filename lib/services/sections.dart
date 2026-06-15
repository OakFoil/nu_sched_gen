import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sections.g.dart';

@Riverpod(keepAlive: true)
class Sections extends _$Sections {
  @override
  Future<Map<String, Set<Section>>> build() async {
    final coursesCart = ref.watch(coursesCartProvider);
    final allSectionsPerCourseCode = await ref.watch(
      allSectionsProvider.future,
    );
    final Map<String, Set<Section>> sectionsPerCourseCode = Map.from(
      allSectionsPerCourseCode,
    );
    sectionsPerCourseCode.removeWhere(
      (courseCode, sections) => !coursesCart.contains(courseCode),
    );

    return sectionsPerCourseCode;
  }
}
