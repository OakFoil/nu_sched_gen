import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:nu_sched_gen/models/slot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'slots.g.dart';

@Riverpod(keepAlive: true)
class Slots extends _$Slots {
  @override
  Future<Set<Slot>> build() async {
    final Response(:body) = await get(Uri.parse("/json.php"));
    final List<dynamic> data = json.decode(body)["data"];
    final Iterable<Slot> slots = data.map((a) => Slot.fromJson(a));
    return slots.toSet();
  }
}
