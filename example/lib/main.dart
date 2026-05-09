import 'dart:async';

import 'package:in_app_query/in_app_query.dart';

void main() async {
  await _testBasicFilters();
  await _testCompositeFilters();
  await _testSorting();
  await _testCursors();
  await _testPagination();
  await _testAggregations();
  await _testGroupingAndDistinct();
  await _testTransform();
  await _testNestedFields();
  await _testArrayOperators();
  await _testNullHandling();
  await _testIndexedSource();
  await _testCollectionCrud();
  await _testCollectionBatch();
  await _testReactiveQuery();
  await _testErrorHandling();
  await _testStreamApi();
  await _testEdgeCases();
  await _testBatchAtomicity();
  await _testStreamRaceFree();
  await _testFilterCompilationCorrectness();

  print('\n✅ ALL TESTS PASSED');
}

final List<Map<String, dynamic>> _users = [
  {
    'id': 'u1',
    'name': 'Alice',
    'age': 28,
    'role': 'admin',
    'tags': ['flutter', 'dart'],
    'active': true,
    'address': {'city': 'NYC', 'country': 'USA'},
    'score': 95.5,
    'createdAt': DateTime(2024, 1, 15),
  },
  {
    'id': 'u2',
    'name': 'Bob',
    'age': 34,
    'role': 'user',
    'tags': ['python', 'go'],
    'active': true,
    'address': {'city': 'LA', 'country': 'USA'},
    'score': 87.2,
    'createdAt': DateTime(2023, 6, 10),
  },
  {
    'id': 'u3',
    'name': 'Charlie',
    'age': 22,
    'role': 'user',
    'tags': ['flutter', 'kotlin'],
    'active': false,
    'address': {'city': 'London', 'country': 'UK'},
    'score': 78.9,
    'createdAt': DateTime(2024, 3, 20),
  },
  {
    'id': 'u4',
    'name': 'Diana',
    'age': 45,
    'role': 'admin',
    'tags': ['rust', 'go'],
    'active': true,
    'address': {'city': 'Paris', 'country': 'France'},
    'score': 92.1,
    'createdAt': DateTime(2022, 11, 5),
  },
  {
    'id': 'u5',
    'name': 'Eve',
    'age': 30,
    'role': 'guest',
    'tags': ['flutter'],
    'active': false,
    'address': {'city': 'Tokyo', 'country': 'Japan'},
    'score': null,
    'createdAt': DateTime(2024, 5, 1),
  },
];

Future<void> _testBasicFilters() async {
  print('\n── Basic Filters ──');

  final eq = QueryBuilder(_users).where('role', isEqualTo: 'admin').build();
  _expect(eq.length == 2, 'isEqualTo');

  final neq = QueryBuilder(_users).where('role', isNotEqualTo: 'user').build();
  _expect(neq.length == 3, 'isNotEqualTo');

  final lt = QueryBuilder(_users).where('age', isLessThan: 30).build();
  _expect(lt.length == 2, 'isLessThan');

  final lte =
      QueryBuilder(_users).where('age', isLessThanOrEqualTo: 30).build();
  _expect(lte.length == 3, 'isLessThanOrEqualTo');

  final gt = QueryBuilder(_users).where('age', isGreaterThan: 30).build();
  _expect(gt.length == 2, 'isGreaterThan');

  final gte =
      QueryBuilder(_users).where('age', isGreaterThanOrEqualTo: 30).build();
  _expect(gte.length == 3, 'isGreaterThanOrEqualTo');

  final whereIn =
      QueryBuilder(_users).where('role', whereIn: ['admin', 'guest']).build();
  _expect(whereIn.length == 3, 'whereIn');

  final whereNotIn =
      QueryBuilder(_users).where('role', whereNotIn: ['user']).build();
  _expect(whereNotIn.length == 3, 'whereNotIn');

  final stringCmp =
      QueryBuilder(_users).where('name', isGreaterThan: 'C').build();
  _expect(stringCmp.length == 3, 'string comparison');

  final dateCmp = QueryBuilder(_users)
      .where('createdAt', isGreaterThanOrEqualTo: DateTime(2024, 1, 1))
      .build();
  _expect(dateCmp.length == 3, 'datetime comparison');

  final chained = QueryBuilder(_users)
      .where('active', isEqualTo: true)
      .where('age', isGreaterThan: 25)
      .build();
  _expect(chained.length == 3, 'chained where');
}

Future<void> _testCompositeFilters() async {
  print('\n── Composite Filters (AND/OR) ──');

  final and = QueryBuilder(_users)
      .whereFilter(
        Filter.and([
          const Filter('active', isEqualTo: true),
          const Filter('role', isEqualTo: 'admin'),
        ]),
      )
      .build();
  _expect(and.length == 2, 'AND filter');

  final or = QueryBuilder(_users)
      .whereFilter(
        Filter.or([
          const Filter('role', isEqualTo: 'admin'),
          const Filter('role', isEqualTo: 'guest'),
        ]),
      )
      .build();
  _expect(or.length == 3, 'OR filter');

  final nested = QueryBuilder(_users)
      .whereFilter(
        Filter.and([
          const Filter('active', isEqualTo: true),
          Filter.or([
            const Filter('role', isEqualTo: 'admin'),
            const Filter('age', isGreaterThan: 30),
          ]),
        ]),
      )
      .build();
  _expect(nested.length == 3, 'nested AND/OR');

  final viaWhere = QueryBuilder(_users)
      .where(
        Filter.or([
          const Filter('age', isLessThan: 25),
          const Filter('age', isGreaterThan: 40),
        ]),
      )
      .build();
  _expect(viaWhere.length == 2, 'where(Filter)');
}

Future<void> _testSorting() async {
  print('\n── Sorting ──');

  final asc = QueryBuilder(_users).orderBy('age').build();
  _expect(asc.first['name'] == 'Charlie', 'orderBy ascending');
  _expect(asc.last['name'] == 'Diana', 'orderBy ascending last');

  final desc = QueryBuilder(_users).orderBy('age', descending: true).build();
  _expect(desc.first['name'] == 'Diana', 'orderBy descending');

  final multi = QueryBuilder(
    _users,
  ).orderBy('role').orderBy('age', descending: true).build();
  _expect(multi.first['role'] == 'admin', 'multi-field sort');
  _expect(multi.first['name'] == 'Diana', 'multi-field highest age in role');

  final stringSort = QueryBuilder(_users).orderBy('name').build();
  _expect(stringSort.first['name'] == 'Alice', 'string sort');

  final dateSort =
      QueryBuilder(_users).orderBy('createdAt', descending: true).build();
  _expect(dateSort.first['name'] == 'Eve', 'datetime sort');
}

Future<void> _testCursors() async {
  print('\n── Cursors ──');

  final base = QueryBuilder(_users).orderBy('age');

  final sai = base.startAt([30]).build();
  _expect(sai.length == 3, 'startAt inclusive');
  final sae = base.startAfter([30]).build();
  _expect(sae.length == 2, 'startAfter exclusive');
  final eai = base.endAt([30]).build();
  _expect(eai.length == 3, 'endAt inclusive');
  final ebe = base.endBefore([30]).build();
  _expect(ebe.length == 2, 'endBefore exclusive');
  final cr = base.startAt([28]).endAt([34]).build();
  _expect(cr.length == 3, 'cursor range');

  final eve = _users.firstWhere((u) => u['name'] == 'Eve');
  final fromDoc = base.startAtDocument(eve).build();
  _expect(fromDoc.first['name'] == 'Eve', 'startAtDocument');

  final descCursor = QueryBuilder(
    _users,
  ).orderBy('age', descending: true).startAfter([34]).build();
  _expect(descCursor.first['name'] == 'Eve', 'startAfter with descending');
}

Future<void> _testPagination() async {
  print('\n── Pagination ──');

  final limited = QueryBuilder(_users).orderBy('age').limit(2).build();
  _expect(limited.length == 2, 'limit');
  _expect(limited.first['name'] == 'Charlie', 'limit ordering');

  final last = QueryBuilder(_users).orderBy('age').limitToLast(2).build();
  _expect(last.length == 2, 'limitToLast');
  _expect(last.last['name'] == 'Diana', 'limitToLast ordering');

  final offset = QueryBuilder(_users).orderBy('age').offset(2).build();
  _expect(offset.length == 3, 'offset');
  _expect(offset.first['name'] == 'Eve', 'offset content');

  final paged = QueryBuilder(_users).orderBy('age').offset(1).limit(2).build();
  _expect(paged.length == 2, 'offset+limit');
  _expect(paged.first['name'] == 'Alice', 'offset+limit content');

  final pages = <List<Map<String, dynamic>>>[];
  await for (final page in QueryBuilder(
    _users,
  ).orderBy('age').paginate(pageSize: 2)) {
    pages.add(page);
  }
  _expect(pages.length == 3, 'paginate pages');
  _expect(pages.last.length == 1, 'paginate last page size');
}

Future<void> _testAggregations() async {
  print('\n── Aggregations ──');

  final qb = QueryBuilder(_users);

  _expect(qb.count() == 5, 'count');
  _expect(qb.sum('age') == 159, 'sum');
  _expect((qb.average('age') as num).toStringAsFixed(1) == '31.8', 'average');
  _expect(qb.min('age') == 22, 'min');
  _expect(qb.max('age') == 45, 'max');

  final filtered = qb.where('active', isEqualTo: true);
  _expect(filtered.count() == 3, 'filtered count');
  _expect(filtered.sum('age') == 107, 'filtered sum');

  final emptyAgg = qb.where('role', isEqualTo: 'nope');
  _expect(emptyAgg.count() == 0, 'empty count');
  _expect(emptyAgg.sum('age') == null, 'sum on empty returns null');
  _expect(emptyAgg.average('age') == null, 'avg on empty returns null');

  _expect(qb.first()?['id'] == 'u1', 'first()');
  _expect(qb.last()?['id'] == 'u5', 'last()');
  _expect(qb.isNotEmpty, 'isNotEmpty');
  _expect(QueryBuilder.empty().isEmpty, 'empty().isEmpty');
}

Future<void> _testGroupingAndDistinct() async {
  print('\n── Group / Distinct ──');

  final grouped = QueryBuilder(_users).groupBy('role');
  _expect(grouped.keys.length == 3, 'groupBy keys count');
  _expect(grouped['admin']!.length == 2, 'groupBy admin');
  _expect(grouped['user']!.length == 2, 'groupBy user');
  _expect(grouped['guest']!.length == 1, 'groupBy guest');

  final groupedNested = QueryBuilder(_users).groupBy('address.country');
  _expect(groupedNested['USA']!.length == 2, 'groupBy nested field');

  final distinctByRole = QueryBuilder(_users).distinct('role').build();
  _expect(distinctByRole.length == 3, 'distinct on field');
  final distinctByActive = QueryBuilder(_users).distinct('active').build();
  _expect(distinctByActive.length == 2, 'distinct boolean');
}

Future<void> _testTransform() async {
  print('\n── Transform ──');

  final transformed = QueryBuilder(_users)
      .transform(
        (doc) => {
          'name': doc['name'],
          'isAdult': (doc['age'] as int) >= 18,
        },
      )
      .build();
  _expect(transformed.length == 5, 'transform count');
  _expect(transformed.first.containsKey('isAdult'), 'transform shape');
  _expect(transformed.first.length == 2, 'transform field count');
}

Future<void> _testNestedFields() async {
  print('\n── Nested Fields ──');

  final byCity =
      QueryBuilder(_users).where('address.city', isEqualTo: 'Tokyo').build();
  _expect(byCity.length == 1, 'nested where');
  _expect(byCity.first['name'] == 'Eve', 'nested where match');

  final byCountry = QueryBuilder(
    _users,
  ).where('address.country', whereIn: ['USA', 'UK']).build();
  _expect(byCountry.length == 3, 'nested whereIn');

  final sortedNested = QueryBuilder(_users).orderBy('address.country').build();
  _expect(sortedNested.first['address']['country'] == 'France', 'nested sort');

  final viaPath = QueryBuilder(
    _users,
  ).where(FieldPath('address.country'), isEqualTo: 'Japan').build();
  _expect(viaPath.length == 1, 'FieldPath object');
}

Future<void> _testArrayOperators() async {
  print('\n── Array Operators ──');

  _expect(
    QueryBuilder(
          _users,
        ).where('tags', arrayContains: 'flutter').build().length ==
        3,
    'arrayContains',
  );

  _expect(
    QueryBuilder(
          _users,
        ).where('tags', arrayNotContains: 'flutter').build().length ==
        2,
    'arrayNotContains',
  );

  _expect(
    QueryBuilder(
          _users,
        ).where('tags', arrayContainsAny: ['rust', 'kotlin']).build().length ==
        2,
    'arrayContainsAny',
  );

  _expect(
    QueryBuilder(_users)
            .where('tags', arrayNotContainsAny: ['flutter', 'dart'])
            .build()
            .length ==
        2,
    'arrayNotContainsAny',
  );
}

Future<void> _testNullHandling() async {
  print('\n── Null Handling ──');

  final isNull = QueryBuilder(_users).where('score', isNull: true).build();
  _expect(isNull.length == 1, 'isNull true');
  _expect(isNull.first['name'] == 'Eve', 'isNull match');

  final notNull = QueryBuilder(_users).where('score', isNull: false).build();
  _expect(notNull.length == 4, 'isNull false');

  final sorted = QueryBuilder(_users).orderBy('score').build();
  _expect(sorted.last['score'] == null, 'nulls sorted last (asc)');

  final cmpWithNull =
      QueryBuilder(_users).where('score', isGreaterThan: 90).build();
  _expect(cmpWithNull.length == 2, 'comparator skips null');
}

Future<void> _testIndexedSource() async {
  print('\n── IndexedSource ──');

  final indexed = IndexedSource(_users, indexedFields: ['role', 'active']);
  _expect(indexed.length == 5, 'indexed length');
  _expect(indexed.hasIndex('role'), 'hasIndex role');
  _expect(!indexed.hasIndex('age'), 'hasIndex age (no)');

  final admins = indexed.lookup('role', 'admin');
  _expect(admins != null && admins.length == 2, 'index lookup admin');

  final actives = indexed.lookup('active', true);
  _expect(actives != null && actives.length == 3, 'index lookup active');

  final missing = indexed.lookup('role', 'nope');
  _expect(missing != null && missing.isEmpty, 'index lookup miss');

  final qb = QueryBuilder.fromIndexed(indexed);
  _expect(qb.count() == 5, 'fromIndexed count');

  final keys = indexed.indexedKeys('role');
  _expect(keys.length == 3, 'indexedKeys');
}

Future<void> _testCollectionCrud() async {
  print('\n── Collection CRUD ──');

  final col = Collection.from(_users);
  _expect(col.length == 5, 'collection.from');
  _expect(col.contains('u1'), 'contains');
  _expect(col.doc('u1')?['name'] == 'Alice', 'doc lookup');

  col.add({'id': 'u6', 'name': 'Frank', 'age': 50, 'role': 'user'});
  _expect(col.length == 6, 'add');

  col.update('u1', {'age': 29});
  _expect(col.doc('u1')?['age'] == 29, 'update merges');
  _expect(col.doc('u1')?['name'] == 'Alice', 'update preserves other fields');

  col.set('u1', {'name': 'Alicia', 'age': 30});
  _expect(col.doc('u1')?['name'] == 'Alicia', 'set replaces');

  final removed = col.remove('u6');
  _expect(removed && col.length == 5, 'remove');

  final missing = col.remove('nope');
  _expect(!missing, 'remove non-existent returns false');

  await col.dispose();
}

Future<void> _testCollectionBatch() async {
  print('\n── Collection Batch ──');

  final col = Collection();
  final received = <List<CollectionChange>>[];
  final sub = col.changes.listen(received.add);

  col.batch((scope) {
    scope.add({'id': '1', 'name': 'A'});
    scope.add({'id': '2', 'name': 'B'});
    scope.add({'id': '3', 'name': 'C'});
  });

  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(received.length == 1, 'batch emits single event');
  _expect(received.first.length == 3, 'batch contains all changes');
  _expect(col.length == 3, 'batch persisted');

  await sub.cancel();
  await col.dispose();
}

Future<void> _testReactiveQuery() async {
  print('\n── Reactive Query ──');

  final col = Collection.from(_users);
  final reactive = ReactiveQuery(
    source: col,
    query: (qb) => qb.where('role', isEqualTo: 'admin').orderBy('age'),
  );

  _expect(reactive.now().length == 2, 'reactive initial admin count');

  final received = <int>[];
  final sub = reactive.watchCount().listen(received.add);

  await Future<void>.delayed(const Duration(milliseconds: 20));

  col.add({'id': 'new1', 'name': 'New Admin', 'age': 33, 'role': 'admin'});
  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(reactive.now().length == 3, 'reactive after admin add');

  col.add({'id': 'new2', 'name': 'New User', 'age': 25, 'role': 'user'});
  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(reactive.now().length == 3, 'reactive unaffected by non-match');

  col.remove('u1');
  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(reactive.now().length == 2, 'reactive after admin remove');

  _expect(received.contains(2), 'reactive stream emitted initial');
  _expect(received.contains(3), 'reactive stream emitted after add');
  _expect(received.last == 2, 'reactive stream emitted after remove');

  await sub.cancel();
  await col.dispose();
}

Future<void> _testErrorHandling() async {
  print('\n── Error Handling ──');

  _expectThrows<InvalidQueryException>(
    () => QueryBuilder(_users).limit(-1),
    'negative limit',
  );

  _expectThrows<InvalidQueryException>(
    () => QueryBuilder(_users).offset(-5),
    'negative offset',
  );

  _expectThrows<InvalidQueryException>(
    () => QueryBuilder(_users).limitToLast(3),
    'limitToLast without orderBy',
  );

  _expectThrows<CursorException>(
    () => QueryBuilder(_users).startAt([10]),
    'startAt without orderBy',
  );

  _expectThrows<CursorException>(
    () => QueryBuilder(_users).orderBy('age').startAt([]),
    'empty cursor values',
  );

  _expectThrows<CursorException>(
    () => QueryBuilder(_users).orderBy('age').startAt([1, 2]),
    'too many cursor values',
  );

  _expectThrows<InvalidQueryException>(() {
    final c = Collection();
    c.add({'name': 'no-id'});
  }, 'add without id');

  _expectThrows<InvalidQueryException>(() {
    final c = Collection.from(_users);
    c.update('does-not-exist', {'x': 1});
  }, 'update missing doc');

  _expectThrows<InvalidQueryException>(() {
    final c = Collection.from(_users);
    c.add({'id': 'u1', 'name': 'dup'});
  }, 'duplicate add');
}

Future<void> _testStreamApi() async {
  print('\n── Stream API ──');

  final docs = <Map<String, dynamic>>[];
  await for (final doc
      in QueryBuilder(_users).where('active', isEqualTo: true).stream()) {
    docs.add(doc);
  }
  _expect(docs.length == 3, 'stream() emits each doc');

  final asyncResult = await QueryBuilder(_users).orderBy('age').execute();
  _expect(asyncResult.length == 5, 'execute() returns future');

  final delayed = await QueryBuilder(
    _users,
  ).limit(2).execute(delay: const Duration(milliseconds: 10));
  _expect(delayed.length == 2, 'execute with delay');
}

Future<void> _testEdgeCases() async {
  print('\n── Edge Cases ──');

  final empty = QueryBuilder.empty();
  _expect(empty.count() == 0, 'empty builder count');
  _expect(empty.first() == null, 'empty first');
  _expect(empty.where('x', isEqualTo: 1).build().isEmpty, 'where on empty');

  final single = QueryBuilder([
    {'id': '1', 'v': 10},
  ]);
  _expect(single.count() == 1, 'single doc');
  _expect(single.orderBy('v').first()?['v'] == 10, 'single doc sort');

  final immutability = QueryBuilder(_users).build();
  _expectThrows<Object>(
    () => immutability.add({'id': 'x'}),
    'result list immutable',
  );

  final reused = QueryBuilder(_users).where('age', isGreaterThan: 25);
  final r1 = reused.limit(2).build();
  final r2 = reused.limit(3).build();
  _expect(r1.length == 2 && r2.length == 3, 'builder is reusable');

  final largeData = List.generate(
    10000,
    (i) => {'id': '$i', 'value': i, 'group': i % 100},
  );
  final largeResult = QueryBuilder(largeData)
      .where('group', isEqualTo: 7)
      .orderBy('value', descending: true)
      .limit(5)
      .build();
  _expect(largeResult.length == 5, 'large dataset');
  _expect(largeResult.first['value'] == 9907, 'large dataset correctness');

  final customPredicate = QueryBuilder(
    _users,
  ).whereCustom((doc) => (doc['name'] as String).startsWith('A')).build();
  _expect(customPredicate.length == 1, 'whereCustom');
}

Future<void> _testBatchAtomicity() async {
  print('\n── Batch Atomicity ──');

  final col = Collection.from([
    {'id': '1', 'name': 'Original'},
  ]);

  final received = <List<CollectionChange>>[];
  final sub = col.changes.listen(received.add);

  Object? caught;
  try {
    col.batch((scope) {
      scope.add({'id': '2', 'name': 'B'});
      scope.add({'id': '3', 'name': 'C'});
      scope.add({'id': '1', 'name': 'Dup'});
    });
  } catch (e) {
    caught = e;
  }

  await Future<void>.delayed(const Duration(milliseconds: 20));

  _expect(caught is InvalidQueryException, 'batch closure exception rethrown');
  _expect(col.length == 1, 'collection rolled back to pre-batch size');
  _expect(col.contains('1'), 'original doc preserved');
  _expect(!col.contains('2'), 'partial add "2" rolled back');
  _expect(!col.contains('3'), 'partial add "3" rolled back');
  _expect(received.isEmpty, 'no change events emitted on failed batch');
  _expect(col.doc('1')?['name'] == 'Original', 'original doc unchanged');

  col.batch((scope) {
    scope.add({'id': '4', 'name': 'D'});
    scope.update('1', {'name': 'Updated'});
  });

  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(col.length == 2, 'successful batch applied');
  _expect(col.doc('1')?['name'] == 'Updated', 'successful update applied');
  _expect(received.length == 1, 'successful batch emits one event');
  _expect(received.first.length == 2, 'event contains both ops');

  await sub.cancel();
  await col.dispose();
}

Future<void> _testStreamRaceFree() async {
  print('\n── Stream Race Free ──');

  final col = Collection.from([
    {'id': '1', 'role': 'admin'},
  ]);
  final reactive = ReactiveQuery(
    source: col,
    query: (qb) => qb.where('role', isEqualTo: 'admin'),
  );

  final received = <int>[];
  final sub = reactive.watchCount().listen(received.add);

  col.add({'id': '2', 'role': 'admin'});
  col.add({'id': '3', 'role': 'user'});
  col.add({'id': '4', 'role': 'admin'});

  await Future<void>.delayed(const Duration(milliseconds: 20));

  _expect(received.contains(1), 'received initial count');
  _expect(received.contains(2), 'received after first sync mutation');
  _expect(received.contains(3), 'received after third sync mutation');
  _expect(received.last == 3, 'final state is 3 admins');

  await sub.cancel();
  await col.dispose();

  final col2 = Collection.from([
    {'id': '1', 'name': 'A'},
  ]);
  final snaps = <List<Map<String, dynamic>>>[];
  final sub2 = col2.snapshots().listen(snaps.add);

  col2.add({'id': '2', 'name': 'B'});
  col2.add({'id': '3', 'name': 'C'});

  await Future<void>.delayed(const Duration(milliseconds: 20));
  _expect(snaps.length == 3, 'snapshots emitted initial + 2 mutations');
  _expect(snaps.first.length == 1, 'first snapshot has initial state');
  _expect(snaps.last.length == 3, 'last snapshot has final state');

  await sub2.cancel();
  await col2.dispose();
}

Future<void> _testFilterCompilationCorrectness() async {
  print('\n── Filter Compilation ──');

  final data = [
    {
      'id': '1',
      'role': 'admin',
      'tags': ['flutter', 'dart'],
    },
    {
      'id': '2',
      'role': 'user',
      'tags': ['python'],
    },
    {
      'id': '3',
      'role': 'admin',
      'tags': ['rust', 'go'],
    },
    {
      'id': '4',
      'role': 'guest',
      'tags': ['flutter'],
    },
  ];

  final compiled = QueryBuilder(data)
      .whereFilter(
        Filter.and([
          const Filter('role', whereIn: ['admin', 'guest']),
          const Filter('tags', arrayContainsAny: ['flutter', 'rust']),
        ]),
      )
      .build();
  _expect(compiled.length == 3, 'compiled AND with whereIn + arrayContainsAny');

  final orResult = QueryBuilder(data)
      .whereFilter(
        Filter.or([
          const Filter('role', whereNotIn: ['admin', 'user']),
          const Filter('tags', arrayContainsAny: ['rust']),
        ]),
      )
      .build();
  _expect(orResult.length == 2, 'compiled OR result');

  final nested = QueryBuilder(data)
      .whereFilter(
        Filter.and([
          Filter.or([
            const Filter('role', isEqualTo: 'admin'),
            const Filter('role', isEqualTo: 'guest'),
          ]),
          const Filter('tags', arrayContains: 'flutter'),
        ]),
      )
      .build();
  _expect(nested.length == 2, 'nested compiled filter');

  final emptyAnd = QueryBuilder(data).whereFilter(Filter.and([])).build();
  _expect(emptyAnd.length == 4, 'empty AND keeps all');

  final emptyOr = QueryBuilder(data).whereFilter(Filter.or([])).build();
  _expect(emptyOr.isEmpty, 'empty OR drops all');

  final singleAnd = QueryBuilder(data)
      .whereFilter(Filter.and([const Filter('role', isEqualTo: 'admin')]))
      .build();
  _expect(singleAnd.length == 2, 'single-child AND');

  final largeData = List.generate(
    50000,
    (i) => {'id': '$i', 'group': i % 10, 'tag': 't${i % 100}'},
  );
  final sw = Stopwatch()..start();
  final perfResult = QueryBuilder(largeData)
      .whereFilter(
        Filter.and([
          const Filter('group', whereIn: [3, 7]),
          const Filter('tag', whereNotIn: ['t10', 't20', 't30']),
        ]),
      )
      .build();
  sw.stop();
  print(
    '  ⚡ 50k docs compiled filter ran in ${sw.elapsedMicroseconds}μs '
    '(${perfResult.length} matches)',
  );
  _expect(perfResult.isNotEmpty, 'compiled filter perf path produces results');
}

void _expect(bool condition, String label) {
  if (!condition) {
    throw StateError('FAILED: $label');
  }
  print('  ✓ $label');
}

void _expectThrows<E>(void Function() fn, String label) {
  try {
    fn();
  } catch (e) {
    if (e is E) {
      print('  ✓ $label (threw ${e.runtimeType})');
      return;
    }
    throw StateError('FAILED: $label expected $E but got ${e.runtimeType}');
  }
  throw StateError('FAILED: $label did not throw');
}
