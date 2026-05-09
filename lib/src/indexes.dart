import 'package:meta/meta.dart' show immutable;

import 'field_path.dart' show FieldPath;

@immutable
class IndexedSource {
  final List<Map<String, dynamic>> _data;
  final Map<String, Map<Object?, List<int>>> _indexes;

  const IndexedSource._(this._data, this._indexes);

  factory IndexedSource(
    Iterable<Map<String, dynamic>> data, {
    Iterable<String> indexedFields = const [],
  }) {
    final source = data is List<Map<String, dynamic>>
        ? List<Map<String, dynamic>>.unmodifiable(data)
        : List<Map<String, dynamic>>.unmodifiable(
            data.toList(growable: false),
          );

    final indexes = <String, Map<Object?, List<int>>>{};
    for (final field in indexedFields) {
      final bucket = <Object?, List<int>>{};
      for (var i = 0; i < source.length; i++) {
        final value = FieldPath.resolve(source[i], field);
        (bucket[value] ??= <int>[]).add(i);
      }
      indexes[field] = Map.unmodifiable(
        bucket.map((k, v) => MapEntry(k, List<int>.unmodifiable(v))),
      );
    }

    return IndexedSource._(source, Map.unmodifiable(indexes));
  }

  List<Map<String, dynamic>> get data => _data;

  bool hasIndex(String field) => _indexes.containsKey(field);

  List<Map<String, dynamic>>? lookup(String field, Object? value) {
    final bucket = _indexes[field];
    if (bucket == null) return null;
    final indices = bucket[value];
    if (indices == null) return const [];
    return List<Map<String, dynamic>>.unmodifiable(
      indices.map((i) => _data[i]),
    );
  }

  Set<Object?> indexedKeys(String field) {
    final bucket = _indexes[field];
    if (bucket == null) return const {};
    return Set<Object?>.unmodifiable(bucket.keys);
  }

  Iterable<String> get indexedFields => _indexes.keys;

  int get length => _data.length;
}
