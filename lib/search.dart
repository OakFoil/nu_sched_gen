import 'dart:collection';
import 'package:collection/collection.dart';

typedef EditDistanceCache =
    HashMap<
      num,
      HashMap<num, HashMap<num, HashMap<String, HashMap<String, num>>>>
    >;

EditDistanceCache _editDistanceCache = HashMap();

extension StringUtils on String {
  String get last => this[length - 1];

  String get allButLast => split("").take(length - 1).join();

  num _editDistanceNotCached(
    String str,
    num insertionCost,
    num removalCost,
    num replacementCost,
  ) {
    if (this == "") return str.length * insertionCost;
    if (str == "") return length * removalCost;
    if (last == str.last) {
      return allButLast.editDistance(
        str.allButLast,
        insertionCost: insertionCost,
        removalCost: removalCost,
        replacementCost: replacementCost,
      );
    }
    final costs = [
      insertionCost +
          editDistance(
            str.allButLast,
            insertionCost: insertionCost,
            removalCost: removalCost,
            replacementCost: replacementCost,
          ),
      removalCost +
          allButLast.editDistance(
            str,
            insertionCost: insertionCost,
            removalCost: removalCost,
            replacementCost: replacementCost,
          ),
      replacementCost +
          allButLast.editDistance(
            str.allButLast,
            insertionCost: insertionCost,
            removalCost: removalCost,
            replacementCost: replacementCost,
          ),
    ];
    return costs.min;
  }

  num editDistance(
    String str, {
    num insertionCost = 1,
    num removalCost = 1,
    num replacementCost = 1,
  }) {
    if (str.length > length) {
      return str.editDistance(
        this,
        insertionCost: removalCost,
        removalCost: insertionCost,
        replacementCost: replacementCost,
      );
    }
    final a = _editDistanceCache[replacementCost] ??= HashMap();
    final b = a[insertionCost] ??= HashMap();
    final c = b[removalCost] ??= HashMap();
    final d = c[this] ??= HashMap();
    final e = d[str] ??= _editDistanceNotCached(
      str,
      insertionCost,
      removalCost,
      replacementCost,
    );
    return e;
  }

  String get removeAllSpecialChars => replaceAll(RegExp(r"[^\w\s]"), "");

  String get removeAllBlank => replaceAll(RegExp(r"\s"), "");
  String get normalizeForSearch =>
      toLowerCase().removeAllBlank.removeAllSpecialChars;
}

extension IterableStringUtils on Iterable<String> {
  Iterable<String> searchFor(String query) => sorted(
    (a, b) => a.normalizeForSearch
        .editDistance(query.normalizeForSearch)
        .compareTo(b.normalizeForSearch.editDistance(query.normalizeForSearch)),
  );
}
