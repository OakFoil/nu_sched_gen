import 'package:nu_sched_gen/models/section.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registered_sections.g.dart';

@Riverpod(keepAlive: true)
class RegisteredSections extends _$RegisteredSections {
  @override
  Set<Section> build() => {};

  void addSection(Section section) {
    state = {...state, section};
  }
}
