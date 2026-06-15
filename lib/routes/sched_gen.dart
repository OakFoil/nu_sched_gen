import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
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
import 'package:nu_sched_gen/utils.dart';

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
      showData: (timeTables) {
        final orderedTimeTables = timeTables.toList();

        return ListView(
          children:
              [
                Center(child: DisplayText("Generate Schedule")),
                CourseSearch(),
              ] +
              coursesCart
                  .sorted()
                  .map(
                    (courseCode) =>
                        CoursePreview(courseCode: courseCode, onTap: () {}),
                  )
                  .toList() +
              [
                Divider(),
                Row(
                  spacing: 16,
                  children: [
                    Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Days:",
                        "Week Days Diff:",
                        "Min Start Time:",
                        "Max End Time:",
                      ].map((text) => TitleText(text)).toList(),
                    ),
                    Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        orderedTimeTables
                            .map((timeTable) => timeTable.days.length)
                            .maxOrNull
                            .toStringOrDash,
                        orderedTimeTables
                            .map((timeTable) => timeTable.weekDaysDiff.sum)
                            .maxOrNull
                            .toStringOrDash,
                        (orderedTimeTables
                                .map((timeTable) => timeTable.minDayStart)
                                .minOrNull
                                ?.format(context))
                            .toStringOrDash,
                        (orderedTimeTables
                                .map((timeTable) => timeTable.maxDayEnd)
                                .maxOrNull
                                ?.format(context))
                            .toStringOrDash,
                      ].map((text) => TitleText(text)).toList(),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(
                  height: 500,
                  child: ListView.builder(
                    prototypeItem: timeTables.isEmpty
                        ? null
                        : TimeTablePreview(timeTables.first),
                    itemCount: timeTables.length,
                    itemBuilder: (context, index) =>
                        timeTables.elementAtOrNull(index) == null
                        ? null
                        : TimeTablePreview(timeTables.elementAt(index)),
                  ),
                ),
              ],
        );
      },
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Card.outlined(
      child: Wrap(
        children: timeTable.sections
            .map((section) => IntrinsicWidth(child: SectionPreview(section)))
            .toList(),
      ),
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
  Widget build(BuildContext context) {
    final orderedSchedules = section.schedules.sorted();

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          spacing: 16,
          children: [
            TitleText(section.courseCode),
            Row(
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: orderedSchedules
                      .map(
                        (schedule) => TitleText(
                          DateFormat.EEEE().format(
                            DateTime(1970, 1, schedule.day),
                          ),
                        ),
                      )
                      .toList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: orderedSchedules
                      .map(
                        (schedule) => TitleText(schedule.start.format(context)),
                      )
                      .toList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: orderedSchedules
                      .map(
                        (schedule) => TitleText(schedule.end.format(context)),
                      )
                      .toList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: orderedSchedules
                      .map((schedule) => TitleText(schedule.room))
                      .toList(),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 16,
              children: [
                section.sectionNumber.toString(),
                "-",
                (section.tutorial?.sectionLetter).toString(),
                "-",
                (section.lab?.sectionLetter).toString(),
              ].map((text) => TitleText(text)).toList(),
            ),
            // TitleText(
            //   "${section.sectionNumber} - ${section.tutorial?.sectionLetter} - ${section.lab?.sectionLetter}",
            // ),
          ],
        ),
      ),
    );
  }
}
