# Changelog

All notable changes to `in_app_query` will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and
the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

---

## [1.1.0] — 2026-05-10

### Added

#### `QueryBuilder`

- `QueryBuilder(List<Map<String, dynamic>>)` — construct from an in-memory list.
- `QueryBuilder.empty()` — factory for an empty source.
- `QueryBuilder.fromIndexed(IndexedSource)` — construct from a pre-indexed source.
-
`.where(field, {isEqualTo, isNotEqualTo, isLessThan, isLessThanOrEqualTo, isGreaterThan, isGreaterThanOrEqualTo, whereIn, whereNotIn, isNull, arrayContains, arrayNotContains, arrayContainsAny, arrayNotContainsAny})` —
field-level filter with all Firestore-compatible operators.
- `.where(Filter)` — pass a composite `Filter` object directly to `.where()`.
- `.whereFilter(Filter)` — explicit composite filter entry-point.
- `.whereCustom(bool Function(Map<String, dynamic>))` — arbitrary predicate filter.
- `.orderBy(field, {descending})` — single and multi-field sorting; `null` values sorted last on
  ascending, first on descending.
- `.limit(int)` — take the first N results.
- `.limitToLast(int)` — take the last N results (requires `orderBy`).
- `.offset(int)` — skip the first N results.
- `.startAt(List)`, `.startAfter(List)` — lower-bound cursors (inclusive / exclusive).
- `.endAt(List)`, `.endBefore(List)` — upper-bound cursors (inclusive / exclusive).
- `.startAtDocument(Map<String, dynamic>)` — start cursor from a document snapshot.
- `.transform(Map Function(Map))` — project documents into a new shape.
- `.distinct(field)` — keep first document per unique field value.
- `.build()` — execute the query and return an **immutable** `List`.
- `.stream()` — emit each result document as a `Stream`.
- `.execute({Duration? delay})` — return results as a `Future`.
- `.paginate({required int pageSize})` — async generator yielding pages.
- `.groupBy(field)` — returns `Map<dynamic, List<Map<String, dynamic>>>`.
- `.count()`, `.sum(field)`, `.average(field)`, `.min(field)`, `.max(field)` — terminal
  aggregations; return `null` on an empty result set (except `count` which returns `0`).
- `.first()`, `.last()` — return the first/last document or `null`.
- `.isEmpty`, `.isNotEmpty` — convenience boolean getters.

#### `Filter`

- `const Filter(field, {operator params…})` — leaf filter node; accepts the same named parameters as
  `QueryBuilder.where`.
- `Filter.and(List<Filter>)` — conjunction (all must match); empty list matches all.
- `Filter.or(List<Filter>)` — disjunction (any must match); empty list matches none.
- Arbitrary nesting of `and` / `or` nodes supported.

#### `FieldPath`

- `FieldPath(String dotPath)` — typed wrapper for dot-notation field paths, accepted anywhere a
  field string is accepted.

#### `IndexedSource`

- `IndexedSource(List<Map<String, dynamic>>, {required List<String> indexedFields})` — builds
  hash-map indexes at construction time.
- `.lookup(field, value)` — O(1) document lookup by indexed field value.
- `.indexedKeys(field)` — returns the set of distinct values indexed for a field.
- `.hasIndex(field)` — returns `true` if the field is indexed.
- `.length` — total number of documents.

#### `Collection`

- `Collection()` / `Collection.from(List)` — mutable live document store.
- `.add(Map)` — insert a document; throws `InvalidQueryException` on missing or duplicate `id`.
- `.update(id, Map)` — shallow-merge fields into an existing document; throws if not found.
- `.set(id, Map)` — fully replace a document.
- `.remove(id)` — delete a document; returns `bool`.
- `.contains(id)`, `.doc(id)`, `.length` — read helpers.
- `.batch(void Function(BatchScope))` — atomic multi-operation write with automatic rollback on
  failure; emits a single change event on success.
- `.snapshots()` — `Stream<List<Map<String, dynamic>>>` emitting the full collection after every
  mutation.
- `.changes` — `Stream<List<CollectionChange>>` emitting granular change records.
- `.dispose()` — close all streams and release resources.

#### `ReactiveQuery`

-
`ReactiveQuery({required Collection source, required QueryBuilder Function(QueryBuilder) query})` —
live derived view over a `Collection`.
- `.now()` — synchronous snapshot of the current query result.
- `.watch()` — `Stream<List<Map<String, dynamic>>>` that re-emits on relevant collection changes (
  debounced).
- `.watchCount()` — `Stream<int>` convenience wrapper over `.watch()`.

#### Exceptions

- `InvalidQueryException` — thrown for malformed queries, invalid pagination arguments, and
  `Collection` constraint violations.
- `CursorException` — thrown when cursor API is misused (missing `orderBy`, wrong value count).

---

## [Unreleased]

_Nothing yet._

---

[1.0.0]: https://github.com/your-org/in_app_query/releases/tag/v1.0.0

[Unreleased]: https://github.com/your-org/in_app_query/compare/v1.0.0...HEAD