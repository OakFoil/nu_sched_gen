import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'courses_cart.g.dart';

@Riverpod(keepAlive: true)
class CoursesCart extends _$CoursesCart {
  @override
  Set<String> build() => {};
  void addCourse(String courseCode) {
    state = state.union({
      courseCode,
    }); // Use state = instead of state.add() to make sure state is updated
  }

  void removeCourse(String courseCode) {
    state = state
        .where((a) => a != courseCode)
        .toSet(); // Use state = instead of state.remove() to make sure state is updated
  }

  void clearCourses() {
    ref.invalidateSelf();
  }
}
