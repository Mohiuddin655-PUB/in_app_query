
// ─── Sample Data ──────────────────────────────────────────────────────────────

import 'package:in_app_query/src/builder.dart';
import 'package:in_app_query/src/filter.dart';

final data = [
  {'name': 'Rahim', 'age': 25, 'city': 'Dhaka',      'tags': ['flutter', 'dart'], 'score': 88.5, 'active': true,  'note': null},
  {'name': 'Karim', 'age': 17, 'city': 'Chittagong', 'tags': ['python'],           'score': 72.0, 'active': false, 'note': 'new'},
  {'name': 'Salam', 'age': 32, 'city': 'Dhaka',      'tags': ['dart', 'java'],    'score': 91.0, 'active': true,  'note': 'senior'},
  {'name': 'Jamal', 'age': 45, 'city': 'Sylhet',     'tags': ['flutter'],         'score': 60.0, 'active': false, 'note': null},
  {'name': 'Rafi',  'age': 19, 'city': 'Dhaka',      'tags': ['python', 'dart'],  'score': 78.5, 'active': true,  'note': 'junior'},
];

// ─── Helper ───────────────────────────────────────────────────────────────────

List<Map<String, dynamic>> fresh() =>
    data.map((e) => Map<String, dynamic>.from(e)).toList();

void print_result(String label, List<Map<String, dynamic>> result) {
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
  // 1. isEqualTo
  print_result(
    'city == Dhaka',
    QueryBuilder(fresh()).where('city', isEqualTo: 'Dhaka').build(),
  );

  // 2. isNotEqualTo
  print_result(
    'city != Dhaka',
    QueryBuilder(fresh()).where('city', isNotEqualTo: 'Dhaka').build(),
  );

  // 3. isGreaterThan
  print_result(
    'age > 25',
    QueryBuilder(fresh()).where('age', isGreaterThan: 25).build(),
  );

  // 4. isLessThan
  print_result(
    'age < 20',
    QueryBuilder(fresh()).where('age', isLessThan: 20).build(),
  );

  // 5. Range — AND logic (most important test)
  print_result(
    'age > 18 AND age < 35',
    QueryBuilder(fresh())
        .where('age', isGreaterThan: 18, isLessThan: 35)
        .build(),
  );

  // 6. isGreaterThanOrEqualTo + isLessThanOrEqualTo
  print_result(
    'score >= 78.5 AND score <= 91.0',
    QueryBuilder(fresh())
        .where('score', isGreaterThanOrEqualTo: 78.5, isLessThanOrEqualTo: 91.0)
        .build(),
  );

  // 7. whereIn
  print_result(
    'city in [Dhaka, Sylhet]',
    QueryBuilder(fresh())
        .where('city', whereIn: ['Dhaka', 'Sylhet'])
        .build(),
  );

  // 8. whereNotIn
  print_result(
    'city not in [Dhaka]',
    QueryBuilder(fresh())
        .where('city', whereNotIn: ['Dhaka'])
        .build(),
  );

  // 9. arrayContains
  print_result(
    'tags contains flutter',
    QueryBuilder(fresh()).where('tags', arrayContains: 'flutter').build(),
  );

  // 10. arrayNotContains
  print_result(
    'tags not contains flutter',
    QueryBuilder(fresh()).where('tags', arrayNotContains: 'flutter').build(),
  );

  // 11. arrayContainsAny
  print_result(
    'tags contains any of [flutter, java]',
    QueryBuilder(fresh())
        .where('tags', arrayContainsAny: ['flutter', 'java'])
        .build(),
  );

  // 12. arrayNotContainsAny
  print_result(
    'tags not contains any of [flutter, python]',
    QueryBuilder(fresh())
        .where('tags', arrayNotContainsAny: ['flutter', 'python'])
        .build(),
  );

  // 13. isNull = true
  print_result(
    'note is null',
    QueryBuilder(fresh()).where('note', isNull: true).build(),
  );

  // 14. isNull = false
  print_result(
    'note is not null',
    QueryBuilder(fresh()).where('note', isNull: false).build(),
  );

  // 15. where chaining
  print_result(
    'city == Dhaka AND age > 20',
    QueryBuilder(fresh())
        .where('city', isEqualTo: 'Dhaka')
        .where('age', isGreaterThan: 20)
        .build(),
  );

  // 16. orderBy ascending
  print_result(
    'orderBy age ASC',
    QueryBuilder(fresh()).orderBy('age').build(),
  );

  // 17. orderBy descending
  print_result(
    'orderBy age DESC',
    QueryBuilder(fresh()).orderBy('age', descending: true).build(),
  );

  // 18. where + orderBy
  print_result(
    'city == Dhaka, orderBy age DESC',
    QueryBuilder(fresh())
        .where('city', isEqualTo: 'Dhaka')
        .orderBy('age', descending: true)
        .build(),
  );

  // 19. limit
  print_result(
    'orderBy age ASC, limit 3',
    QueryBuilder(fresh()).orderBy('age').limit(3).build(),
  );

  // 20. limitToLast
  print_result(
    'orderBy age ASC, limitToLast 2',
    QueryBuilder(fresh()).orderBy('age').limitToLast(2).build(),
  );

  // 21. Filter.and
  print_result(
    'Filter.and → city==Dhaka AND age>20',
    QueryBuilder(fresh())
        .where(Filter.and([
      Filter('city', isEqualTo: 'Dhaka'),
      Filter('age', isGreaterThan: 20),
    ]))
        .build(),
  );

  // 22. Filter.or
  print_result(
    'Filter.or → city==Sylhet OR age<18',
    QueryBuilder(fresh())
        .where(Filter.or([
      Filter('city', isEqualTo: 'Sylhet'),
      Filter('age', isLessThan: 18),
    ]))
        .build(),
  );

  // 23. empty data
  print_result(
    'empty data source',
    QueryBuilder([]).where('age', isGreaterThan: 10).build(),
  );

  // 24. no conditions — returns all
  print_result(
    'no conditions (returns all)',
    QueryBuilder(fresh()).build(),
  );

  // 25. execute (async)
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