import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'courses_cart.g.dart';

@Riverpod(keepAlive: true)
class CoursesCart extends _$CoursesCart {
  @override
  Set<String> build() => kReleaseMode
      ? {}
      : {"ECE211", "ECE231", "ECE251", "MTH214", "MTH215", "ENGL003"};

  void addCourse(String courseCode) {
    state = state.union({courseCode});
  }

  void removeCourse(String courseCode) {
    state = state.where((a) => a != courseCode).toSet();
  }

  void clearCourses() {
    ref.invalidateSelf();
  }
}
