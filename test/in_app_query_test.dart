import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_query/in_app_query.dart';

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

void main() {
  group('Basic Filters', () {
    test('isEqualTo', () {
      final result =
          QueryBuilder(_users).where('role', isEqualTo: 'admin').build();
      expect(result.length, 2);
    });

    test('isNotEqualTo', () {
      final result =
          QueryBuilder(_users).where('role', isNotEqualTo: 'user').build();
      expect(result.length, 3);
    });

    test('isLessThan', () {
      final result = QueryBuilder(_users).where('age', isLessThan: 30).build();
      expect(result.length, 2);
    });

    test('isLessThanOrEqualTo', () {
      final result =
          QueryBuilder(_users).where('age', isLessThanOrEqualTo: 30).build();
      expect(result.length, 3);
    });

    test('isGreaterThan', () {
      final result =
          QueryBuilder(_users).where('age', isGreaterThan: 30).build();
      expect(result.length, 2);
    });

    test('isGreaterThanOrEqualTo', () {
      final result =
          QueryBuilder(_users).where('age', isGreaterThanOrEqualTo: 30).build();
      expect(result.length, 3);
    });

    test('whereIn', () {
      final result = QueryBuilder(_users)
          .where('role', whereIn: ['admin', 'guest']).build();
      expect(result.length, 3);
    });

    test('whereNotIn', () {
      final result =
          QueryBuilder(_users).where('role', whereNotIn: ['user']).build();
      expect(result.length, 3);
    });

    test('string comparison', () {
      final result =
          QueryBuilder(_users).where('name', isGreaterThan: 'C').build();
      expect(result.length, 3);
    });

    test('datetime comparison', () {
      final result = QueryBuilder(_users)
          .where('createdAt', isGreaterThanOrEqualTo: DateTime(2024, 1, 1))
          .build();
      expect(result.length, 3);
    });

    test('chained where', () {
      final result = QueryBuilder(_users)
          .where('active', isEqualTo: true)
          .where('age', isGreaterThan: 25)
          .build();
      expect(result.length, 3);
    });
  });

  group('Composite Filters (AND/OR)', () {
    test('AND filter', () {
      final result = QueryBuilder(_users)
          .whereFilter(
            Filter.and([
              const Filter('active', isEqualTo: true),
              const Filter('role', isEqualTo: 'admin'),
            ]),
          )
          .build();
      expect(result.length, 2);
    });

    test('OR filter', () {
      final result = QueryBuilder(_users)
          .whereFilter(
            Filter.or([
              const Filter('role', isEqualTo: 'admin'),
              const Filter('role', isEqualTo: 'guest'),
            ]),
          )
          .build();
      expect(result.length, 3);
    });

    test('nested AND/OR', () {
      final result = QueryBuilder(_users)
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
      expect(result.length, 3);
    });

    test('where(Filter)', () {
      final result = QueryBuilder(_users)
          .where(
            Filter.or([
              const Filter('age', isLessThan: 25),
              const Filter('age', isGreaterThan: 40),
            ]),
          )
          .build();
      expect(result.length, 2);
    });
  });

  group('Sorting', () {
    test('orderBy ascending - first', () {
      final result = QueryBuilder(_users).orderBy('age').build();
      expect(result.first['name'], 'Charlie');
    });

    test('orderBy ascending - last', () {
      final result = QueryBuilder(_users).orderBy('age').build();
      expect(result.last['name'], 'Diana');
    });

    test('orderBy descending', () {
      final result =
          QueryBuilder(_users).orderBy('age', descending: true).build();
      expect(result.first['name'], 'Diana');
    });

    test('multi-field sort - role', () {
      final result = QueryBuilder(_users)
          .orderBy('role')
          .orderBy('age', descending: true)
          .build();
      expect(result.first['role'], 'admin');
    });

    test('multi-field sort - highest age in role', () {
      final result = QueryBuilder(_users)
          .orderBy('role')
          .orderBy('age', descending: true)
          .build();
      expect(result.first['name'], 'Diana');
    });

    test('string sort', () {
      final result = QueryBuilder(_users).orderBy('name').build();
      expect(result.first['name'], 'Alice');
    });

    test('datetime sort', () {
      final result =
          QueryBuilder(_users).orderBy('createdAt', descending: true).build();
      expect(result.first['name'], 'Eve');
    });
  });

  group('Cursors', () {
    test('startAt inclusive', () {
      final result = QueryBuilder(_users).orderBy('age').startAt([30]).build();
      expect(result.length, 3);
    });

    test('startAfter exclusive', () {
      final result =
          QueryBuilder(_users).orderBy('age').startAfter([30]).build();
      expect(result.length, 2);
    });

    test('endAt inclusive', () {
      final result = QueryBuilder(_users).orderBy('age').endAt([30]).build();
      expect(result.length, 3);
    });

    test('endBefore exclusive', () {
      final result =
          QueryBuilder(_users).orderBy('age').endBefore([30]).build();
      expect(result.length, 2);
    });

    test('cursor range', () {
      final result =
          QueryBuilder(_users).orderBy('age').startAt([28]).endAt([34]).build();
      expect(result.length, 3);
    });

    test('startAtDocument', () {
      final eve = _users.firstWhere((u) => u['name'] == 'Eve');
      final result =
          QueryBuilder(_users).orderBy('age').startAtDocument(eve).build();
      expect(result.first['name'], 'Eve');
    });

    test('startAfter with descending', () {
      final result = QueryBuilder(_users)
          .orderBy('age', descending: true)
          .startAfter([34]).build();
      expect(result.first['name'], 'Eve');
    });
  });

  group('Pagination', () {
    test('limit count', () {
      final result = QueryBuilder(_users).orderBy('age').limit(2).build();
      expect(result.length, 2);
    });

    test('limit ordering', () {
      final result = QueryBuilder(_users).orderBy('age').limit(2).build();
      expect(result.first['name'], 'Charlie');
    });

    test('limitToLast count', () {
      final result = QueryBuilder(_users).orderBy('age').limitToLast(2).build();
      expect(result.length, 2);
    });

    test('limitToLast ordering', () {
      final result = QueryBuilder(_users).orderBy('age').limitToLast(2).build();
      expect(result.last['name'], 'Diana');
    });

    test('offset count', () {
      final result = QueryBuilder(_users).orderBy('age').offset(2).build();
      expect(result.length, 3);
    });

    test('offset content', () {
      final result = QueryBuilder(_users).orderBy('age').offset(2).build();
      expect(result.first['name'], 'Eve');
    });

    test('offset+limit count', () {
      final result =
          QueryBuilder(_users).orderBy('age').offset(1).limit(2).build();
      expect(result.length, 2);
    });

    test('offset+limit content', () {
      final result =
          QueryBuilder(_users).orderBy('age').offset(1).limit(2).build();
      expect(result.first['name'], 'Alice');
    });

    test('paginate pages count', () async {
      final pages = <List<Map<String, dynamic>>>[];
      await for (final page
          in QueryBuilder(_users).orderBy('age').paginate(pageSize: 2)) {
        pages.add(page);
      }
      expect(pages.length, 3);
    });

    test('paginate last page size', () async {
      final pages = <List<Map<String, dynamic>>>[];
      await for (final page
          in QueryBuilder(_users).orderBy('age').paginate(pageSize: 2)) {
        pages.add(page);
      }
      expect(pages.last.length, 1);
    });
  });

  group('Aggregations', () {
    test('count', () {
      expect(QueryBuilder(_users).count(), 5);
    });

    test('sum', () {
      expect(QueryBuilder(_users).sum('age'), 159);
    });

    test('average', () {
      expect(
        (QueryBuilder(_users).average('age') as num).toStringAsFixed(1),
        '31.8',
      );
    });

    test('min', () {
      expect(QueryBuilder(_users).min('age'), 22);
    });

    test('max', () {
      expect(QueryBuilder(_users).max('age'), 45);
    });

    test('filtered count', () {
      expect(QueryBuilder(_users).where('active', isEqualTo: true).count(), 3);
    });

    test('filtered sum', () {
      expect(QueryBuilder(_users).where('active', isEqualTo: true).sum('age'),
          107);
    });

    test('empty count', () {
      expect(QueryBuilder(_users).where('role', isEqualTo: 'nope').count(), 0);
    });

    test('sum on empty returns null', () {
      expect(QueryBuilder(_users).where('role', isEqualTo: 'nope').sum('age'),
          isNull);
    });

    test('avg on empty returns null', () {
      expect(
          QueryBuilder(_users).where('role', isEqualTo: 'nope').average('age'),
          isNull);
    });

    test('first()', () {
      expect(QueryBuilder(_users).first()?['id'], 'u1');
    });

    test('last()', () {
      expect(QueryBuilder(_users).last()?['id'], 'u5');
    });

    test('isNotEmpty', () {
      expect(QueryBuilder(_users).isNotEmpty, isTrue);
    });

    test('empty().isEmpty', () {
      expect(QueryBuilder.empty().isEmpty, isTrue);
    });
  });

  group('Group / Distinct', () {
    test('groupBy keys count', () {
      expect(QueryBuilder(_users).groupBy('role').keys.length, 3);
    });

    test('groupBy admin', () {
      expect(QueryBuilder(_users).groupBy('role')['admin']!.length, 2);
    });

    test('groupBy user', () {
      expect(QueryBuilder(_users).groupBy('role')['user']!.length, 2);
    });

    test('groupBy guest', () {
      expect(QueryBuilder(_users).groupBy('role')['guest']!.length, 1);
    });

    test('groupBy nested field', () {
      expect(QueryBuilder(_users).groupBy('address.country')['USA']!.length, 2);
    });

    test('distinct on field', () {
      expect(QueryBuilder(_users).distinct('role').build().length, 3);
    });

    test('distinct boolean', () {
      expect(QueryBuilder(_users).distinct('active').build().length, 2);
    });
  });

  group('Transform', () {
    test('transform count', () {
      final result = QueryBuilder(_users)
          .transform((doc) =>
              {'name': doc['name'], 'isAdult': (doc['age'] as int) >= 18})
          .build();
      expect(result.length, 5);
    });

    test('transform shape', () {
      final result = QueryBuilder(_users)
          .transform((doc) =>
              {'name': doc['name'], 'isAdult': (doc['age'] as int) >= 18})
          .build();
      expect(result.first.containsKey('isAdult'), isTrue);
    });

    test('transform field count', () {
      final result = QueryBuilder(_users)
          .transform((doc) =>
              {'name': doc['name'], 'isAdult': (doc['age'] as int) >= 18})
          .build();
      expect(result.first.length, 2);
    });
  });

  group('Nested Fields', () {
    test('nested where count', () {
      final result = QueryBuilder(_users)
          .where('address.city', isEqualTo: 'Tokyo')
          .build();
      expect(result.length, 1);
    });

    test('nested where match', () {
      final result = QueryBuilder(_users)
          .where('address.city', isEqualTo: 'Tokyo')
          .build();
      expect(result.first['name'], 'Eve');
    });

    test('nested whereIn', () {
      final result = QueryBuilder(_users)
          .where('address.country', whereIn: ['USA', 'UK']).build();
      expect(result.length, 3);
    });

    test('nested sort', () {
      final result = QueryBuilder(_users).orderBy('address.country').build();
      expect(result.first['address']['country'], 'France');
    });

    test('FieldPath object', () {
      final result = QueryBuilder(_users)
          .where(FieldPath('address.country'), isEqualTo: 'Japan')
          .build();
      expect(result.length, 1);
    });
  });

  group('Array Operators', () {
    test('arrayContains', () {
      expect(
        QueryBuilder(_users)
            .where('tags', arrayContains: 'flutter')
            .build()
            .length,
        3,
      );
    });

    test('arrayNotContains', () {
      expect(
        QueryBuilder(_users)
            .where('tags', arrayNotContains: 'flutter')
            .build()
            .length,
        2,
      );
    });

    test('arrayContainsAny', () {
      expect(
        QueryBuilder(_users)
            .where('tags', arrayContainsAny: ['rust', 'kotlin'])
            .build()
            .length,
        2,
      );
    });

    test('arrayNotContainsAny', () {
      expect(
        QueryBuilder(_users)
            .where('tags', arrayNotContainsAny: ['flutter', 'dart'])
            .build()
            .length,
        2,
      );
    });
  });

  group('Null Handling', () {
    test('isNull true - count', () {
      expect(
          QueryBuilder(_users).where('score', isNull: true).build().length, 1);
    });

    test('isNull true - match', () {
      expect(
        QueryBuilder(_users).where('score', isNull: true).build().first['name'],
        'Eve',
      );
    });

    test('isNull false', () {
      expect(
          QueryBuilder(_users).where('score', isNull: false).build().length, 4);
    });

    test('nulls sorted last (asc)', () {
      expect(
          QueryBuilder(_users).orderBy('score').build().last['score'], isNull);
    });

    test('comparator skips null', () {
      expect(
        QueryBuilder(_users).where('score', isGreaterThan: 90).build().length,
        2,
      );
    });
  });

  group('IndexedSource', () {
    late IndexedSource indexed;

    setUp(() {
      indexed = IndexedSource(_users, indexedFields: ['role', 'active']);
    });

    test('indexed length', () {
      expect(indexed.length, 5);
    });

    test('hasIndex role', () {
      expect(indexed.hasIndex('role'), isTrue);
    });

    test('hasIndex age (no)', () {
      expect(indexed.hasIndex('age'), isFalse);
    });

    test('index lookup admin', () {
      expect(indexed.lookup('role', 'admin')?.length, 2);
    });

    test('index lookup active', () {
      expect(indexed.lookup('active', true)?.length, 3);
    });

    test('index lookup miss', () {
      expect(indexed.lookup('role', 'nope'), isEmpty);
    });

    test('fromIndexed count', () {
      expect(QueryBuilder.fromIndexed(indexed).count(), 5);
    });

    test('indexedKeys', () {
      expect(indexed.indexedKeys('role').length, 3);
    });
  });

  group('Collection CRUD', () {
    late Collection col;

    setUp(() {
      col = Collection.from(_users);
    });

    tearDown(() async {
      await col.dispose();
    });

    test('collection.from length', () {
      expect(col.length, 5);
    });

    test('contains', () {
      expect(col.contains('u1'), isTrue);
    });

    test('doc lookup', () {
      expect(col.doc('u1')?['name'], 'Alice');
    });

    test('add', () {
      col.add({'id': 'u6', 'name': 'Frank', 'age': 50, 'role': 'user'});
      expect(col.length, 6);
    });

    test('update merges', () {
      col.update('u1', {'age': 29});
      expect(col.doc('u1')?['age'], 29);
    });

    test('update preserves other fields', () {
      col.update('u1', {'age': 29});
      expect(col.doc('u1')?['name'], 'Alice');
    });

    test('set replaces', () {
      col.set('u1', {'name': 'Alicia', 'age': 30});
      expect(col.doc('u1')?['name'], 'Alicia');
    });

    test('remove', () {
      col.add({'id': 'u6', 'name': 'Frank', 'age': 50, 'role': 'user'});
      expect(col.remove('u6') && col.length == 5, isTrue);
    });

    test('remove non-existent returns false', () {
      expect(col.remove('nope'), isFalse);
    });
  });

  group('Collection Batch', () {
    test('batch emits single event with all changes', () async {
      final col = Collection();
      final received = <List<CollectionChange>>[];
      final sub = col.changes.listen(received.add);

      col.batch((scope) {
        scope.add({'id': '1', 'name': 'A'});
        scope.add({'id': '2', 'name': 'B'});
        scope.add({'id': '3', 'name': 'C'});
      });

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(received.length, 1);
      expect(received.first.length, 3);
      expect(col.length, 3);

      await sub.cancel();
      await col.dispose();
    });
  });

  group('Reactive Query', () {
    late Collection col;
    late ReactiveQuery reactive;

    setUp(() {
      col = Collection.from(_users);
      reactive = ReactiveQuery(
        source: col,
        query: (qb) => qb.where('role', isEqualTo: 'admin').orderBy('age'),
      );
    });

    tearDown(() async {
      await col.dispose();
    });

    test('initial admin count', () {
      expect(reactive.now().length, 2);
    });

    test('stream emitted initial count', () async {
      final received = <int>[];
      final sub = reactive.watchCount().listen(received.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(received.contains(2), isTrue);
      await sub.cancel();
    });

    test('reactive after admin add', () async {
      final sub = reactive.watchCount().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      col.add({'id': 'new1', 'name': 'New Admin', 'age': 33, 'role': 'admin'});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(reactive.now().length, 3);
      await sub.cancel();
    });

    test('reactive unaffected by non-match', () async {
      final sub = reactive.watchCount().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      col.add({'id': 'new1', 'name': 'New Admin', 'age': 33, 'role': 'admin'});
      col.add({'id': 'new2', 'name': 'New User', 'age': 25, 'role': 'user'});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(reactive.now().length, 3);
      await sub.cancel();
    });

    test('reactive after admin remove', () async {
      final sub = reactive.watchCount().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 5));
      col.add({'id': 'new1', 'name': 'New Admin', 'age': 33, 'role': 'admin'});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      col.remove('u1');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(reactive.now().length, 2);
      await sub.cancel();
    });

    test('reactive stream emits correct sequence', () async {
      final received = <int>[];
      final sub = reactive.watchCount().listen(received.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      col.add({'id': 'new1', 'name': 'New Admin', 'age': 33, 'role': 'admin'});
      await Future<void>.delayed(const Duration(milliseconds: 10));
      col.remove('u1');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(received.contains(2), isTrue);
      expect(received.contains(3), isTrue);
      expect(received.last, 2);
      await sub.cancel();
    });
  });

  group('Error Handling', () {
    test('negative limit throws', () {
      expect(
        () => QueryBuilder(_users).limit(-1),
        throwsA(isA<InvalidQueryException>()),
      );
    });

    test('negative offset throws', () {
      expect(
        () => QueryBuilder(_users).offset(-5),
        throwsA(isA<InvalidQueryException>()),
      );
    });

    test('limitToLast without orderBy throws', () {
      expect(
        () => QueryBuilder(_users).limitToLast(3),
        throwsA(isA<InvalidQueryException>()),
      );
    });

    test('startAt without orderBy throws', () {
      expect(
        () => QueryBuilder(_users).startAt([10]),
        throwsA(isA<CursorException>()),
      );
    });

    test('empty cursor values throws', () {
      expect(
        () => QueryBuilder(_users).orderBy('age').startAt([]),
        throwsA(isA<CursorException>()),
      );
    });

    test('too many cursor values throws', () {
      expect(
        () => QueryBuilder(_users).orderBy('age').startAt([1, 2]),
        throwsA(isA<CursorException>()),
      );
    });

    test('add without id throws', () {
      expect(
        () => Collection()..add({'name': 'no-id'}),
        throwsA(isA<InvalidQueryException>()),
      );
    });

    test('update missing doc throws', () {
      expect(
        () => Collection.from(_users)..update('does-not-exist', {'x': 1}),
        throwsA(isA<InvalidQueryException>()),
      );
    });

    test('duplicate add throws', () {
      expect(
        () => Collection.from(_users)..add({'id': 'u1', 'name': 'dup'}),
        throwsA(isA<InvalidQueryException>()),
      );
    });
  });

  group('Stream API', () {
    test('stream() emits each doc', () async {
      final docs = <Map<String, dynamic>>[];
      await for (final doc
          in QueryBuilder(_users).where('active', isEqualTo: true).stream()) {
        docs.add(doc);
      }
      expect(docs.length, 3);
    });

    test('execute() returns future', () async {
      final result = await QueryBuilder(_users).orderBy('age').execute();
      expect(result.length, 5);
    });

    test('execute with delay', () async {
      final result = await QueryBuilder(_users)
          .limit(2)
          .execute(delay: const Duration(milliseconds: 10));
      expect(result.length, 2);
    });
  });

  group('Edge Cases', () {
    test('empty builder count', () {
      expect(QueryBuilder.empty().count(), 0);
    });

    test('empty first returns null', () {
      expect(QueryBuilder.empty().first(), isNull);
    });

    test('where on empty', () {
      expect(QueryBuilder.empty().where('x', isEqualTo: 1).build(), isEmpty);
    });

    test('single doc count', () {
      expect(
          QueryBuilder([
            {'id': '1', 'v': 10}
          ]).count(),
          1);
    });

    test('single doc sort', () {
      expect(
          QueryBuilder([
            {'id': '1', 'v': 10}
          ]).orderBy('v').first()?['v'],
          10);
    });

    test('result list is immutable', () {
      final result = QueryBuilder(_users).build();
      expect(() => result.add({'id': 'x'}), throwsA(anything));
    });

    test('builder is reusable', () {
      final reused = QueryBuilder(_users).where('age', isGreaterThan: 25);
      final r1 = reused.limit(2).build();
      final r2 = reused.limit(3).build();
      expect(r1.length, 2);
      expect(r2.length, 3);
    });

    test('large dataset correctness', () {
      final largeData = List.generate(
        10000,
        (i) => {'id': '$i', 'value': i, 'group': i % 100},
      );
      final result = QueryBuilder(largeData)
          .where('group', isEqualTo: 7)
          .orderBy('value', descending: true)
          .limit(5)
          .build();
      expect(result.length, 5);
      expect(result.first['value'], 9907);
    });

    test('whereCustom predicate', () {
      final result = QueryBuilder(_users)
          .whereCustom((doc) => (doc['name'] as String).startsWith('A'))
          .build();
      expect(result.length, 1);
    });
  });

  group('Batch Atomicity', () {
    test('failed batch rolls back and emits no events', () async {
      final col = Collection.from([
        {'id': '1', 'name': 'Original'},
      ]);
      final received = <List<CollectionChange>>[];
      final sub = col.changes.listen(received.add);

      expect(
        () => col.batch((scope) {
          scope.add({'id': '2', 'name': 'B'});
          scope.add({'id': '3', 'name': 'C'});
          scope.add({'id': '1', 'name': 'Dup'}); // duplicate — should throw
        }),
        throwsA(isA<InvalidQueryException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(col.length, 1, reason: 'collection rolled back');
      expect(col.contains('1'), isTrue, reason: 'original doc preserved');
      expect(col.contains('2'), isFalse, reason: 'partial add "2" rolled back');
      expect(col.contains('3'), isFalse, reason: 'partial add "3" rolled back');
      expect(received, isEmpty, reason: 'no change events on failed batch');
      expect(col.doc('1')?['name'], 'Original',
          reason: 'original doc unchanged');

      await sub.cancel();
      await col.dispose();
    });

    test('successful batch applies all ops and emits one event', () async {
      final col = Collection.from([
        {'id': '1', 'name': 'Original'},
      ]);
      final received = <List<CollectionChange>>[];
      final sub = col.changes.listen(received.add);

      col.batch((scope) {
        scope.add({'id': '4', 'name': 'D'});
        scope.update('1', {'name': 'Updated'});
      });

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(col.length, 2, reason: 'successful batch applied');
      expect(col.doc('1')?['name'], 'Updated', reason: 'update applied');
      expect(received.length, 1, reason: 'one event emitted');
      expect(received.first.length, 2, reason: 'event contains both ops');

      await sub.cancel();
      await col.dispose();
    });
  });

  group('Stream Race Free', () {
    test('watchCount emits correct sequence for rapid mutations', () async {
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

      expect(received.contains(1), isTrue, reason: 'initial count emitted');
      expect(received.contains(2), isTrue,
          reason: 'count after first admin add');
      expect(received.contains(3), isTrue,
          reason: 'count after third admin add');
      expect(received.last, 3, reason: 'final state is 3 admins');

      await sub.cancel();
      await col.dispose();
    });

    test('snapshots emits initial + per-mutation', () async {
      final col = Collection.from([
        {'id': '1', 'name': 'A'},
      ]);
      final snaps = <List<Map<String, dynamic>>>[];
      final sub = col.snapshots().listen(snaps.add);

      col.add({'id': '2', 'name': 'B'});
      col.add({'id': '3', 'name': 'C'});

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(snaps.length, 3, reason: 'initial + 2 mutations');
      expect(snaps.first.length, 1, reason: 'first snapshot has initial state');
      expect(snaps.last.length, 3, reason: 'last snapshot has final state');

      await sub.cancel();
      await col.dispose();
    });
  });

  group('Filter Compilation Correctness', () {
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

    test('compiled AND with whereIn + arrayContainsAny', () {
      final result = QueryBuilder(data)
          .whereFilter(
            Filter.and([
              const Filter('role', whereIn: ['admin', 'guest']),
              const Filter('tags', arrayContainsAny: ['flutter', 'rust']),
            ]),
          )
          .build();
      expect(result.length, 3);
    });

    test('compiled OR result', () {
      final result = QueryBuilder(data)
          .whereFilter(
            Filter.or([
              const Filter('role', whereNotIn: ['admin', 'user']),
              const Filter('tags', arrayContainsAny: ['rust']),
            ]),
          )
          .build();
      expect(result.length, 2);
    });

    test('nested compiled filter', () {
      final result = QueryBuilder(data)
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
      expect(result.length, 2);
    });

    test('empty AND keeps all', () {
      expect(QueryBuilder(data).whereFilter(Filter.and([])).build().length, 4);
    });

    test('empty OR drops all', () {
      expect(QueryBuilder(data).whereFilter(Filter.or([])).build(), isEmpty);
    });

    test('single-child AND', () {
      final result = QueryBuilder(data)
          .whereFilter(Filter.and([const Filter('role', isEqualTo: 'admin')]))
          .build();
      expect(result.length, 2);
    });

    test('compiled filter perf on 50k docs', () {
      final largeData = List.generate(
        50000,
        (i) => {'id': '$i', 'group': i % 10, 'tag': 't${i % 100}'},
      );
      final sw = Stopwatch()..start();
      final result = QueryBuilder(largeData)
          .whereFilter(
            Filter.and([
              const Filter('group', whereIn: [3, 7]),
              const Filter('tag', whereNotIn: ['t10', 't20', 't30']),
            ]),
          )
          .build();
      sw.stop();
      printOnFailure(
        '50k docs compiled filter ran in ${sw.elapsedMicroseconds}μs '
        '(${result.length} matches)',
      );
      expect(result, isNotEmpty);
    });
  });
}
