import 'dart:convert';

/// Helpers for reading the method-channel payloads.
///
/// Everything the Android side sends is a `String` (or null), so parsing is
/// deliberately defensive: a missing or malformed field should degrade that one
/// field rather than throw and lose the whole result.
class Parse {
  Parse._();

  /// Reads a JSON array of image URLs, as produced by `FetchData.imagesToJson`.
  ///
  /// Also accepts an already-decoded `List`, so models keep round-tripping
  /// through `toMap()` / `fromMap()`.
  static List<String> imageList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is! String || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List ? decoded.map((e) => e.toString()).toList() : [];
    } on FormatException {
      return [];
    }
  }

  /// Parses an integer the native side sent as a string.
  static int integer(dynamic raw, {int fallback = 0}) =>
      nullableInteger(raw) ?? fallback;

  /// Like [integer], but keeps "field absent" distinct from "field was zero".
  static int? nullableInteger(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static bool boolean(dynamic raw) =>
      raw is bool ? raw : raw is String && raw.toLowerCase() == 'true';

  /// The native side sends position-indexed maps. Iterating in key order keeps
  /// results in the order YouTube returned them; `HashMap` ordering did not.
  static void forEachIndexed(dynamic raw, void Function(Map item) body) {
    if (raw is! Map) return;
    final keys = raw.keys.toList()
      ..sort((a, b) => integer(a).compareTo(integer(b)));
    for (final key in keys) {
      final value = raw[key];
      if (value is Map) body(value);
    }
  }

  /// Maps an indexed payload into a list of models.
  static List<T> list<T>(dynamic raw, T Function(Map item) build) {
    final result = <T>[];
    forEachIndexed(raw, (item) => result.add(build(item)));
    return result;
  }
}
