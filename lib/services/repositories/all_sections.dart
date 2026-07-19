import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:infinityfree_bypasser/infinityfree_bypasser.dart';
import 'package:nu_sched_gen/models/section.dart';
import 'package:nu_sched_gen/models/slot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_sections.g.dart';

final InfinityfreeBypasser _bypasser = InfinityfreeBypasser();

@Riverpod(keepAlive: true)
Future<Map<String, Set<Section>>> allSections(Ref ref) async {
  const backendUrl = "https://nu-courses.rf.gd",
      corsFixUrl = "https://everyorigin.jwvbremen.nl/api/get?url=$backendUrl",
      url = kIsWeb ? corsFixUrl : backendUrl;

  await _bypasser.bypass(url);

  if (_bypasser.cookie == null) {
    return Future.error("InfinityFree Bot Check Bypass Failed");
  }

  final Response(:body) = await get(
    Uri.parse(url),
    headers: {'Cookie': _bypasser.cookie!},
  );
  final List<dynamic> data = json.decode(body)["data"];
  final Set<Slot> slots = data.map((a) => Slot.fromJson(a)).toSet();

  return Section.allSectionsPerCourseCode(slots);
}
