import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nu_sched_gen/models/slot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slots.g.dart';

@Riverpod(keepAlive: true)
class Slots extends _$Slots {
  @override
  Future<Set<Slot>> build() async {
    //TODO final Response(:body) = await get(Uri.parse("https://nu-courses-scraping.ct.ws"),);
    final body = await rootBundle.loadString("assets/json.json");
    final List<dynamic> data = json.decode(body)["data"];
    final Set<Slot> slots = data.map((a) => Slot.fromJson(a)).toSet();
    return slots;
  }
}
