import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:nu_sched_gen/services/time_tables.dart';
import 'package:nu_sched_gen/search.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nu_sched_gen/utils.dart';

part 'sched_gen.g.dart';

@TypedGoRoute<SchedGenRoute>(path: "/")
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

    return ListView(
      children:
          const [
            Center(child: DisplayText("Generate Schedule")),
            CourseSearch(),
          ] +
          coursesCart
              .sorted()
              .map((courseCode) => CoursePreview(courseCode: courseCode))
              .toList() +
          const [
            Divider(),
            TimeTablesStats(),
            Divider(),
            SizedBox(height: 500, child: TimeTablesList()),
          ],
    );
  }
}

class TimeTablesStats extends ConsumerWidget {
  const TimeTablesStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueBuilder(
    asyncValue: ref.watch(timeTablesProvider),
    showData: (timeTables) => Row(
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
            timeTables
                .map((timeTable) => timeTable.days.length)
                .maxOrNull
                .toStringOrDash,
            timeTables
                .map((timeTable) => timeTable.weekDaysDiff.sum)
                .maxOrNull
                .toStringOrDash,
            (timeTables
                    .map((timeTable) => timeTable.minDayStart)
                    .minOrNull
                    ?.format(context))
                .toStringOrDash,
            (timeTables
                    .map((timeTable) => timeTable.maxDayEnd)
                    .maxOrNull
                    ?.format(context))
                .toStringOrDash,
          ].map((text) => TitleText(text)).toList(),
        ),
      ],
    ),
  );
}

class TimeTablesList extends ConsumerWidget {
  const TimeTablesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueBuilder(
    asyncValue: ref.watch(timeTablesProvider),
    showData: (timeTables) => ListView.builder(
      prototypeItem: timeTables.isEmpty
          ? null
          : TimeTablePreview(timeTables.first),
      itemCount: timeTables.length,
      itemBuilder: (context, index) => timeTables.elementAtOrNull(index) == null
          ? null
          : TimeTablePreview(timeTables.elementAt(index)),
    ),
  );
}

class CourseSearch extends ConsumerStatefulWidget {
  const CourseSearch({super.key});

  @override
  ConsumerState<CourseSearch> createState() => _CourseSearchState();
}

class _CourseSearchState extends ConsumerState<CourseSearch> {
  final SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) => Center(
    child: AsyncValueBuilder(
      asyncValue: ref.watch(allSectionsProvider),
      showData: (allSections) => SearchAnchor.bar(
        barHintText: 'Search courses',
        searchController: controller,
        suggestionsBuilder: (context, controller) => allSections.keys
            .searchFor(controller.text)
            .take(10)
            .map(
              (courseCode) => CoursePreview(
                courseCode: courseCode,
                onTap: () {
                  controller.closeView("");
                  ref.read(coursesCartProvider.notifier).addCourse(courseCode);
                },
              ),
            ),
      ),
    ),
  );
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
  final GestureTapCallback? onTap;

  const CoursePreview({super.key, required this.courseCode, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    title: TitleText(courseCode),
    onTap: onTap,
    trailing:
        ref.watch(
          coursesCartProvider.select(
            (coursesCart) => coursesCart.contains(courseCode),
          ),
        )
        ? IconButton(
            onPressed: () {
              ref.read(coursesCartProvider.notifier).removeCourse(courseCode);
            },
            icon: const Icon(Icons.highlight_remove),
          )
        : const SizedBox.shrink(),
  );
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
                            DateTime(1970, 0, schedule.day),
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
            const Divider(),
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
          ],
        ),
      ),
    );
  }
}
