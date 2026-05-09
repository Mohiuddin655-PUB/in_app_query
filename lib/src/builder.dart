import 'package:meta/meta.dart' show immutable;

import 'collection.dart' show Collection;
import 'comparators.dart' show Comparators;
import 'exceptions.dart' show CursorException, InvalidQueryException;
import 'field_path.dart' show FieldPath;
import 'filter.dart' show Filter;
import 'indexes.dart' show IndexedSource;
import 'operations.dart'
    show
        OffsetOp,
        QueryDocument,
        QueryOp,
        DocumentPredicate,
        DocumentTransformer,
        QueryDocuments,
        FilterOp,
        SortOp,
        LimitOp,
        DistinctOp,
        MapOp,
        QueryExecutor,
        CursorOp;
import 'sorting.dart' show Sorting;

export 'collection.dart'
    show
        BatchScope,
        Collection,
        CollectionChange,
        CollectionChangeType,
        DocumentId;
export 'indexes.dart' show IndexedSource;
export 'operations.dart' show QueryDocument, QueryDocuments;

@immutable
class QueryBuilder {
  final List<QueryDocument> _source;
  final List<QueryOp> _ops;
  final List<Sorting> _orders;

  const QueryBuilder._({
    required List<QueryDocument> source,
    required List<QueryOp> ops,
    required List<Sorting> orders,
  })  : _source = source,
        _ops = ops,
        _orders = orders;

  factory QueryBuilder(Iterable<QueryDocument> data) {
    final source = data is List<QueryDocument>
        ? List<QueryDocument>.unmodifiable(data)
        : List<QueryDocument>.unmodifiable(data.toList(growable: false));
    return QueryBuilder._(source: source, ops: const [], orders: const []);
  }

  factory QueryBuilder.fromIndexed(IndexedSource source) {
    return QueryBuilder._(source: source.data, ops: const [], orders: const []);
  }

  factory QueryBuilder.fromCollection(Collection collection) {
    return QueryBuilder(collection.documents);
  }

  factory QueryBuilder.empty() =>
      QueryBuilder._(source: const [], ops: const [], orders: const []);

  QueryBuilder _addOp(QueryOp op, {List<Sorting>? orders}) {
    return QueryBuilder._(
      source: _source,
      ops: List.unmodifiable([..._ops, op]),
      orders: orders ?? _orders,
    );
  }

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
    if (field is Filter) return _addOp(FilterOp.fromFilter(field));

    return _addOp(
      FilterOp.fromConditions(
        field: field,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayNotContains: arrayNotContains,
        arrayContainsAny: arrayContainsAny,
        arrayNotContainsAny: arrayNotContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull,
      ),
    );
  }

  QueryBuilder whereFilter(Filter filter) =>
      _addOp(FilterOp.fromFilter(filter));

  QueryBuilder whereCustom(DocumentPredicate predicate) =>
      _addOp(FilterOp(predicate));

  QueryBuilder orderBy(Object field, {bool descending = false}) {
    final fieldKey = FieldPath.stableKey(field);
    final next = Sorting(fieldKey, descending: descending);
    final newOrders = <Sorting>[
      ..._orders.where((s) => s.field != fieldKey),
      next,
    ];
    final immutableOrders = List<Sorting>.unmodifiable(newOrders);
    return _addOp(SortOp(immutableOrders), orders: immutableOrders);
  }

  QueryBuilder startAt(List<Object?> values) =>
      _addCursor(values, inclusive: true, isStart: true);

  QueryBuilder startAfter(List<Object?> values) =>
      _addCursor(values, inclusive: false, isStart: true);

  QueryBuilder startAtDocument(QueryDocument document) =>
      startAt(_extractCursorValues(document, 'startAtDocument'));

  QueryBuilder startAfterDocument(QueryDocument document) =>
      startAfter(_extractCursorValues(document, 'startAfterDocument'));

  QueryBuilder endAt(List<Object?> values) =>
      _addCursor(values, inclusive: true, isStart: false);

  QueryBuilder endBefore(List<Object?> values) =>
      _addCursor(values, inclusive: false, isStart: false);

  QueryBuilder endAtDocument(QueryDocument document) =>
      endAt(_extractCursorValues(document, 'endAtDocument'));

  QueryBuilder endBeforeDocument(QueryDocument document) =>
      endBefore(_extractCursorValues(document, 'endBeforeDocument'));

  QueryBuilder offset(int count) {
    if (count < 0) {
      throw InvalidQueryException('offset must be non-negative, got $count');
    }
    return _addOp(OffsetOp(count));
  }

  QueryBuilder limit(int count) {
    if (count < 0) {
      throw InvalidQueryException('limit must be non-negative, got $count');
    }
    return _addOp(LimitOp(count));
  }

  QueryBuilder limitToLast(int count) {
    if (count < 0) {
      throw InvalidQueryException(
        'limitToLast must be non-negative, got $count',
      );
    }
    if (_orders.isEmpty) {
      throw const InvalidQueryException(
        'limitToLast requires at least one orderBy clause',
      );
    }
    return _addOp(LimitOp(count, toLast: true));
  }

  QueryBuilder distinct([Object? field]) => _addOp(DistinctOp(field));

  QueryBuilder transform(DocumentTransformer transformer) =>
      _addOp(MapOp(transformer));

  QueryDocuments build() => QueryExecutor.execute(_source, _ops);

  Future<QueryDocuments> execute({Duration? delay}) {
    if (delay == null || delay <= Duration.zero) {
      return Future.sync(build);
    }
    return Future.delayed(delay, build);
  }

  Stream<QueryDocument> stream() async* {
    for (final doc in build()) {
      yield doc;
    }
  }

  Stream<QueryDocuments> paginate({required int pageSize}) async* {
    if (pageSize <= 0) {
      throw InvalidQueryException('pageSize must be positive, got $pageSize');
    }
    final all = build();
    for (int i = 0; i < all.length; i += pageSize) {
      final end = (i + pageSize) > all.length ? all.length : i + pageSize;
      yield List.unmodifiable(all.sublist(i, end));
    }
  }

  int count() => build().length;

  QueryDocument? first() {
    final result = build();
    return result.isEmpty ? null : result.first;
  }

  QueryDocument? last() {
    final result = build();
    return result.isEmpty ? null : result.last;
  }

  bool get isEmpty => build().isEmpty;

  bool get isNotEmpty => build().isNotEmpty;

  num? sum(Object field) {
    num total = 0;
    var found = false;
    for (final doc in build()) {
      final value = FieldPath.resolve(doc, field);
      if (value is num) {
        total += value;
        found = true;
      }
    }
    return found ? total : null;
  }

  num? average(Object field) {
    num total = 0;
    int n = 0;
    for (final doc in build()) {
      final value = FieldPath.resolve(doc, field);
      if (value is num) {
        total += value;
        n++;
      }
    }
    return n == 0 ? null : total / n;
  }

  Object? min(Object field) {
    Object? best;
    for (final doc in build()) {
      final value = FieldPath.resolve(doc, field);
      if (value == null) continue;
      if (best == null) {
        best = value;
        continue;
      }
      if (Comparators.compare(value, best) < 0) best = value;
    }
    return best;
  }

  Object? max(Object field) {
    Object? best;
    for (final doc in build()) {
      final value = FieldPath.resolve(doc, field);
      if (value == null) continue;
      if (best == null) {
        best = value;
        continue;
      }
      if (Comparators.compare(value, best) > 0) best = value;
    }
    return best;
  }

  Map<Object?, QueryDocuments> groupBy(Object field) {
    final groups = <Object?, List<QueryDocument>>{};
    for (final doc in build()) {
      final key = FieldPath.resolve(doc, field);
      (groups[key] ??= <QueryDocument>[]).add(doc);
    }
    return groups.map(
      (k, v) => MapEntry(k, List<QueryDocument>.unmodifiable(v)),
    );
  }

  QueryBuilder _addCursor(
    List<Object?> values, {
    required bool inclusive,
    required bool isStart,
  }) {
    if (_orders.isEmpty) {
      throw const CursorException(
        'Cursor operations require at least one orderBy clause',
      );
    }
    if (values.isEmpty) {
      throw const CursorException('Cursor values cannot be empty');
    }
    if (values.length > _orders.length) {
      throw CursorException(
        'Too many cursor values (${values.length}) for ${_orders.length} orderBy clauses',
      );
    }
    return _addOp(
      CursorOp(
        values: List.unmodifiable(values),
        orders: _orders,
        inclusive: inclusive,
        isStart: isStart,
      ),
    );
  }

  List<Object?> _extractCursorValues(QueryDocument document, String method) {
    if (_orders.isEmpty) {
      throw CursorException('$method requires at least one orderBy clause');
    }
    return _orders
        .map((s) => FieldPath.resolve(document, s.field))
        .toList(growable: false);
  }
}
