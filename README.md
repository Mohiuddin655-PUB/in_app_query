# in_app_query

A powerful, Firestore-inspired in-memory query engine for Dart & Flutter. Filter, sort, paginate, and reactively observe in-memory collections with a familiar, composable API — no network required.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [QueryBuilder](#querybuilder)
    - [Filtering](#filtering)
    - [Composite Filters](#composite-filters)
    - [Sorting](#sorting)
    - [Cursors](#cursors)
    - [Pagination](#pagination)
    - [Aggregations](#aggregations)
    - [Grouping & Distinct](#grouping--distinct)
    - [Transform](#transform)
    - [Stream & Async API](#stream--async-api)
- [Filter](#filter)
- [FieldPath](#fieldpath)
- [IndexedSource](#indexedsource)
- [Collection](#collection)
    - [CRUD](#crud)
    - [Batch Operations](#batch-operations)
    - [Reactive Snapshots](#reactive-snapshots)
- [ReactiveQuery](#reactivequery)
- [Error Handling](#error-handling)
- [Performance](#performance)

---

## Features

- ✅ Firestore-compatible query API (`where`, `orderBy`, `limit`, `startAt`, …)
- ✅ Composite `AND` / `OR` filters with arbitrary nesting
- ✅ Dot-notation nested field access (`address.city`)
- ✅ Array operators (`arrayContains`, `arrayContainsAny`, …)
- ✅ Cursor-based pagination (`startAt`, `startAfter`, `endAt`, `endBefore`)
- ✅ Aggregations (`count`, `sum`, `average`, `min`, `max`)
- ✅ `groupBy`, `distinct`, and `transform` projections
- ✅ Live `Collection` with CRUD, atomic batch writes, and change streams
- ✅ `ReactiveQuery` for auto-updating derived views
- ✅ `IndexedSource` for O(1) field lookups on hot paths
- ✅ Fully synchronous build path; async helpers (`execute`, `stream`, `paginate`) available
- ✅ Immutable result lists

---

## Installation

```yaml
dependencies:
  in_app_query: ^1.1.0
```

```dart
import 'package:in_app_query/in_app_query.dart';
```

---

## Quick Start

```dart
final users = [
  {'id': 'u1', 'name': 'Alice', 'age': 28, 'role': 'admin', 'active': true},
  {'id': 'u2', 'name': 'Bob',   'age': 34, 'role': 'user',  'active': true},
  {'id': 'u3', 'name': 'Eve',   'age': 22, 'role': 'guest', 'active': false},
];

final results = QueryBuilder(users)
    .where('active', isEqualTo: true)
    .where('age', isGreaterThan: 25)
    .orderBy('age')
    .limit(10)
    .build();
```

---

## QueryBuilder

`QueryBuilder` is the main entry point. It is **immutable and reusable** — every method returns a new builder instance, leaving the original unchanged.

```dart
QueryBuilder(List<Map<String, dynamic>> source)
QueryBuilder.empty()                          // empty source
QueryBuilder.fromIndexed(IndexedSource source)
```

### Filtering

```dart
// Equality
.where('role', isEqualTo: 'admin')
.where('role', isNotEqualTo: 'guest')

// Comparison — works on num, String, DateTime
.where('age', isLessThan: 30)
.where('age', isLessThanOrEqualTo: 30)
.where('age', isGreaterThan: 25)
.where('age', isGreaterThanOrEqualTo: 25)

// Set membership
.where('role', whereIn: ['admin', 'user'])
.where('role', whereNotIn: ['guest'])

// Null checks
.where('score', isNull: true)
.where('score', isNull: false)

// Array operators
.where('tags', arrayContains: 'flutter')
.where('tags', arrayNotContains: 'flutter')
.where('tags', arrayContainsAny: ['rust', 'go'])
.where('tags', arrayNotContainsAny: ['dart', 'python'])

// Custom predicate
.whereCustom((doc) => (doc['name'] as String).startsWith('A'))

// Chain multiple conditions (implicit AND)
.where('active', isEqualTo: true)
.where('role', isEqualTo: 'admin')
```

Nested fields are accessed with dot notation:

```dart
.where('address.city', isEqualTo: 'Tokyo')
.where('address.country', whereIn: ['USA', 'UK'])
```

### Composite Filters

Pass a `Filter` object to `.where()` or `.whereFilter()` for `AND` / `OR` logic:

```dart
.whereFilter(
  Filter.and([
    const Filter('active', isEqualTo: true),
    Filter.or([
      const Filter('role', isEqualTo: 'admin'),
      const Filter('age', isGreaterThan: 40),
    ]),
  ]),
)
```

> `Filter.and([])` keeps all documents. `Filter.or([])` drops all documents.

### Sorting

```dart
.orderBy('age')                        // ascending (default)
.orderBy('age', descending: true)      // descending

// Multi-field: primary then secondary
.orderBy('role').orderBy('age', descending: true)
```

`null` values are always sorted **last** in ascending order and **first** in descending order.

### Cursors

Cursors require an `orderBy` to be set first. Values correspond positionally to the ordered fields.

```dart
.orderBy('age').startAt([28])          // age >= 28 (inclusive)
.orderBy('age').startAfter([28])       // age >  28 (exclusive)
.orderBy('age').endAt([34])            // age <= 34 (inclusive)
.orderBy('age').endBefore([34])        // age <  34 (exclusive)

// Range
.orderBy('age').startAt([28]).endAt([34])

// Start from a specific document
.orderBy('age').startAtDocument(myDoc)
```

### Pagination

```dart
.limit(10)             // take the first N results
.limitToLast(10)       // take the last N results (requires orderBy)
.offset(20)            // skip the first N results
.offset(20).limit(10)  // classic page = offset / limit

// Async streaming pages
await for (final page in builder.paginate(pageSize: 20)) {
  // page is List<Map<String, dynamic>>
}
```

### Aggregations

Aggregations are **terminal** — they consume the builder and return a value directly without calling `.build()`.

```dart
builder.count()            // int
builder.sum('age')         // num? (null if no documents)
builder.average('age')     // num? (null if no documents)
builder.min('age')         // dynamic
builder.max('age')         // dynamic
builder.first()            // Map<String, dynamic>?
builder.last()             // Map<String, dynamic>?
builder.isEmpty            // bool
builder.isNotEmpty         // bool
```

### Grouping & Distinct

```dart
// Returns Map<dynamic, List<Map<String, dynamic>>>
final byRole = QueryBuilder(users).groupBy('role');
// { 'admin': [...], 'user': [...], 'guest': [...] }

// Dot-notation supported
final byCountry = QueryBuilder(users).groupBy('address.country');

// Keep only the first document for each unique value of a field
final uniqueRoles = QueryBuilder(users).distinct('role').build();
```

### Transform

Project documents into a new shape before returning results:

```dart
final result = QueryBuilder(users)
    .transform((doc) => {
      'name': doc['name'],
      'isAdult': (doc['age'] as int) >= 18,
    })
    .build();
```

`transform` can be combined with filters and sorting applied **before** it.

### Stream & Async API

```dart
// Emit each document individually as a stream
await for (final doc in builder.stream()) { ... }

// Return all results as a Future
final results = await builder.execute();

// With an artificial delay (useful for testing loaders)
final results = await builder.execute(delay: const Duration(milliseconds: 200));
```

---

## Filter

A standalone, reusable filter object. Accepts the same named parameters as `.where()`.

```dart
const Filter('role', isEqualTo: 'admin')
const Filter('age', isGreaterThan: 25)
const Filter('tags', arrayContains: 'flutter')
const Filter('role', whereIn: ['admin', 'user'])

Filter.and([filter1, filter2, ...])
Filter.or([filter1, filter2, ...])
```

---

## FieldPath

Use `FieldPath` as a typed alternative to dot-notation strings:

```dart
QueryBuilder(users)
    .where(FieldPath('address.country'), isEqualTo: 'Japan')
    .build();
```

---

## IndexedSource

Pre-build hash-map indexes for fields that are queried repeatedly. Lookups against indexed fields run in O(1) instead of O(n).

```dart
final indexed = IndexedSource(
  users,
  indexedFields: ['role', 'active'],
);

indexed.length;                   // int
indexed.hasIndex('role');         // true
indexed.hasIndex('age');          // false

indexed.lookup('role', 'admin');  // List<Map<String, dynamic>>?
indexed.indexedKeys('role');      // Set of distinct values for the field

// Use with QueryBuilder
final qb = QueryBuilder.fromIndexed(indexed);
```

---

## Collection

A live, mutable store that wraps a list of documents and emits change events.

```dart
final col = Collection();                // empty
final col = Collection.from(existing);  // seeded with existing docs

// Remember to dispose when done
await col.dispose();
```

### CRUD

Every document **must** have an `'id'` field.

```dart
col.add({'id': 'u1', 'name': 'Alice'});       // throws if id exists
col.update('u1', {'name': 'Alicia'});          // shallow merge; throws if missing
col.set('u1', {'name': 'Alicia', 'age': 30}); // full replace
col.remove('u1');                              // returns bool

col.contains('u1');                            // bool
col.doc('u1');                                 // Map? — null if missing
col.length;                                    // int
```

### Batch Operations

Execute multiple mutations atomically. If any operation throws, **all changes are rolled back** and no change events are emitted.

```dart
col.batch((scope) {
  scope.add({'id': 'u6', 'name': 'Frank'});
  scope.update('u1', {'role': 'superadmin'});
  scope.remove('u3');
});
```

### Reactive Snapshots

```dart
// Full snapshot after every mutation
col.snapshots().listen((List<Map<String, dynamic>> all) { ... });

// Granular change events
col.changes.listen((List<CollectionChange> changes) {
  for (final change in changes) {
    print('${change.type}: ${change.id}');
  }
});
```

---

## ReactiveQuery

Combines a `Collection` with a `QueryBuilder` query to produce a self-updating view.

```dart
final reactive = ReactiveQuery(
  source: col,
  query: (qb) => qb.where('role', isEqualTo: 'admin').orderBy('age'),
);

// Synchronous snapshot of the current result
final current = reactive.now(); // List<Map<String, dynamic>>

// Stream that re-emits whenever the underlying collection changes
reactive.watch().listen((List<Map<String, dynamic>> results) { ... });

// Convenience: stream of result counts
reactive.watchCount().listen((int count) { ... });
```

The stream is **debounced** — rapid synchronous mutations to the source collection are coalesced into a single emission.

---

## Error Handling

| Situation | Exception |
|---|---|
| `limit` or `offset` called with a negative value | `InvalidQueryException` |
| `limitToLast` called without `orderBy` | `InvalidQueryException` |
| `startAt` / `startAfter` / `endAt` / `endBefore` called without `orderBy` | `CursorException` |
| Cursor values list is empty or has more entries than ordered fields | `CursorException` |
| `Collection.add` called with a document missing an `'id'` key | `InvalidQueryException` |
| `Collection.add` called with a duplicate id | `InvalidQueryException` |
| `Collection.update` called with a non-existent id | `InvalidQueryException` |

---

## Performance

`in_app_query` is optimised for in-memory workloads:

- `QueryBuilder.fromIndexed` skips O(n) scans for equality filters on indexed fields.
- The compiled filter path (`whereFilter`) fuses all conditions into a single pass over the source list.
- Benchmark on a 50 000-document collection with a compiled `AND(whereIn, whereNotIn)` filter typically completes in **< 50 ms** on a mid-range device.

For very large datasets, prefer `IndexedSource` on high-cardinality equality fields and avoid rebuilding `QueryBuilder` instances in hot loops — builders are reusable by design.

.


