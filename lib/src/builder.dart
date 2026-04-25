import 'filter.dart';
import 'sorting.dart';

class QueryBuilder {
  final List<Map<String, dynamic>> _data;
  final Map<String, Sorting> _orders;

  QueryBuilder._(this._data, this._orders);

  factory QueryBuilder(List<Map<String, dynamic>> data) {
    return QueryBuilder._(List.unmodifiable(data), const {});
  }

  // ─── Filter ───────────────────────────────────────────────────────────────

  QueryBuilder where(
    Object field, {
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
    if (field is Filter) return _applyFilter(field);

    final filtered = _data.where((doc) {
      final value = doc[field];
      if (isEqualTo != null && value != isEqualTo) return false;
      if (isNotEqualTo != null && value == isNotEqualTo) return false;
      if (isLessThan != null && !_isLessThan(value, isLessThan)) return false;
      if (isLessThanOrEqualTo != null &&
          !_isLessThanOrEqual(value, isLessThanOrEqualTo)) {
        return false;
      }
      if (isGreaterThan != null && !_isGreaterThan(value, isGreaterThan)) {
        return false;
      }
      if (isGreaterThanOrEqualTo != null &&
          !_isGreaterThanOrEqual(value, isGreaterThanOrEqualTo)) {
        return false;
      }
      if (arrayContains != null && !_iterableContains(value, arrayContains)) {
        return false;
      }
      if (arrayNotContains != null &&
          _iterableContains(value, arrayNotContains)) {
        return false;
      }
      if (arrayContainsAny != null &&
          !_iterableContainsAny(value, arrayContainsAny)) {
        return false;
      }
      if (arrayNotContainsAny != null &&
          _iterableContainsAny(value, arrayNotContainsAny)) {
        return false;
      }
      if (whereIn != null && !whereIn.contains(value)) return false;
      if (whereNotIn != null && whereNotIn.contains(value)) return false;
      if (isNull != null && (value == null) != isNull) return false;
      return true;
    }).toList();

    return QueryBuilder._(filtered, _orders);
  }

  QueryBuilder _applyFilter(Filter filter) {
    if (filter.type.isAndFilter) {
      return _applyAndFilter(filter.field as List<Filter>);
    } else if (filter.type.isOrFilter) {
      return _applyOrFilter(filter.field as List<Filter>);
    }
    return QueryBuilder._(_applySingleFilter(_data, filter), _orders);
  }

  QueryBuilder _applyAndFilter(List<Filter> filters) {
    var result = _data;
    for (final filter in filters) {
      if (filter.type.isNoneFilter) {
        result = _applySingleFilter(result, filter);
      } else {
        result = QueryBuilder._(result, _orders)._applyFilter(filter)._data;
      }
    }
    return QueryBuilder._(result, _orders);
  }

  QueryBuilder _applyOrFilter(List<Filter> filters) {
    final matchedIndices = <int>{};

    for (final filter in filters) {
      for (int i = 0; i < _data.length; i++) {
        if (matchedIndices.contains(i)) continue;
        final doc = _data[i];
        final matches = filter.type.isNoneFilter
            ? _applySingleFilter([doc], filter).isNotEmpty
            : QueryBuilder._([doc], _orders)
                ._applyFilter(filter)
                ._data
                .isNotEmpty;
        if (matches) matchedIndices.add(i);
      }
    }

    final sortedIndices = matchedIndices.toList()..sort();
    return QueryBuilder._(sortedIndices.map((i) => _data[i]).toList(), _orders);
  }

  static List<Map<String, dynamic>> _applySingleFilter(
    List<Map<String, dynamic>> data,
    Filter filter,
  ) {
    return data.where((doc) {
      final value = doc[filter.field];
      if (filter.isEqualTo != null && value != filter.isEqualTo) return false;
      if (filter.isNotEqualTo != null && value == filter.isNotEqualTo) {
        return false;
      }
      if (filter.isLessThan != null && !_isLessThan(value, filter.isLessThan)) {
        return false;
      }
      if (filter.isLessThanOrEqualTo != null &&
          !_isLessThanOrEqual(value, filter.isLessThanOrEqualTo)) {
        return false;
      }
      if (filter.isGreaterThan != null &&
          !_isGreaterThan(value, filter.isGreaterThan)) {
        return false;
      }
      if (filter.isGreaterThanOrEqualTo != null &&
          !_isGreaterThanOrEqual(value, filter.isGreaterThanOrEqualTo)) {
        return false;
      }
      if (filter.arrayContains != null &&
          !_iterableContains(value, filter.arrayContains)) {
        return false;
      }
      if (filter.arrayNotContains != null &&
          _iterableContains(value, filter.arrayNotContains)) {
        return false;
      }
      if (filter.arrayContainsAny != null &&
          !_iterableContainsAny(value, filter.arrayContainsAny!)) {
        return false;
      }
      if (filter.arrayNotContainsAny != null &&
          _iterableContainsAny(value, filter.arrayNotContainsAny!)) {
        return false;
      }
      if (filter.whereIn != null && !filter.whereIn!.contains(value)) {
        return false;
      }
      if (filter.whereNotIn != null && filter.whereNotIn!.contains(value)) {
        return false;
      }
      if (filter.isNull != null && (value == null) != filter.isNull) {
        return false;
      }
      return true;
    }).toList();
  }

  // ─── Sorting ──────────────────────────────────────────────────────────────

  QueryBuilder orderBy(String field, {bool descending = false}) {
    final newOrders = Map<String, Sorting>.from(_orders)
      ..[field] = Sorting(field, descending: descending);
    return QueryBuilder._(_sorted(_data, newOrders), newOrders);
  }

  static List<Map<String, dynamic>> _sorted(
    List<Map<String, dynamic>> data,
    Map<String, Sorting> orders,
  ) {
    if (orders.isEmpty) return data;
    final result = List<Map<String, dynamic>>.from(data);
    result.sort((a, b) {
      for (final sort in orders.values) {
        final x = a[sort.field];
        final y = b[sort.field];
        if (x == null && y == null) continue;
        if (x == null) return 1;
        if (y == null) return -1;
        final cmp = _compare(x, y);
        if (cmp != 0) return sort.descending ? -cmp : cmp;
      }
      return 0;
    });
    return result;
  }

  // ─── Cursors ──────────────────────────────────────────────────────────────

  QueryBuilder startAt(List<dynamic> values) {
    final fields = _orderFields;
    return QueryBuilder._(
      _data.where((doc) => _cursorCompare(doc, values, fields) >= 0).toList(),
      _orders,
    );
  }

  QueryBuilder startAfter(List<dynamic> values) {
    final fields = _orderFields;
    return QueryBuilder._(
      _data.where((doc) => _cursorCompare(doc, values, fields) > 0).toList(),
      _orders,
    );
  }

  QueryBuilder startAtDocument(Map<String, dynamic> document) {
    return startAt(_orderFields.map((f) => document[f]).toList());
  }

  QueryBuilder startAfterDocument(Map<String, dynamic> document) {
    return startAfter(_orderFields.map((f) => document[f]).toList());
  }

  QueryBuilder endAt(List<dynamic> values) {
    final fields = _orderFields;
    return QueryBuilder._(
      _data.where((doc) => _cursorCompare(doc, values, fields) <= 0).toList(),
      _orders,
    );
  }

  QueryBuilder endBefore(List<dynamic> values) {
    final fields = _orderFields;
    return QueryBuilder._(
      _data.where((doc) => _cursorCompare(doc, values, fields) < 0).toList(),
      _orders,
    );
  }

  QueryBuilder endAtDocument(Map<String, dynamic> document) {
    return endAt(_orderFields.map((f) => document[f]).toList());
  }

  QueryBuilder endBeforeDocument(Map<String, dynamic> document) {
    return endBefore(_orderFields.map((f) => document[f]).toList());
  }

  List<String> get _orderFields => _orders.keys.toList();

  int _cursorCompare(
    Map<String, dynamic> doc,
    List<dynamic> values,
    List<String> fields,
  ) {
    final len = fields.isEmpty
        ? values.length
        : values.length < fields.length
            ? values.length
            : fields.length;

    for (int i = 0; i < len; i++) {
      final a =
          fields.isNotEmpty ? doc[fields[i]] : doc.values.elementAtOrNull(i);
      final b = values.elementAtOrNull(i);
      if (a == null && b == null) continue;
      if (a == null) return -1;
      if (b == null) return 1;
      final cmp = _compare(a, b);
      if (cmp != 0) {
        final sort = fields.isNotEmpty ? _orders[fields[i]] : null;
        return (sort != null && sort.descending) ? -cmp : cmp;
      }
    }
    return 0;
  }

  // ─── Pagination ───────────────────────────────────────────────────────────

  QueryBuilder limit(int count) {
    assert(count >= 0, 'limit must be non-negative');
    return QueryBuilder._(_data.take(count).toList(), _orders);
  }

  QueryBuilder limitToLast(int count) {
    assert(count >= 0, 'limitToLast must be non-negative');
    return QueryBuilder._(
      _data.reversed.take(count).toList().reversed.toList(),
      _orders,
    );
  }

  // ─── Terminal ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> build() => List.unmodifiable(_data);

  Future<List<Map<String, dynamic>>> execute([int delayMs = 100]) {
    if (delayMs <= 0) return Future.value(build());
    return Future.delayed(Duration(milliseconds: delayMs), build);
  }

  // ─── Private Comparators ──────────────────────────────────────────────────

  static bool _isLessThan(Object? a, Object? b) {
    if (a == null || b == null) return false;
    if (a is num && b is num) return a < b;
    return false;
  }

  static bool _isLessThanOrEqual(Object? a, Object? b) {
    if (a == null || b == null) return false;
    if (a is num && b is num) return a <= b;
    return false;
  }

  static bool _isGreaterThan(Object? a, Object? b) {
    if (a == null || b == null) return false;
    if (a is num && b is num) return a > b;
    return false;
  }

  static bool _isGreaterThanOrEqual(Object? a, Object? b) {
    if (a == null || b == null) return false;
    if (a is num && b is num) return a >= b;
    return false;
  }

  static bool _iterableContains(Object? value, Object? target) =>
      value is Iterable && value.contains(target);

  static bool _iterableContainsAny(Object? value, Iterable<Object?> targets) =>
      value is Iterable && value.any(targets.contains);

  static int _compare(Object a, Object b) {
    if (a is num && b is num) return a.compareTo(b);
    if (a is Comparable && b is Comparable && a.runtimeType == b.runtimeType) {
      return a.compareTo(b);
    }
    return 0;
  }
}
