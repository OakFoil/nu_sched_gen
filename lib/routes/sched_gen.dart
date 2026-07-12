import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/time_table.dart';
import 'package:nu_sched_gen/services/courses_cart.dart';
import 'package:nu_sched_gen/services/optimizations.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:nu_sched_gen/services/avilable_sections.dart';
import 'package:nu_sched_gen/services/time_tables.dart';
import 'package:common_flutter/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nu_sched_gen/utils.dart';

part 'sched_gen.g.dart';

@TypedGoRoute<SchedGenRoute>(path: "/")
class SchedGenRoute extends GoRouteData with $SchedGenRoute {
  const SchedGenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => SchedGenScreen();
}

class SchedGenScreen extends ConsumerWidget {
  const SchedGenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesPreviews = ref.watch(
      coursesCartProvider.select(
        (coursesCart) => coursesCart
            .sorted()
            .map((courseCode) => CoursePreview(courseCode: courseCode))
            .toList(),
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverList.list(
          children:
              const [
                Center(child: DisplayText("Generate Schedule")),
                CoursesSearch(),
              ] +
              coursesPreviews +
              [
                const Divider(),
                ListTile(
                  contentPadding: const EdgeInsets.only(right: 16),
                  title: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: const [
                        TextSpan(text: "Optimizations Order (Drag "),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.drag_handle),
                        ),
                        TextSpan(text: " to reorder)"),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      ref.invalidate(optimizationsProvider);
                    },
                    icon: const Icon(Icons.replay),
                  ),
                ),
              ],
        ),
        const TimeTablesOptimizations(),
        SliverList.list(children: [Divider(), TimeTablesStats(), Divider()]),
        const TimeTablesList(),
      ],
    );
  }
}

class TimeTablesOptimizations extends ConsumerWidget {
  const TimeTablesOptimizations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optimizations = ref.watch(optimizationsProvider);

    return SliverReorderableList(
      autoScrollerVelocityScalar: 0.1, // TODO add drag boundary
      itemCount: optimizations.length,
      itemBuilder: (context, index) => ListTile(
        key: ObjectKey(optimizations[index]),
        title: Text(optimizations[index].name),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.drag_handle),
        ),
      ),
      onReorderItem: (oldIndex, newIndex) => ref
          .read(optimizationsProvider.notifier)
          .moveBefore(oldIndex, newIndex),
    );
  }
}

// Cannot add AsyncValueBuilder to it since when loading a prograss bar is displayed which breaks sliver rendering
class TimeTablesList extends ConsumerWidget {
  const TimeTablesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueBuilder(
    asSliver: true,
    asyncValue: ref.watch(timeTablesProvider),
    showData: (timeTables) => SliverPrototypeExtentList(
      prototypeItem: timeTables.isEmpty
          ? const SizedBox.shrink()
          : TimeTablePreview(timeTables.first),
      delegate: SliverChildBuilderDelegate((context, index) {
        final timeTable = timeTables.elementAtOrNull(index);

        return timeTable == null ? null : TimeTablePreview(timeTable);
      }, childCount: timeTables.length),
    ),
  );
}

class TimeTablesStats extends ConsumerWidget {
  const TimeTablesStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueBuilder(
    asyncValue: ref.watch(timeTablesProvider),
    showData: (timeTables) {
      final durationInMinutes = timeTables
          .map((timeTable) => timeTable.maxDayDurationInMinutes)
          .maxOrNull;

      return Row(
        spacing: 16,
        children: [
          Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              "Days:",
              "Week Days Diff:",
              "Min Start Time",
              "Max End Time:",
              "Max Day Duration:",
            ].map((text) => TitleText(text)).toList(),
          ),
          Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                [
                      timeTables
                          .map((timeTable) => timeTable.days.length)
                          .maxOrNull,
                      timeTables
                          .map((timeTable) => timeTable.weekDaysDiff.sum)
                          .maxOrNull,
                      timeTables
                          .map((timeTable) => timeTable.minDayStart)
                          .minOrNull
                          ?.format(context),
                      timeTables
                          .map((timeTable) => timeTable.maxDayEnd)
                          .maxOrNull
                          ?.format(context),
                      durationInMinutes == null
                          ? null
                          : Duration(minutes: durationInMinutes).format(),
                    ]
                    .map((textOrNull) => TitleText(textOrNull.toStringOrDash))
                    .toList(),
          ),
        ],
      );
    },
  );
}

class CoursesSearch extends ConsumerStatefulWidget {
  const CoursesSearch({super.key});

  @override
  ConsumerState<CoursesSearch> createState() => _CourseSearchState();
}

class _CourseSearchState extends ConsumerState<CoursesSearch> {
  final SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) => Center(
    child: MkFutureBuilder(
      future: ref.watch(
        allSectionsProvider.selectAsync((allSections) => allSections.keys),
      ),
      showData: (allCourseCodes) => SearchAnchor.bar(
        barHintText: 'Search courses',
        searchController: controller,
        suggestionsBuilder: (context, controller) => allCourseCodes
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
  Widget build(BuildContext context, WidgetRef ref) => MkFutureBuilder(
    future: ref.watch(
      avilableSectionsProvider.selectAsync(
        (avilableSections) => avilableSections.keys.contains(courseCode),
      ),
    ),
    showData: (isAvilable) {
      final isInCart = ref.watch(
        coursesCartProvider.select(
          (coursesCart) => coursesCart.contains(courseCode),
        ),
      );

      return ListTile(
        title: TitleText(courseCode),
        onTap: isAvilable && !isInCart ? onTap : null,
        trailing: isInCart
            ? IconButton(
                onPressed: () {
                  ref
                      .read(coursesCartProvider.notifier)
                      .removeCourse(courseCode);
                },
                icon: const Icon(Icons.highlight_remove),
              )
            : isAvilable
            ? const SizedBox.shrink()
            : const TitleText("Full"),
      );
    },
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
