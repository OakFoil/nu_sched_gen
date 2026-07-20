import 'dart:convert';
import 'package:http/http.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/slot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_sections.g.dart';

@Riverpod(keepAlive: true)
Future<Map<String, Set<Section>>> allSections(Ref ref) async {
  const url = "https://sched-gen.rf.gd/api";

  final Response(:body) = await get(Uri.parse(url));
  final List<dynamic> data = json.decode(body)["data"];
  final Set<Slot> slots = data.map((a) => Slot.fromJson(a)).toSet();

  return Section.allSectionsPerCourseCode(slots);
}
