import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/repositories/slots.dart';
import 'package:nu_sched_gen/services/time_tables.dart';
import 'package:nu_sched_gen/search.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'sched_gen.g.dart';

@TypedGoRoute<SchedGenRoute>(path: "/generate-schedule")
class SchedGenRoute extends GoRouteData with _$SchedGenRoute {
  const SchedGenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SchedGenScreen();
}

class SchedGenScreen extends ConsumerWidget {
  const SchedGenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesCart = ref.watch(coursesCartProvider);
    return AsyncValueBuilder(
      asyncValue: ref.watch(timeTablesProvider),
      showData: (timeTables) => ListView(
        children:
            [DisplayText("SchedGenScreen"), CourseSearch()] +
            coursesCart
                .map(
                  (courseCode) =>
                      CoursePreview(courseCode: courseCode, onTap: () {}),
                )
                .toList() +
            [
              SizedBox(
                height: 500,
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: ListView.builder(
                    prototypeItem: TimeTablePreview(timeTables.first),
                    itemCount: timeTables.length,
                    itemBuilder: (context, index) => timeTables
                        .map((timeTable) => TimeTablePreview(timeTable))
                        .elementAtOrNull(index),
                  ),
                ),
              ),
            ],
      ),
    );
  }
}

class CourseSearch extends ConsumerStatefulWidget {
  const CourseSearch({super.key});

  @override
  ConsumerState<CourseSearch> createState() => _CourseSearchState();
}

class _CourseSearchState extends ConsumerState<CourseSearch> {
  final SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) {
    final coursesCart = ref.watch(coursesCartProvider.notifier);
    return Center(
      child: AsyncValueBuilder(
        asyncValue: ref.watch(slotsProvider),
        showData: (slots) => SearchAnchor.bar(
          barHintText: 'Search courses',
          searchController: controller,
          suggestionsBuilder: (context, controller) => slots
              .map((slot) => slot.courseCode)
              .toSet()
              .searchFor(controller.text)
              .map(
                (courseCode) => CoursePreview(
                  courseCode: courseCode,
                  onTap: () {
                    controller.closeView(controller.text);
                    coursesCart.addCourse(courseCode);
                  },
                ),
              )
              .take(10),
        ),
      ),
    );
  }
}

class TimeTablePreview extends StatelessWidget {
  final TimeTable timeTable;

  const TimeTablePreview(this.timeTable, {super.key});

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: Wrap(
      children: timeTable.sections
          .map((section) => IntrinsicWidth(child: SectionPreview(section)))
          .toList(),
    ),
  );
}

class CoursePreview extends ConsumerWidget {
  final String courseCode;
  final void Function() onTap;

  const CoursePreview({
    super.key,
    required this.courseCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(coursesCartProvider);
    final coursesCart = ref.watch(coursesCartProvider.notifier);
    return ListTile(
      title: TitleText(courseCode),
      onTap: onTap,
      trailing: coursesCart.isInCart(courseCode)
          ? IconButton(
              onPressed: () {
                coursesCart.removeCourse(courseCode);
              },
              icon: Icon(Icons.highlight_remove),
            )
          : SizedBox.shrink(),
    );
  }
}

class SectionPreview extends StatelessWidget {
  final Section section;
  const SectionPreview(this.section, {super.key});

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: TitleText(
            "${section.courseCode}\n${section.schedules.map((schedule) => "${schedule.day} - ${schedule.start.format(context)} - ${schedule.end.format(context)} - ${schedule.room}\n").join()}",
          ),
        ),
        Divider(),
        Card.filled(
          child: TitleText(
            "${section.sectionNumber} - ${section.tutorial?.sectionLetter} - ${section.lab?.sectionLetter}",
          ),
        ),
      ],
    ),
  );
}
