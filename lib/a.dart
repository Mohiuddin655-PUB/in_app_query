// ─── Sample Data ──────────────────────────────────────────────────────────────

import 'package:in_app_query/src/builder.dart';
import 'package:in_app_query/src/filter.dart';

final data = [
  {
    'name': 'Rahim',
    'age': 25,
    'city': 'Dhaka',
    'tags': ['flutter', 'dart'],
    'score': 88.5,
    'active': true,
    'note': null
  },
  {
    'name': 'Karim',
    'age': 17,
    'city': 'Chittagong',
    'tags': ['python'],
    'score': 72.0,
    'active': false,
    'note': 'new'
  },
  {
    'name': 'Salam',
    'age': 32,
    'city': 'Dhaka',
    'tags': ['dart', 'java'],
    'score': 91.0,
    'active': true,
    'note': 'senior'
  },
  {
    'name': 'Jamal',
    'age': 45,
    'city': 'Sylhet',
    'tags': ['flutter'],
    'score': 60.0,
    'active': false,
    'note': null
  },
  {
    'name': 'Rafi',
    'age': 19,
    'city': 'Dhaka',
    'tags': ['python', 'dart'],
    'score': 78.5,
    'active': true,
    'note': 'junior'
  },
  {
    'name': 'Nasir',
    'age': 25,
    'city': 'Sylhet',
    'tags': ['flutter', 'java'],
    'score': 85.0,
    'active': true,
    'note': 'mid'
  },
  {
    'name': 'Tarek',
    'age': 25,
    'city': 'Chittagong',
    'tags': ['dart'],
    'score': 65.0,
    'active': false,
    'note': null
  },
];

// ─── Helper ───────────────────────────────────────────────────────────────────

List<Map<String, dynamic>> fresh() =>
    data.map((e) => Map<String, dynamic>.from(e)).toList();

void printResult(String label, List<Map<String, dynamic>> result) {
  print('\n──────────────────────────────');
  print('🔍 $label');
  print('──────────────────────────────');
  if (result.isEmpty) {
    print('  (empty)');
  } else {
    for (var doc in result) {
      print('  $doc');
    }
  }
  print('Total: ${result.length}');
}

// ─── Main ─────────────────────────────────────────────────────────────────────

void main() async {
  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 1: Basic Filters
  // ═══════════════════════════════════════════════════════════════════════════

  // 1. isEqualTo
  printResult(
    'city == Dhaka',
    QueryBuilder(fresh()).where('city', isEqualTo: 'Dhaka').build(),
  );

  // 2. isNotEqualTo
  printResult(
    'city != Dhaka',
    QueryBuilder(fresh()).where('city', isNotEqualTo: 'Dhaka').build(),
  );

  // 3. isGreaterThan
  printResult(
    'age > 25',
    QueryBuilder(fresh()).where('age', isGreaterThan: 25).build(),
  );

  // 4. isLessThan
  printResult(
    'age < 20',
    QueryBuilder(fresh()).where('age', isLessThan: 20).build(),
  );

  // 5. Range — AND logic
  printResult(
    'age > 18 AND age < 35',
    QueryBuilder(fresh())
        .where('age', isGreaterThan: 18, isLessThan: 35)
        .build(),
  );

  // 6. isGreaterThanOrEqualTo + isLessThanOrEqualTo
  printResult(
    'score >= 78.5 AND score <= 91.0',
    QueryBuilder(fresh())
        .where('score',
        isGreaterThanOrEqualTo: 78.5, isLessThanOrEqualTo: 91.0)
        .build(),
  );

  // 7. whereIn
  printResult(
    'city in [Dhaka, Sylhet]',
    QueryBuilder(fresh()).where('city', whereIn: ['Dhaka', 'Sylhet']).build(),
  );

  // 8. whereNotIn
  printResult(
    'city not in [Dhaka]',
    QueryBuilder(fresh()).where('city', whereNotIn: ['Dhaka']).build(),
  );

  // 9. arrayContains
  printResult(
    'tags contains flutter',
    QueryBuilder(fresh()).where('tags', arrayContains: 'flutter').build(),
  );

  // 10. arrayNotContains
  printResult(
    'tags not contains flutter',
    QueryBuilder(fresh()).where('tags', arrayNotContains: 'flutter').build(),
  );

  // 11. arrayContainsAny
  printResult(
    'tags contains any of [flutter, java]',
    QueryBuilder(fresh())
        .where('tags', arrayContainsAny: ['flutter', 'java'])
        .build(),
  );

  // 12. arrayNotContainsAny
  printResult(
    'tags not contains any of [flutter, python]',
    QueryBuilder(fresh())
        .where('tags', arrayNotContainsAny: ['flutter', 'python'])
        .build(),
  );

  // 13. isNull = true
  printResult(
    'note is null',
    QueryBuilder(fresh()).where('note', isNull: true).build(),
  );

  // 14. isNull = false
  printResult(
    'note is not null',
    QueryBuilder(fresh()).where('note', isNull: false).build(),
  );

  // 15. where chaining (implicit AND)
  printResult(
    'city == Dhaka AND age > 20',
    QueryBuilder(fresh())
        .where('city', isEqualTo: 'Dhaka')
        .where('age', isGreaterThan: 20)
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 2: Single Sort
  // ═══════════════════════════════════════════════════════════════════════════

  // 16. orderBy ascending
  printResult(
    'orderBy age ASC',
    QueryBuilder(fresh()).orderBy('age').build(),
  );

  // 17. orderBy descending
  printResult(
    'orderBy age DESC',
    QueryBuilder(fresh()).orderBy('age', descending: true).build(),
  );

  // 18. where + orderBy
  printResult(
    'city == Dhaka, orderBy age DESC',
    QueryBuilder(fresh())
        .where('city', isEqualTo: 'Dhaka')
        .orderBy('age', descending: true)
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 3: Multi-Field Sort
  // ═══════════════════════════════════════════════════════════════════════════

  // 19. Two-field sort — age ASC, then score ASC (tiebreaker)
  // Rahim(25,88.5), Nasir(25,85.0), Tarek(25,65.0) — same age, score breaks tie
  printResult(
    'orderBy age ASC, then score ASC',
    QueryBuilder(fresh()).orderBy('age').orderBy('score').build(),
  );

  // 20. Two-field sort — age ASC, then score DESC
  printResult(
    'orderBy age ASC, then score DESC',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score', descending: true)
        .build(),
  );

  // 21. Two-field sort — city ASC, then age DESC
  printResult(
    'orderBy city ASC, then age DESC',
    QueryBuilder(fresh())
        .orderBy('city')
        .orderBy('age', descending: true)
        .build(),
  );

  // 22. Three-field sort — city ASC, age ASC, score DESC
  printResult(
    'orderBy city ASC, age ASC, score DESC',
    QueryBuilder(fresh())
        .orderBy('city')
        .orderBy('age')
        .orderBy('score', descending: true)
        .build(),
  );

  // 23. Filter + multi-sort
  printResult(
    'active == true, orderBy city ASC, then score DESC',
    QueryBuilder(fresh())
        .where('active', isEqualTo: true)
        .orderBy('city')
        .orderBy('score', descending: true)
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 4: Pagination
  // ═══════════════════════════════════════════════════════════════════════════

  // 24. limit
  printResult(
    'orderBy age ASC, limit 3',
    QueryBuilder(fresh()).orderBy('age').limit(3).build(),
  );

  // 25. limitToLast
  printResult(
    'orderBy age ASC, limitToLast 2',
    QueryBuilder(fresh()).orderBy('age').limitToLast(2).build(),
  );

  // 26. Filter + sort + limit
  printResult(
    'score > 70, orderBy score DESC, limit 3',
    QueryBuilder(fresh())
        .where('score', isGreaterThan: 70)
        .orderBy('score', descending: true)
        .limit(3)
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 5: Cursors — Single Field
  // ═══════════════════════════════════════════════════════════════════════════

  // 27. startAt — ascending
  // age sorted ASC: 17, 19, 25, 25, 25, 32, 45
  // startAt(25) → should include 25, 25, 25, 32, 45
  printResult(
    'orderBy age ASC → startAt(25)',
    QueryBuilder(fresh()).orderBy('age').startAt([25]).build(),
  );

  // 28. startAfter — ascending
  // startAfter(25) → should skip all 25s, give 32, 45
  printResult(
    'orderBy age ASC → startAfter(25)',
    QueryBuilder(fresh()).orderBy('age').startAfter([25]).build(),
  );

  // 29. endAt — ascending
  // endAt(25) → should include 17, 19, 25, 25, 25
  printResult(
    'orderBy age ASC → endAt(25)',
    QueryBuilder(fresh()).orderBy('age').endAt([25]).build(),
  );

  // 30. endBefore — ascending
  // endBefore(25) → should give 17, 19
  printResult(
    'orderBy age ASC → endBefore(25)',
    QueryBuilder(fresh()).orderBy('age').endBefore([25]).build(),
  );

  // 31. startAt + endAt — range window
  // age 19..32 inclusive
  printResult(
    'orderBy age ASC → startAt(19) + endAt(32)',
    QueryBuilder(fresh()).orderBy('age').startAt([19]).endAt([32]).build(),
  );

  // 32. startAfter + endBefore — exclusive range
  // age strictly between 19 and 45
  printResult(
    'orderBy age ASC → startAfter(19) + endBefore(45)',
    QueryBuilder(fresh())
        .orderBy('age')
        .startAfter([19])
        .endBefore([45])
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 6: Cursors — Descending
  //  ⚠️ This is where the _cursorCompare bug shows up if unfixed
  // ═══════════════════════════════════════════════════════════════════════════

  // 33. startAt — descending
  // age sorted DESC: 45, 32, 25, 25, 25, 19, 17
  // startAt(25) in DESC → should include 25, 25, 25, 19, 17
  printResult(
    'orderBy age DESC → startAt(25)  ⚠️ bug test',
    QueryBuilder(fresh())
        .orderBy('age', descending: true)
        .startAt([25])
        .build(),
  );

  // 34. startAfter — descending
  // startAfter(25) in DESC → should give 19, 17
  printResult(
    'orderBy age DESC → startAfter(25)  ⚠️ bug test',
    QueryBuilder(fresh())
        .orderBy('age', descending: true)
        .startAfter([25])
        .build(),
  );

  // 35. endAt — descending
  // endAt(25) in DESC → should give 45, 32, 25, 25, 25
  printResult(
    'orderBy age DESC → endAt(25)  ⚠️ bug test',
    QueryBuilder(fresh())
        .orderBy('age', descending: true)
        .endAt([25])
        .build(),
  );

  // 36. endBefore — descending
  // endBefore(25) in DESC → should give 45, 32
  printResult(
    'orderBy age DESC → endBefore(25)  ⚠️ bug test',
    QueryBuilder(fresh())
        .orderBy('age', descending: true)
        .endBefore([25])
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 7: Cursors — Multi-Field Sort
  // ═══════════════════════════════════════════════════════════════════════════

  // Sorted by age ASC, score ASC:
  //   Karim(17,72), Rafi(19,78.5), Tarek(25,65), Nasir(25,85), Rahim(25,88.5), Salam(32,91), Jamal(45,60)
  final multiSorted =
  QueryBuilder(fresh()).orderBy('age').orderBy('score').build();
  printResult('Reference: orderBy age ASC, score ASC', multiSorted);

  // 37. startAt with two values — age=25, score=85.0
  // Should include: Nasir(25,85), Rahim(25,88.5), Salam(32,91), Jamal(45,60)
  printResult(
    'orderBy age ASC, score ASC → startAt(25, 85.0)',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .startAt([25, 85.0])
        .build(),
  );

  // 38. startAfter with two values — age=25, score=85.0
  // Should skip Nasir(25,85), give: Rahim(25,88.5), Salam(32,91), Jamal(45,60)
  printResult(
    'orderBy age ASC, score ASC → startAfter(25, 85.0)',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .startAfter([25, 85.0])
        .build(),
  );

  // 39. endAt with two values — age=25, score=85.0
  // Should include: Karim(17,72), Rafi(19,78.5), Tarek(25,65), Nasir(25,85)
  printResult(
    'orderBy age ASC, score ASC → endAt(25, 85.0)',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .endAt([25, 85.0])
        .build(),
  );

  // 40. startAt + endAt multi-field window
  // From (19, 78.5) to (25, 85.0) inclusive
  printResult(
    'orderBy age ASC, score ASC → startAt(19,78.5) + endAt(25,85.0)',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .startAt([19, 78.5])
        .endAt([25, 85.0])
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 8: Cursors — Document-Based
  // ═══════════════════════════════════════════════════════════════════════════

  // 41. startAtDocument
  final pivot = {'age': 25, 'score': 85.0};
  printResult(
    'orderBy age ASC, score ASC → startAtDocument({age:25, score:85})',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .startAtDocument(pivot)
        .build(),
  );

  // 42. startAfterDocument
  printResult(
    'orderBy age ASC, score ASC → startAfterDocument({age:25, score:85})',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .startAfterDocument(pivot)
        .build(),
  );

  // 43. endAtDocument
  printResult(
    'orderBy age ASC, score ASC → endAtDocument({age:25, score:85})',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .endAtDocument(pivot)
        .build(),
  );

  // 44. endBeforeDocument
  printResult(
    'orderBy age ASC, score ASC → endBeforeDocument({age:25, score:85})',
    QueryBuilder(fresh())
        .orderBy('age')
        .orderBy('score')
        .endBeforeDocument(pivot)
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 9: Cursor + Pagination (simulated page walk)
  // ═══════════════════════════════════════════════════════════════════════════

  // 45. Page 1: first 3 by age
  final page1 = QueryBuilder(fresh()).orderBy('age').limit(3).build();
  printResult('Page 1: orderBy age ASC, limit 3', page1);

  // 46. Page 2: startAfter last doc from page 1, limit 3
  final lastOfPage1 = page1.last;
  final page2 = QueryBuilder(fresh())
      .orderBy('age')
      .startAfterDocument(lastOfPage1)
      .limit(3)
      .build();
  printResult(
    'Page 2: startAfterDocument(${lastOfPage1['name']}), limit 3',
    page2,
  );

  // 47. Page 3: startAfter last doc from page 2
  final lastOfPage2 = page2.last;
  final page3 = QueryBuilder(fresh())
      .orderBy('age')
      .startAfterDocument(lastOfPage2)
      .limit(3)
      .build();
  printResult(
    'Page 3: startAfterDocument(${lastOfPage2['name']}), limit 3',
    page3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 10: Compound Filters
  // ═══════════════════════════════════════════════════════════════════════════

  // 48. Filter.and
  printResult(
    'Filter.and → city==Dhaka AND age>20',
    QueryBuilder(fresh())
        .where(Filter.and([
      Filter('city', isEqualTo: 'Dhaka'),
      Filter('age', isGreaterThan: 20),
    ]))
        .build(),
  );

  // 49. Filter.or
  printResult(
    'Filter.or → city==Sylhet OR age<18',
    QueryBuilder(fresh())
        .where(Filter.or([
      Filter('city', isEqualTo: 'Sylhet'),
      Filter('age', isLessThan: 18),
    ]))
        .build(),
  );

  // 50. Filter.or with sort + limit
  printResult(
    'Filter.or → (score>85 OR age<20), orderBy score DESC, limit 3',
    QueryBuilder(fresh())
        .where(Filter.or([
      Filter('score', isGreaterThan: 85),
      Filter('age', isLessThan: 20),
    ]))
        .orderBy('score', descending: true)
        .limit(3)
        .build(),
  );

  // 51. Nested: AND inside OR
  //   (city==Dhaka AND age>20) OR (city==Sylhet)
  printResult(
    'Nested: (city==Dhaka AND age>20) OR city==Sylhet',
    QueryBuilder(fresh())
        .where(Filter.or([
      Filter.and([
        Filter('city', isEqualTo: 'Dhaka'),
        Filter('age', isGreaterThan: 20),
      ]),
      Filter('city', isEqualTo: 'Sylhet'),
    ]))
        .build(),
  );

  // 52. Nested: OR inside AND
  //   (city==Dhaka OR city==Sylhet) AND active==true
  printResult(
    'Nested: (city==Dhaka OR city==Sylhet) AND active==true',
    QueryBuilder(fresh())
        .where(Filter.and([
      Filter.or([
        Filter('city', isEqualTo: 'Dhaka'),
        Filter('city', isEqualTo: 'Sylhet'),
      ]),
      Filter('active', isEqualTo: true),
    ]))
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 11: Full Pipeline — Filter + Sort + Cursor + Limit
  // ═══════════════════════════════════════════════════════════════════════════

  // 53. Full pipeline
  printResult(
    'active==true, orderBy score DESC, startAt(88.5), limit 2',
    QueryBuilder(fresh())
        .where('active', isEqualTo: true)
        .orderBy('score', descending: true)
        .startAt([88.5])
        .limit(2)
        .build(),
  );

  // 54. Full pipeline with multi-sort cursor
  printResult(
    'age>18, orderBy city ASC + score DESC, startAt(Dhaka, 90), endAt(Sylhet, 80)',
    QueryBuilder(fresh())
        .where('age', isGreaterThan: 18)
        .orderBy('city')
        .orderBy('score', descending: true)
        .startAt(['Dhaka', 90])
        .endAt(['Sylhet', 80])
        .build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 12: Edge Cases
  // ═══════════════════════════════════════════════════════════════════════════

  // 55. Empty data
  printResult(
    'empty data source',
    QueryBuilder([]).where('age', isGreaterThan: 10).build(),
  );

  // 56. No conditions — returns all
  printResult(
    'no conditions (returns all)',
    QueryBuilder(fresh()).build(),
  );

  // 57. Non-existent field — nothing matches
  printResult(
    'where on non-existent field',
    QueryBuilder(fresh()).where('salary', isGreaterThan: 1000).build(),
  );

  // 58. Non-existent field isNull=true — all match (field missing = null)
  printResult(
    'non-existent field isNull=true',
    QueryBuilder(fresh()).where('salary', isNull: true).build(),
  );

  // 59. Limit 0 — empty result
  printResult(
    'limit(0)',
    QueryBuilder(fresh()).orderBy('age').limit(0).build(),
  );

  // 60. Limit bigger than data
  printResult(
    'limit(100) on 7 docs',
    QueryBuilder(fresh()).orderBy('age').limit(100).build(),
  );

  // 61. Cursor past all data — empty
  printResult(
    'orderBy age ASC, startAfter(100) → empty',
    QueryBuilder(fresh()).orderBy('age').startAfter([100]).build(),
  );

  // 62. Cursor before all data — returns everything
  printResult(
    'orderBy age ASC, startAt(0) → all',
    QueryBuilder(fresh()).orderBy('age').startAt([0]).build(),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  SECTION 13: Async Execute
  // ═══════════════════════════════════════════════════════════════════════════

  // 63. execute async
  print('\n──────────────────────────────');
  print('🔍 execute() async — city == Dhaka');
  print('──────────────────────────────');
  final asyncResult = await QueryBuilder(fresh())
      .where('city', isEqualTo: 'Dhaka')
      .execute(100);
  for (var doc in asyncResult) {
    print('  $doc');
  }
  print('Total: ${asyncResult.length}');
}