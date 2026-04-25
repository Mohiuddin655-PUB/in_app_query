import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_query/src/builder.dart';
import 'package:in_app_query/src/filter.dart';

// ─── Sample Data ────────────────────────────────────────────────────────────

final _seed = [
  {
    'name': 'Rahim',
    'age': 25,
    'city': 'Dhaka',
    'tags': ['flutter', 'dart'],
    'score': 88.5,
    'active': true,
    'note': null,
  },
  {
    'name': 'Karim',
    'age': 17,
    'city': 'Chittagong',
    'tags': ['python'],
    'score': 72.0,
    'active': false,
    'note': 'new',
  },
  {
    'name': 'Salam',
    'age': 32,
    'city': 'Dhaka',
    'tags': ['dart', 'java'],
    'score': 91.0,
    'active': true,
    'note': 'senior',
  },
  {
    'name': 'Jamal',
    'age': 45,
    'city': 'Sylhet',
    'tags': ['flutter'],
    'score': 60.0,
    'active': false,
    'note': null,
  },
  {
    'name': 'Rafi',
    'age': 19,
    'city': 'Dhaka',
    'tags': ['python', 'dart'],
    'score': 78.5,
    'active': true,
    'note': 'junior',
  },
  {
    'name': 'Nasir',
    'age': 25,
    'city': 'Sylhet',
    'tags': ['flutter', 'java'],
    'score': 85.0,
    'active': true,
    'note': 'mid',
  },
  {
    'name': 'Tarek',
    'age': 25,
    'city': 'Chittagong',
    'tags': ['dart'],
    'score': 65.0,
    'active': false,
    'note': null,
  },
];

List<Map<String, dynamic>> fresh() =>
    _seed.map((e) => Map<String, dynamic>.from(e)).toList();

List<String> names(List<Map<String, dynamic>> result) =>
    result.map((d) => d['name'] as String).toList();

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  WHERE — basic predicates
  // ═════════════════════════════════════════════════════════════════════════

  group('where - isEqualTo / isNotEqualTo', () {
    test('isEqualTo filters matching docs', () {
      final r = QueryBuilder(fresh()).where('city', isEqualTo: 'Dhaka').build();
      expect(names(r), ['Rahim', 'Salam', 'Rafi']);
    });

    test('isNotEqualTo excludes matching docs', () {
      final r =
          QueryBuilder(fresh()).where('city', isNotEqualTo: 'Dhaka').build();
      expect(names(r), ['Karim', 'Jamal', 'Nasir', 'Tarek']);
    });
  });

  group('where - comparison operators', () {
    test('isGreaterThan', () {
      final r = QueryBuilder(fresh()).where('age', isGreaterThan: 25).build();
      expect(names(r), ['Salam', 'Jamal']);
    });

    test('isLessThan', () {
      final r = QueryBuilder(fresh()).where('age', isLessThan: 20).build();
      expect(names(r), ['Karim', 'Rafi']);
    });

    test('isGreaterThanOrEqualTo', () {
      final r = QueryBuilder(fresh())
          .where('age', isGreaterThanOrEqualTo: 25)
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal', 'Nasir', 'Tarek']);
    });

    test('isLessThanOrEqualTo', () {
      final r =
          QueryBuilder(fresh()).where('age', isLessThanOrEqualTo: 19).build();
      expect(names(r), ['Karim', 'Rafi']);
    });

    test('combined range — isGreaterThan + isLessThan', () {
      final r = QueryBuilder(fresh())
          .where('age', isGreaterThan: 18, isLessThan: 35)
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Rafi', 'Nasir', 'Tarek']);
    });

    test('combined range — isGreaterThanOrEqualTo + isLessThanOrEqualTo', () {
      final r = QueryBuilder(fresh())
          .where('score',
              isGreaterThanOrEqualTo: 78.5, isLessThanOrEqualTo: 91.0)
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Rafi', 'Nasir']);
    });
  });

  group('where - whereIn / whereNotIn', () {
    test('whereIn matches listed values', () {
      final r = QueryBuilder(fresh())
          .where('city', whereIn: ['Dhaka', 'Sylhet']).build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal', 'Rafi', 'Nasir']);
    });

    test('whereNotIn excludes listed values', () {
      final r =
          QueryBuilder(fresh()).where('city', whereNotIn: ['Dhaka']).build();
      expect(names(r), ['Karim', 'Jamal', 'Nasir', 'Tarek']);
    });
  });

  group('where - array operators', () {
    test('arrayContains', () {
      final r =
          QueryBuilder(fresh()).where('tags', arrayContains: 'flutter').build();
      expect(names(r), ['Rahim', 'Jamal', 'Nasir']);
    });

    test('arrayNotContains', () {
      final r = QueryBuilder(fresh())
          .where('tags', arrayNotContains: 'flutter')
          .build();
      expect(names(r), ['Karim', 'Salam', 'Rafi', 'Tarek']);
    });

    test('arrayContainsAny', () {
      final r = QueryBuilder(fresh())
          .where('tags', arrayContainsAny: ['flutter', 'java']).build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal', 'Nasir']);
    });

    test('arrayNotContainsAny', () {
      final r = QueryBuilder(fresh())
          .where('tags', arrayNotContainsAny: ['flutter', 'python']).build();
      expect(names(r), ['Salam', 'Tarek']);
    });
  });

  group('where - isNull', () {
    test('isNull: true matches null fields', () {
      final r = QueryBuilder(fresh()).where('note', isNull: true).build();
      expect(names(r), ['Rahim', 'Jamal', 'Tarek']);
    });

    test('isNull: false matches non-null fields', () {
      final r = QueryBuilder(fresh()).where('note', isNull: false).build();
      expect(names(r), ['Karim', 'Salam', 'Rafi', 'Nasir']);
    });

    test('isNull on non-existent field — all are null', () {
      final r = QueryBuilder(fresh()).where('salary', isNull: true).build();
      expect(r.length, 7);
    });
  });

  group('where - chaining (implicit AND)', () {
    test('two chained where calls', () {
      final r = QueryBuilder(fresh())
          .where('city', isEqualTo: 'Dhaka')
          .where('age', isGreaterThan: 20)
          .build();
      expect(names(r), ['Rahim', 'Salam']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  FILTER OBJECTS — compound
  // ═════════════════════════════════════════════════════════════════════════

  group('Filter.and', () {
    test('basic AND filter', () {
      final r = QueryBuilder(fresh())
          .where(Filter.and([
            Filter('city', isEqualTo: 'Dhaka'),
            Filter('age', isGreaterThan: 20),
          ]))
          .build();
      expect(names(r), ['Rahim', 'Salam']);
    });
  });

  group('Filter.or', () {
    test('basic OR filter', () {
      final r = QueryBuilder(fresh())
          .where(Filter.or([
            Filter('city', isEqualTo: 'Sylhet'),
            Filter('age', isLessThan: 18),
          ]))
          .build();
      expect(names(r), ['Karim', 'Jamal', 'Nasir']);
    });

    test('OR with sort + limit', () {
      final r = QueryBuilder(fresh())
          .where(Filter.or([
            Filter('score', isGreaterThan: 85),
            Filter('age', isLessThan: 20),
          ]))
          .orderBy('score', descending: true)
          .limit(3)
          .build();
      expect(names(r), ['Salam', 'Rahim', 'Rafi']);
    });

    test('OR preserves original order (no duplicates)', () {
      final r = QueryBuilder(fresh())
          .where(Filter.or([
            Filter('city', isEqualTo: 'Dhaka'),
            Filter('active', isEqualTo: true),
          ]))
          .build();
      // Rahim, Salam, Rafi match city==Dhaka
      // Nasir matches active==true but not city==Dhaka → added
      // No duplicates
      expect(names(r), ['Rahim', 'Salam', 'Rafi', 'Nasir']);
    });
  });

  group('Nested compound filters', () {
    test('AND inside OR', () {
      // (city==Dhaka AND age>20) OR city==Sylhet
      final r = QueryBuilder(fresh())
          .where(Filter.or([
            Filter.and([
              Filter('city', isEqualTo: 'Dhaka'),
              Filter('age', isGreaterThan: 20),
            ]),
            Filter('city', isEqualTo: 'Sylhet'),
          ]))
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal', 'Nasir']);
    });

    test('OR inside AND', () {
      // (city==Dhaka OR city==Sylhet) AND active==true
      final r = QueryBuilder(fresh())
          .where(Filter.and([
            Filter.or([
              Filter('city', isEqualTo: 'Dhaka'),
              Filter('city', isEqualTo: 'Sylhet'),
            ]),
            Filter('active', isEqualTo: true),
          ]))
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Rafi', 'Nasir']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  SORTING
  // ═════════════════════════════════════════════════════════════════════════

  group('orderBy - single field', () {
    test('ascending', () {
      final r = QueryBuilder(fresh()).orderBy('age').build();
      final ages = r.map((d) => d['age']).toList();
      expect(ages, [17, 19, 25, 25, 25, 32, 45]);
    });

    test('descending', () {
      final r = QueryBuilder(fresh()).orderBy('age', descending: true).build();
      final ages = r.map((d) => d['age']).toList();
      expect(ages, [45, 32, 25, 25, 25, 19, 17]);
    });

    test('where + orderBy', () {
      final r = QueryBuilder(fresh())
          .where('city', isEqualTo: 'Dhaka')
          .orderBy('age', descending: true)
          .build();
      expect(names(r), ['Salam', 'Rahim', 'Rafi']);
    });
  });

  group('orderBy - multi-field', () {
    test('age ASC, score ASC (tiebreaker)', () {
      final r = QueryBuilder(fresh()).orderBy('age').orderBy('score').build();
      // age=25 trio sorted by score: Tarek(65), Nasir(85), Rahim(88.5)
      expect(names(r),
          ['Karim', 'Rafi', 'Tarek', 'Nasir', 'Rahim', 'Salam', 'Jamal']);
    });

    test('age ASC, score DESC', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score', descending: true)
          .build();
      // age=25 trio sorted by score DESC: Rahim(88.5), Nasir(85), Tarek(65)
      expect(names(r),
          ['Karim', 'Rafi', 'Rahim', 'Nasir', 'Tarek', 'Salam', 'Jamal']);
    });

    test('city ASC, age DESC', () {
      final r = QueryBuilder(fresh())
          .orderBy('city')
          .orderBy('age', descending: true)
          .build();
      expect(names(r),
          ['Tarek', 'Karim', 'Salam', 'Rahim', 'Rafi', 'Jamal', 'Nasir']);
    });

    test('three-field sort: city ASC, age ASC, score DESC', () {
      final r = QueryBuilder(fresh())
          .orderBy('city')
          .orderBy('age')
          .orderBy('score', descending: true)
          .build();
      expect(names(r),
          ['Karim', 'Tarek', 'Rafi', 'Rahim', 'Salam', 'Nasir', 'Jamal']);
    });

    test('filter + multi-sort', () {
      final r = QueryBuilder(fresh())
          .where('active', isEqualTo: true)
          .orderBy('city')
          .orderBy('score', descending: true)
          .build();
      expect(names(r), ['Salam', 'Rahim', 'Rafi', 'Nasir']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  PAGINATION
  // ═════════════════════════════════════════════════════════════════════════

  group('limit / limitToLast', () {
    test('limit returns first N', () {
      final r = QueryBuilder(fresh()).orderBy('age').limit(3).build();
      expect(names(r), ['Karim', 'Rafi', 'Rahim']);
    });

    test('limitToLast returns last N', () {
      final r = QueryBuilder(fresh()).orderBy('age').limitToLast(2).build();
      expect(names(r), ['Salam', 'Jamal']);
    });

    test('limit(0) returns empty', () {
      final r = QueryBuilder(fresh()).orderBy('age').limit(0).build();
      expect(r, isEmpty);
    });

    test('limit > data length returns all', () {
      final r = QueryBuilder(fresh()).orderBy('age').limit(100).build();
      expect(r.length, 7);
    });

    test('filter + sort + limit', () {
      final r = QueryBuilder(fresh())
          .where('score', isGreaterThan: 70)
          .orderBy('score', descending: true)
          .limit(3)
          .build();
      expect(names(r), ['Salam', 'Rahim', 'Nasir']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CURSORS — single field ascending
  // ═════════════════════════════════════════════════════════════════════════

  group('cursors - single field ASC', () {
    // Sorted by age ASC: Karim(17), Rafi(19), Rahim(25), Nasir(25), Tarek(25), Salam(32), Jamal(45)

    test('startAt includes boundary', () {
      final r = QueryBuilder(fresh()).orderBy('age').startAt([25]).build();
      expect(r.length, 5);
      expect(r.every((d) => (d['age'] as int) >= 25), isTrue);
    });

    test('startAfter excludes boundary', () {
      final r = QueryBuilder(fresh()).orderBy('age').startAfter([25]).build();
      expect(names(r), ['Salam', 'Jamal']);
    });

    test('endAt includes boundary', () {
      final r = QueryBuilder(fresh()).orderBy('age').endAt([25]).build();
      expect(r.length, 5);
      expect(r.every((d) => (d['age'] as int) <= 25), isTrue);
    });

    test('endBefore excludes boundary', () {
      final r = QueryBuilder(fresh()).orderBy('age').endBefore([25]).build();
      expect(names(r), ['Karim', 'Rafi']);
    });

    test('startAt + endAt — inclusive range', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .startAt([19]).endAt([32]).build();
      expect(r.length, 5);
      expect(r.first['name'], 'Rafi');
      expect(r.last['name'], 'Salam');
    });

    test('startAfter + endBefore — exclusive range', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .startAfter([19]).endBefore([45]).build();
      expect(r.length, 4);
      expect(r.every((d) {
        final age = d['age'] as int;
        return age > 19 && age < 45;
      }), isTrue);
    });

    test('cursor past all data returns empty', () {
      final r = QueryBuilder(fresh()).orderBy('age').startAfter([100]).build();
      expect(r, isEmpty);
    });

    test('cursor before all data returns everything', () {
      final r = QueryBuilder(fresh()).orderBy('age').startAt([0]).build();
      expect(r.length, 7);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CURSORS — single field descending
  // ═════════════════════════════════════════════════════════════════════════

  group('cursors - single field DESC', () {
    // Sorted by age DESC: Jamal(45), Salam(32), Rahim(25), Nasir(25), Tarek(25), Rafi(19), Karim(17)

    test('startAt in DESC — includes boundary and after', () {
      final r = QueryBuilder(fresh())
          .orderBy('age', descending: true)
          .startAt([25]).build();
      // In DESC order, startAt(25) means "from 25 onward" → 25,25,25,19,17
      expect(r.length, 5);
      expect(r.first['age'], 25);
      expect(r.last['age'], 17);
    });

    test('startAfter in DESC — excludes boundary', () {
      final r = QueryBuilder(fresh())
          .orderBy('age', descending: true)
          .startAfter([25]).build();
      // After 25 in DESC → 19, 17
      expect(names(r), ['Rafi', 'Karim']);
    });

    test('endAt in DESC — includes boundary and before', () {
      final r = QueryBuilder(fresh())
          .orderBy('age', descending: true)
          .endAt([25]).build();
      // Up to 25 in DESC → 45, 32, 25, 25, 25
      expect(r.length, 5);
      expect(r.first['age'], 45);
      expect(r.last['age'], 25);
    });

    test('endBefore in DESC — excludes boundary', () {
      final r = QueryBuilder(fresh())
          .orderBy('age', descending: true)
          .endBefore([25]).build();
      // Before 25 in DESC → 45, 32
      expect(names(r), ['Jamal', 'Salam']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CURSORS — multi-field
  // ═════════════════════════════════════════════════════════════════════════

  group('cursors - multi-field', () {
    // orderBy age ASC, score ASC:
    // Karim(17,72), Rafi(19,78.5), Tarek(25,65), Nasir(25,85), Rahim(25,88.5), Salam(32,91), Jamal(45,60)

    test('startAt with two values', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .startAt([25, 85.0]).build();
      expect(names(r), ['Nasir', 'Rahim', 'Salam', 'Jamal']);
    });

    test('startAfter with two values', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .startAfter([25, 85.0]).build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal']);
    });

    test('endAt with two values', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .endAt([25, 85.0]).build();
      expect(names(r), ['Karim', 'Rafi', 'Tarek', 'Nasir']);
    });

    test('startAt + endAt multi-field window', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .startAt([19, 78.5]).endAt([25, 85.0]).build();
      expect(names(r), ['Rafi', 'Tarek', 'Nasir']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CURSORS — document-based
  // ═════════════════════════════════════════════════════════════════════════

  group('cursors - document-based', () {
    final pivot = {'age': 25, 'score': 85.0};

    test('startAtDocument', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .startAtDocument(pivot)
          .build();
      expect(names(r), ['Nasir', 'Rahim', 'Salam', 'Jamal']);
    });

    test('startAfterDocument', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .startAfterDocument(pivot)
          .build();
      expect(names(r), ['Rahim', 'Salam', 'Jamal']);
    });

    test('endAtDocument', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .endAtDocument(pivot)
          .build();
      expect(names(r), ['Karim', 'Rafi', 'Tarek', 'Nasir']);
    });

    test('endBeforeDocument', () {
      final r = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('score')
          .endBeforeDocument(pivot)
          .build();
      expect(names(r), ['Karim', 'Rafi', 'Tarek']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  PAGE WALK simulation
  // ═════════════════════════════════════════════════════════════════════════

  group('page walk with unique tiebreaker', () {
    test('paginating through all docs with age+name', () {
      // Unique tiebreaker ensures no docs are lost
      final all = QueryBuilder(fresh()).orderBy('age').orderBy('name').build();

      final page1 =
          QueryBuilder(fresh()).orderBy('age').orderBy('name').limit(3).build();
      expect(page1.length, 3);

      final page2 = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('name')
          .startAfterDocument(page1.last)
          .limit(3)
          .build();
      expect(page2.length, 3);

      final page3 = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('name')
          .startAfterDocument(page2.last)
          .limit(3)
          .build();
      expect(page3.length, 1);

      final page4 = QueryBuilder(fresh())
          .orderBy('age')
          .orderBy('name')
          .startAfterDocument(page3.last)
          .limit(3)
          .build();
      expect(page4, isEmpty);

      // All docs accounted for
      final collected = [...page1, ...page2, ...page3];
      expect(collected.length, all.length);
      expect(names(collected), names(all));
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  FULL PIPELINE — filter + sort + cursor + limit
  // ═════════════════════════════════════════════════════════════════════════

  group('full pipeline', () {
    test('filter + DESC sort + cursor + limit', () {
      final r = QueryBuilder(fresh())
          .where('active', isEqualTo: true)
          .orderBy('score', descending: true)
          .startAt([88.5])
          .limit(2)
          .build();
      // active docs by score DESC: Salam(91), Rahim(88.5), Nasir(85), Rafi(78.5)
      // startAt(88.5) in DESC → Rahim(88.5), Nasir(85), Rafi(78.5)
      // limit 2 → Rahim, Nasir
      expect(names(r), ['Rahim', 'Nasir']);
    });

    test('filter + multi-sort + cursor window', () {
      final r = QueryBuilder(fresh())
          .where('age', isGreaterThan: 18)
          .orderBy('city')
          .orderBy('score', descending: true)
          .startAt(['Dhaka', 90]).endAt(['Sylhet', 80]).build();
      expect(names(r), ['Rahim', 'Rafi', 'Nasir']);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  EDGE CASES
  // ═════════════════════════════════════════════════════════════════════════

  group('edge cases', () {
    test('empty data source', () {
      final r = QueryBuilder([]).where('age', isGreaterThan: 10).build();
      expect(r, isEmpty);
    });

    test('no conditions returns all', () {
      final r = QueryBuilder(fresh()).build();
      expect(r.length, 7);
    });

    test('where on non-existent field returns empty (isGreaterThan)', () {
      final r =
          QueryBuilder(fresh()).where('salary', isGreaterThan: 1000).build();
      expect(r, isEmpty);
    });

    test('build returns unmodifiable list', () {
      final r = QueryBuilder(fresh()).build();
      expect(() => r.add({}), throwsUnsupportedError);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  ASYNC EXECUTE
  // ═════════════════════════════════════════════════════════════════════════

  group('execute', () {
    test('execute returns same result as build', () async {
      final qb = QueryBuilder(fresh()).where('city', isEqualTo: 'Dhaka');
      final sync = qb.build();
      final asyncResult = await qb.execute(1);
      expect(names(asyncResult), names(sync));
    });

    test('execute with 0 delay', () async {
      final r = await QueryBuilder(fresh())
          .where('active', isEqualTo: true)
          .execute(0);
      expect(r.length, 4);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  TYPE MISMATCH — cross-type behavior
  // ═════════════════════════════════════════════════════════════════════════

  group('type mismatch - isEqualTo / isNotEqualTo (safe, no crash)', () {
    test('int field vs string value → no match', () {
      // age is int, comparing with String '25' → Dart == returns false
      final r = QueryBuilder(fresh()).where('age', isEqualTo: '25').build();
      expect(r, isEmpty);
    });

    test('string field vs int value → no match', () {
      final r = QueryBuilder(fresh()).where('city', isEqualTo: 123).build();
      expect(r, isEmpty);
    });

    test('isNotEqualTo with wrong type → everything passes', () {
      // 25 != '25' is true for all, so nothing gets excluded
      final r = QueryBuilder(fresh()).where('age', isNotEqualTo: '25').build();
      expect(r.length, 7);
    });

    test('bool field vs string value → no match', () {
      final r =
          QueryBuilder(fresh()).where('active', isEqualTo: 'true').build();
      expect(r, isEmpty);
    });

    test('int vs double — Dart treats 25 == 25.0 as false', () {
      // Dart: 25 == 25.0 → true for num, but depends on runtime
      // This test documents actual behavior
      final r = QueryBuilder(fresh()).where('age', isEqualTo: 25.0).build();
      // In Dart, int 25 == double 25.0 is true
      expect(r.length, 3); // Rahim, Nasir, Tarek all age 25
    });
  });

  group('type mismatch - comparison operators', () {
    // ─ Cross-type between Comparables (int↔String, etc.) → THROWS
    test('isGreaterThan: int field vs string → throws', () {
      expect(
        () => QueryBuilder(fresh()).where('age', isGreaterThan: '25').build(),
        throwsA(isA<TypeError>()),
      );
    });

    test('isLessThan: int field vs string → throws', () {
      expect(
        () => QueryBuilder(fresh()).where('age', isLessThan: '10').build(),
        throwsA(isA<TypeError>()),
      );
    });

    test('isGreaterThanOrEqualTo: string field vs int → throws', () {
      expect(
        () => QueryBuilder(fresh())
            .where('city', isGreaterThanOrEqualTo: 100)
            .build(),
        throwsA(isA<TypeError>()),
      );
    });

    // ─ Non-Comparable types (bool, Map, etc.) → silent fail, no crash
    test(
        'isLessThanOrEqualTo: string field vs bool → no match (bool not Comparable)',
        () {
      // bool does NOT implement Comparable, so the `b is Comparable` check
      // short-circuits and _isLessThanOrEqual returns false silently.
      final r = QueryBuilder(fresh())
          .where('city', isLessThanOrEqualTo: true)
          .build();
      expect(r, isEmpty);
    });

    test('isGreaterThan: int field vs bool → no match (bool not Comparable)',
        () {
      final r = QueryBuilder(fresh()).where('age', isGreaterThan: true).build();
      expect(r, isEmpty);
    });

    // ─ Compatible numeric types work
    test('int vs double comparison works fine (both are num)', () {
      final r = QueryBuilder(fresh()).where('age', isGreaterThan: 25.0).build();
      expect(names(r), ['Salam', 'Jamal']);
    });
  });

  group('type mismatch - array operators (safe)', () {
    test('arrayContains on non-list field → returns empty', () {
      // 'age' is int, not Iterable
      final r = QueryBuilder(fresh()).where('age', arrayContains: 25).build();
      expect(r, isEmpty);
    });

    test('arrayContains with wrong element type → no match', () {
      // tags is List<String>, looking for int
      final r = QueryBuilder(fresh()).where('tags', arrayContains: 123).build();
      expect(r, isEmpty);
    });

    test('arrayContainsAny on non-list field → returns empty', () {
      final r = QueryBuilder(fresh())
          .where('name', arrayContainsAny: ['Rahim']).build();
      expect(r, isEmpty);
    });

    test('arrayNotContains on non-list field → returns all', () {
      // 'age' is not Iterable, _iterableContains returns false
      // arrayNotContains check: _iterableContains(value, x) → false
      // so the filter does NOT exclude → all docs pass
      final r =
          QueryBuilder(fresh()).where('age', arrayNotContains: 25).build();
      expect(r.length, 7);
    });
  });

  group('type mismatch - whereIn / whereNotIn (safe)', () {
    test('whereIn with wrong types → no match', () {
      // age is int, searching in list of strings
      final r =
          QueryBuilder(fresh()).where('age', whereIn: ['25', '17']).build();
      expect(r, isEmpty);
    });

    test('whereNotIn with wrong types → everything passes', () {
      // '25' != 25, so nothing gets excluded
      final r = QueryBuilder(fresh()).where('age', whereNotIn: ['25']).build();
      expect(r.length, 7);
    });

    test('whereIn mixed types — only matching type matches', () {
      // Mix of int and string, only int 25 matches
      final r = QueryBuilder(fresh()).where('age', whereIn: [25, '17']).build();
      expect(names(r), ['Rahim', 'Nasir', 'Tarek']);
    });
  });

  group('type mismatch - isNull (safe)', () {
    test('isNull on a field with mixed nulls', () {
      final r = QueryBuilder(fresh()).where('note', isNull: true).build();
      expect(names(r), ['Rahim', 'Jamal', 'Tarek']);
    });

    test('isNull ignores field type entirely', () {
      // Works on any field — just checks null/not-null
      final r = QueryBuilder(fresh()).where('tags', isNull: false).build();
      expect(r.length, 7); // all have tags
    });
  });

  group('type mismatch - sorting', () {
    test('sorting mixed with non-Comparable type — does not throw', () {
      // bool is not Comparable → _compare returns 0 → sort stable.
      final mixed = [
        {'val': 10},
        {'val': true},
        {'val': 3},
      ];
      final r = QueryBuilder(mixed).orderBy('val').build();
      expect(r.length, 3);
    });

    test('sorting with null values — nulls go to end', () {
      final withNulls = [
        {'name': 'A', 'rank': 3},
        {'name': 'B', 'rank': null},
        {'name': 'C', 'rank': 1},
      ];
      final r = QueryBuilder(withNulls).orderBy('rank').build();
      expect(r[0]['name'], 'C');
      expect(r[1]['name'], 'A');
      expect(r[2]['name'], 'B'); // null last
    });

    test('sorting with missing field — treated as null', () {
      final partial = [
        {'name': 'A', 'rank': 2},
        {'name': 'B'},
        {'name': 'C', 'rank': 1},
      ];
      final r = QueryBuilder(partial).orderBy('rank').build();
      expect(r[0]['name'], 'C');
      expect(r[1]['name'], 'A');
      expect(r[2]['name'], 'B'); // missing = null = last
    });
  });

  group('type mismatch - Filter object (safe)', () {
    test('Filter with wrong type isEqualTo → no match', () {
      final r =
          QueryBuilder(fresh()).where(Filter('age', isEqualTo: '25')).build();
      expect(r, isEmpty);
    });

    test('Filter.and with one wrong type → no match', () {
      final r = QueryBuilder(fresh())
          .where(Filter.and([
            Filter('city', isEqualTo: 'Dhaka'),
            Filter('age', isEqualTo: '25'), // wrong type
          ]))
          .build();
      expect(r, isEmpty);
    });

    test('Filter with wrong type comparison (Comparable) throws', () {
      expect(
        () => QueryBuilder(fresh())
            .where(Filter('age', isGreaterThan: 'abc'))
            .build(),
        throwsA(isA<TypeError>()),
      );
    });

    test('Filter with non-Comparable comparison value → no match', () {
      // bool is not Comparable
      final r = QueryBuilder(fresh())
          .where(Filter('age', isGreaterThan: true))
          .build();
      expect(r, isEmpty);
    });
  });

  group('type mismatch - cursor', () {
    test('cursor with non-Comparable type → no crash, _compare returns 0', () {
      // bool is not Comparable → _compare returns 0 → all docs treated as equal
      expect(
        () => QueryBuilder(fresh()).orderBy('age').startAt([true]).build(),
        returnsNormally,
      );
    });

    test('cursor with compatible numeric type works', () {
      // int field, double cursor value — num.compareTo(num) is valid
      final r = QueryBuilder(fresh()).orderBy('age').startAt([25.0]).build();
      expect(r.length, 5);
    });
  });
}
