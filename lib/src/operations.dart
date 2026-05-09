import 'comparators.dart' show Comparators;
import 'exceptions.dart' show InvalidQueryException;
import 'field_path.dart' show FieldPath;
import 'filter.dart' show Filter;
import 'filter_engine.dart' show FilterEngine;
import 'sorting.dart' show Sorting;

typedef QueryDocument = Map<String, dynamic>;
typedef QueryDocuments = List<QueryDocument>;
typedef DocumentPredicate = bool Function(QueryDocument doc);
typedef DocumentTransformer = QueryDocument Function(QueryDocument doc);

sealed class QueryOp {
  const QueryOp();
}

final class FilterOp extends QueryOp {
  final DocumentPredicate predicate;

  const FilterOp(this.predicate);

  factory FilterOp.fromFilter(Filter filter) {
    return FilterOp(_compile(filter));
  }

  factory FilterOp.fromConditions({
    required Object field,
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Object? arrayNotContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? arrayNotContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    final resolvedField =
        field is String && field.contains('.') ? FieldPath(field) : field;

    final whereInSet = _toSet(whereIn);
    final whereNotInSet = _toSet(whereNotIn);
    final containsAnySet = _toSet(arrayContainsAny);
    final notContainsAnySet = _toSet(arrayNotContainsAny);

    return FilterOp((doc) {
      return FilterEngine.matchesConditions(
        doc,
        field: resolvedField,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayNotContains: arrayNotContains,
        arrayContainsAny: containsAnySet,
        arrayNotContainsAny: notContainsAnySet,
        whereInSet: whereInSet,
        whereNotInSet: whereNotInSet,
        isNull: isNull,
      );
    });
  }

  static DocumentPredicate _compile(Filter filter) {
    if (filter.type.isAndFilter) {
      final children =
          (filter.field as List<Filter>).map(_compile).toList(growable: false);
      if (children.isEmpty) return _alwaysTrue;
      if (children.length == 1) return children[0];
      return (doc) {
        for (var i = 0; i < children.length; i++) {
          if (!children[i](doc)) return false;
        }
        return true;
      };
    }
    if (filter.type.isOrFilter) {
      final children =
          (filter.field as List<Filter>).map(_compile).toList(growable: false);
      if (children.isEmpty) return _alwaysFalse;
      if (children.length == 1) return children[0];
      return (doc) {
        for (var i = 0; i < children.length; i++) {
          if (children[i](doc)) return true;
        }
        return false;
      };
    }

    final rawField = filter.field;
    final field = rawField is String && rawField.contains('.')
        ? FieldPath(rawField)
        : rawField;
    final isEqualTo = filter.isEqualTo;
    final isNotEqualTo = filter.isNotEqualTo;
    final isLessThan = filter.isLessThan;
    final isLessThanOrEqualTo = filter.isLessThanOrEqualTo;
    final isGreaterThan = filter.isGreaterThan;
    final isGreaterThanOrEqualTo = filter.isGreaterThanOrEqualTo;
    final arrayContains = filter.arrayContains;
    final arrayNotContains = filter.arrayNotContains;
    final containsAnySet = _toSet(filter.arrayContainsAny);
    final notContainsAnySet = _toSet(filter.arrayNotContainsAny);
    final whereInSet = _toSet(filter.whereIn);
    final whereNotInSet = _toSet(filter.whereNotIn);
    final isNull = filter.isNull;

    return (doc) => FilterEngine.matchesConditions(
          doc,
          field: field,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThan: isLessThan,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThan: isGreaterThan,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayNotContains: arrayNotContains,
          arrayContainsAny: containsAnySet,
          arrayNotContainsAny: notContainsAnySet,
          whereInSet: whereInSet,
          whereNotInSet: whereNotInSet,
          isNull: isNull,
        );
  }

  static bool _alwaysTrue(QueryDocument _) => true;

  static bool _alwaysFalse(QueryDocument _) => false;

  static Set<Object?>? _toSet(Iterable<Object?>? values) {
    if (values == null) return null;
    return values is Set<Object?> ? values : values.toSet();
  }
}

final class SortOp extends QueryOp {
  final List<Sorting> orders;

  const SortOp(this.orders);
}

final class CursorOp extends QueryOp {
  final List<Object?> values;
  final List<Sorting> orders;
  final bool inclusive;
  final bool isStart;

  const CursorOp({
    required this.values,
    required this.orders,
    required this.inclusive,
    required this.isStart,
  });

  bool matches(QueryDocument doc) {
    final cmp = _compareDoc(doc);
    if (isStart) return inclusive ? cmp >= 0 : cmp > 0;
    return inclusive ? cmp <= 0 : cmp < 0;
  }

  int _compareDoc(QueryDocument doc) {
    for (int i = 0; i < values.length; i++) {
      final sort = orders[i];
      final a = FieldPath.resolve(doc, sort.field);
      final b = values[i];
      if (a == null && b == null) continue;
      if (a == null) return sort.descending ? -1 : 1;
      if (b == null) return sort.descending ? 1 : -1;
      final cmp = Comparators.compare(a, b);
      if (cmp != 0) return sort.descending ? -cmp : cmp;
    }
    return 0;
  }
}

final class OffsetOp extends QueryOp {
  final int count;

  const OffsetOp(this.count);
}

final class LimitOp extends QueryOp {
  final int count;
  final bool toLast;

  const LimitOp(this.count, {this.toLast = false});
}

final class DistinctOp extends QueryOp {
  final Object? field;

  const DistinctOp([this.field]);
}

final class MapOp extends QueryOp {
  final DocumentTransformer transform;

  const MapOp(this.transform);
}

abstract final class QueryExecutor {
  const QueryExecutor._();

  static QueryDocuments execute(List<QueryDocument> source, List<QueryOp> ops) {
    if (ops.isEmpty) return source;

    final leadingFilters = <FilterOp>[];
    SortOp? sortOp;
    final cursors = <CursorOp>[];
    final tail = <QueryOp>[];

    var seenNonFilter = false;
    for (final op in ops) {
      if (op is FilterOp && !seenNonFilter) {
        leadingFilters.add(op);
        continue;
      }
      seenNonFilter = true;
      if (op is SortOp) {
        sortOp = op;
      } else if (op is CursorOp) {
        cursors.add(op);
      } else {
        tail.add(op);
      }
    }

    Iterable<QueryDocument> pipeline = source;

    if (leadingFilters.isNotEmpty) {
      pipeline = pipeline.where((doc) {
        for (var i = 0; i < leadingFilters.length; i++) {
          if (!leadingFilters[i].predicate(doc)) return false;
        }
        return true;
      });
    }

    QueryDocuments working;
    final activeSort = sortOp;

    if (activeSort != null) {
      working = pipeline is List<QueryDocument>
          ? List<QueryDocument>.of(pipeline)
          : pipeline.toList(growable: true);
      if (working.length > 1) _sortInPlace(working, activeSort.orders);
    } else {
      working = pipeline is List<QueryDocument>
          ? pipeline
          : pipeline.toList(growable: false);
    }

    if (cursors.isNotEmpty) {
      final filtered = <QueryDocument>[];
      for (final doc in working) {
        var keep = true;
        for (var i = 0; i < cursors.length; i++) {
          if (!cursors[i].matches(doc)) {
            keep = false;
            break;
          }
        }
        if (keep) filtered.add(doc);
      }
      working = filtered;
    }

    for (final op in tail) {
      working = _applyTail(working, op);
    }

    if (identical(working, source)) return source;
    return List<QueryDocument>.unmodifiable(working);
  }

  static QueryDocuments _applyTail(QueryDocuments data, QueryOp op) {
    switch (op) {
      case FilterOp(predicate: final p):
        final out = <QueryDocument>[];
        for (final doc in data) {
          if (p(doc)) out.add(doc);
        }
        return out;
      case OffsetOp(count: final c):
        if (c <= 0) return data;
        if (c >= data.length) return <QueryDocument>[];
        return data.sublist(c);
      case LimitOp(count: final c, toLast: final last):
        if (c >= data.length) return data;
        if (last) {
          final start = data.length - c;
          return start <= 0 ? data : data.sublist(start);
        }
        return data.sublist(0, c);
      case DistinctOp(field: final field):
        if (field == null) {
          final seen = <_DocKey>{};
          final out = <QueryDocument>[];
          for (final doc in data) {
            if (seen.add(_DocKey(doc))) out.add(doc);
          }
          return out;
        }
        final seen = <Object?>{};
        final out = <QueryDocument>[];
        for (final doc in data) {
          final raw = FieldPath.resolve(doc, field);
          final key = raw is Map || raw is Iterable ? _DocKey(raw) : raw;
          if (seen.add(key)) out.add(doc);
        }
        return out;
      case MapOp(transform: final t):
        return List<QueryDocument>.generate(
          data.length,
          (i) => t(data[i]),
          growable: false,
        );
      case SortOp():
      case CursorOp():
        throw const InvalidQueryException(
          'Sort and cursor must be handled in main pipeline',
        );
    }
  }

  static void _sortInPlace(QueryDocuments data, List<Sorting> orders) {
    data.sort((a, b) {
      for (var i = 0; i < orders.length; i++) {
        final sort = orders[i];
        final x = FieldPath.resolve(a, sort.field);
        final y = FieldPath.resolve(b, sort.field);
        if (x == null && y == null) continue;
        if (x == null) return sort.descending ? -1 : 1;
        if (y == null) return sort.descending ? 1 : -1;
        final cmp = Comparators.compare(x, y);
        if (cmp != 0) return sort.descending ? -cmp : cmp;
      }
      return 0;
    });
  }
}

final class _DocKey {
  final Object? value;
  late final int _hash = _hashOf(value);

  _DocKey(this.value);

  @override
  int get hashCode => _hash;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _DocKey && _deepEquals(value, other.value);
  }

  static int _hashOf(Object? v) {
    if (v == null) return 0;
    if (v is Map) {
      final keys = v.keys.toList()..sort((a, b) => '$a'.compareTo('$b'));
      var h = 17;
      for (final k in keys) {
        h = 0x1fffffff & (h * 31 + k.hashCode);
        h = 0x1fffffff & (h * 31 + _hashOf(v[k]));
      }
      return h;
    }
    if (v is Set) {
      var h = 0;
      for (final e in v) {
        h ^= _hashOf(e);
      }
      return 0x1fffffff & (h * 31 + v.length);
    }
    if (v is Iterable) {
      var h = 19;
      for (final e in v) {
        h = 0x1fffffff & (h * 31 + _hashOf(e));
      }
      return h;
    }
    return v.hashCode;
  }

  static bool _deepEquals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k)) return false;
        if (!_deepEquals(a[k], b[k])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Set && b is Set) {
      if (a.length != b.length) return false;
      for (final e in a) {
        if (!b.contains(e)) return false;
      }
      return true;
    }
    if (a is Iterable && b is Iterable) {
      final ai = a.iterator;
      final bi = b.iterator;
      while (ai.moveNext()) {
        if (!bi.moveNext()) return false;
        if (!_deepEquals(ai.current, bi.current)) return false;
      }
      return !bi.moveNext();
    }
    return a == b;
  }
}
