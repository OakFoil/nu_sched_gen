import 'package:collection/collection.dart';
import 'package:common_flutter/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            .map((section) => section.schedules)
            .flattened
            .findStudyRooms,
      ),
    ),
    showData: (studyRooms) => ListView(
      children:
          <Widget>[
            Center(child: DisplayText("Find Study Rooms (EXPERIMENTAL)")),
          ] +
          studyRooms.entries
              .map((entry) => BuildingPreview(entry.key, entry.value))
              .toList(),
    ),
  );
}

class BuildingPreview extends StatelessWidget {
  final Building building;
  final Map<String?, Map<String, List<Schedule>>> floors;

  const BuildingPreview(this.building, this.floors, {super.key});

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: HeadlineText(building.toString()),
    children: floors.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FloorPreview(entry.key, entry.value),
          ),
        )
        .toList(),
  );
}

class FloorPreview extends StatelessWidget {
  final String? floor;
  final Map<String, List<Schedule>> rooms;

  const FloorPreview(this.floor, this.rooms, {super.key});

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: HeadlineText(floor.toString()),
    children: rooms.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RoomPreview(entry.key, entry.value),
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
  Widget build(BuildContext context) => ListTile(
    title: HeadlineText(room),
    trailing: TitleText("Empty until ${schedules.first.start.format(context)}"),
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
                        (schedule.start.toMinute - a) /
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
        child: TitleText(schedule.start.format(context)),
      ),
      Container(height: 16 * 4, color: Colors.red),
      Align(
        alignment: AlignmentGeometry.centerRight,
        child: TitleText(schedule.end.format(context)),
      ),
    ],
  );
}
