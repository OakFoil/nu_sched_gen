import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'courses_cart.g.dart';

@Riverpod(keepAlive: true)
class CoursesCart extends _$CoursesCart {
  @override
  List<String> build() => [];
  void addCourse(String courseCode) {
    state = state.followedBy({courseCode}).toList();
  }

  void removeCourse(String courseCode) {
    state = state.where((a) => a != courseCode).toList();
  }

  void clearCourses() {
    ref.invalidateSelf();
  }

  bool isInCart(String courseCode) => state.contains(courseCode);
}
