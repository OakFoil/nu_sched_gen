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
  const url = "https://sched-gen.rf.gd/api";

  final Response(:body) = await get(
    Uri.parse(url),
    headers: kIsWeb ? null : {'Cookie': await getCookie(url)},
  );
  final List<dynamic> data = json.decode(body)["data"];
  final Set<Slot> slots = data.map((a) => Slot.fromJson(a)).toSet();

  return Section.allSectionsPerCourseCode(slots);
}

Future<String> getCookie(String url) async {
  await _bypasser.bypass(url);

  if (_bypasser.cookie == null) {
    return Future.error("InfinityFree Bot Check Bypass Failed");
  }

  return _bypasser.cookie!;
}
