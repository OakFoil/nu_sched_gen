import 'package:collection/collection.dart';
import 'package:common_flutter/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nu_sched_gen/conflicts_with.dart';
import 'package:nu_sched_gen/models/schedule.dart';
import 'package:nu_sched_gen/services/repositories/all_sections.dart';
import 'package:nu_sched_gen/utils.dart';

part 'find_study_rooms.g.dart';

@TypedGoRoute<FindStudyRoomsRoute>(path: "/find-study-rooms")
class FindStudyRoomsRoute extends GoRouteData with $FindStudyRoomsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FindStudyRoomsScreen();
}

class FindStudyRoomsScreen extends ConsumerWidget {
  const FindStudyRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MkFutureBuilder(
    future: ref.watch(
      allSectionsProvider.selectAsync(
        (allSections) => allSections.values.flattened
            .expand((section) => section.slots.expand((slot) => slot.schedules))
            .findStudyRooms,
      ),
    ),
    showData: (studyRooms) => ListView(
      children:
          <Widget>[
            Center(child: DisplayText("Find Study Rooms (EXPERIMENTAL)")),
          ] +
          studyRooms.entries
              .map(
                (entry) => ExpansionTilePreview(
                  entry.key,
                  entry.value,
                  (building, floors) => ExpansionTilePreview(
                    building,
                    floors,
                    (room, schedules) => RoomPreview(room, schedules),
                  ),
                ),
              )
              .toList(),
    ),
  );
}

class ExpansionTilePreview<T, G> extends StatelessWidget {
  final T? value;
  final Map<String, G> subValues;
  final Widget Function(String, G) f;

  const ExpansionTilePreview(this.value, this.subValues, this.f, {super.key});

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: HeadlineText(value.toString()),
    children: subValues.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
            child: f(entry.key, entry.value),
          ),
        )
        .toList(),
  );
}

class RoomPreview extends StatelessWidget {
  final String room;
  final List<Schedule> schedules;

  const RoomPreview(this.room, this.schedules, {super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      HeadlineText(room),
      Flexible(
        child: TitleText(
          "Empty until ${schedules.first.timeSlot.start.format(context)}",
        ),
      ),
    ],
  );
}

class Timeline extends StatelessWidget {
  final List<Schedule> schedules;
  final int a = TimeOfDay(hour: 8, minute: 30).toMinute,
      b = TimeOfDay(hour: 20, minute: 0).toMinute;

  Timeline(Set<Schedule> schedules, {super.key})
    : schedules = schedules.sorted();

  @override
  Widget build(BuildContext context) => schedules.containsConflicts
      ? DisplayText("Error: Schedules contains conflicts")
      : LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: schedules
                .map(
                  (schedule) => Positioned(
                    left:
                        constraints.maxWidth *
                        (schedule.timeSlot.start.toMinute - a) /
                        (b - a),
                    width: constraints.maxWidth * schedule.duration / (b - a),
                    child: ScheduleView(schedule),
                  ),
                )
                .toList(),
          ),
        );
}

class ScheduleView extends StatelessWidget {
  final Schedule schedule;

  const ScheduleView(this.schedule, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: AlignmentGeometry.centerLeft,
        child: TitleText(schedule.timeSlot.start.format(context)),
      ),
      Container(height: 16 * 4, color: Colors.red),
      Align(
        alignment: AlignmentGeometry.centerRight,
        child: TitleText(schedule.timeSlot.end.format(context)),
      ),
    ],
  );
}
