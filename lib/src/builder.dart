import 'filter.dart';
import 'sorting.dart';

void main() {
  List<Map<String, dynamic>> data = [
    {
      "id": "id_1",
      'username': 'daniel_white',
      'email': 'daniel_white@example.com',
      'age': 43,
      'country': 'India'
    },
    {
      "id": "id_2",
      'username': 'olivia_adams',
      'email': 'olivia_adams@hotmail.com',
      'age': 57,
      'country': 'Japan'
    },
    {
      "id": "id_3",
      'username': 'olivia_adams',
      'email': 'olivia_adams@test.com',
      'age': 36,
      'country': 'Brazil'
    },
    {
      "id": "id_4",
      'username': 'olivia_adams',
      'email': 'olivia_adams@demo.com',
      'age': 53,
      'country': 'Japan'
    },
    {
      "id": "id_5",
      'username': 'peter_brown',
      'email': 'peter_brown@gmail.com',
      'age': 57,
      'country': 'China'
    },
    {
      "id": "id_6",
      'username': 'olivia_adams',
      'email': 'olivia_adams@yahoo.com',
      'age': 30,
      'country': 'Brazil'
    },
    {
      "id": "id_7",
      'username': 'emma_smith',
      'email': 'emma_smith@example.com',
      'age': 49,
      'country': 'Germany'
    },
    {
      "id": "id_8",
      'username': 'olivia_adams',
      'email': 'olivia_adams@demo.com',
      'age': 53,
      'country': 'Canada'
    },
    {
      "id": "id_9",
      'username': 'peter_brown',
      'email': 'peter_brown@hotmail.com',
      'age': 65,
      'country': 'Brazil'
    },
    {
      "id": "id_10",
      'username': 'sarah_carter',
      'email': 'sarah_carter@gmail.com',
      'age': 55,
      'country': 'Japan'
    },
    {
      "id": "id_11",
      'username': null,
      'email': 'sarah_carter@gmail.com',
      'age': 55,
      'country': 'Japan'
    },
    {
      "id": "id_12",
      'username': 'olivia_adams',
      'email': 'olivia_adams@demo.com',
      'age': null,
      'country': 'US'
    },
    {
      "id": "id_13",
      'username': 'olivia_adams',
      'email': 'olivia_adams@yahoo.com',
      'age': 53,
      'country': 'Australia'
    },
  ];
  _queryTest(data);
  _sortingTest(data);
  _selectionTest();
  _pagination(data);
}

void _queryTest(List<Map<String, dynamic>> data) {
  // Simple query
  var simple = QueryBuilder(data)
      // .where('username', isNull: true)
      // .where('username', isNull: false)
      .where('username', isEqualTo: "olivia_adams")
      // .where('username', isNotEqualTo: "daniel_white")
      // .where('age', isGreaterThan: 60)
      // .where('age', isGreaterThanOrEqualTo: 60)
      // .where('age', isLessThan: 60)
      .where('age', isLessThanOrEqualTo: 50)
      // .where('posts', arrayContains: "a")
      // .where('posts', arrayContains: "x")
      // .where('posts', arrayContainsAny: ["a", "x"])
      // .where('posts', arrayContainsAny: ["x", "y"])
      // .where('posts', arrayNotContains: "x")
      // .where('posts', arrayNotContains: "a")
      // .where('posts', arrayNotContainsAny: ["a", "x"])
      // .where('posts', arrayNotContainsAny: ["a", "b"])
      .build();

  simple.output(
      "Query output(simple): Query by username == olivia_adams and age <= 50");
  /*
  Query output(simple): Query by username == olivia_adams and age <= 50
  {id: id_3, username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  */

  // complex query
  var complex = QueryBuilder(data)
      .where(const Filter.or([
        Filter("age", isEqualTo: 30),
        Filter('age', isEqualTo: 53),
        Filter('age', isEqualTo: 63),
        Filter('country', isEqualTo: "Japan"),
      ]))
      .where(const Filter.and([
        Filter('country', isEqualTo: "Japan"),
        Filter('username', isEqualTo: "olivia_adams"),
      ]))
      .build();

  complex.output("Query output(filter): Query with OR and AND condition");
  /*
  Query output(filter): Query with OR and AND condition
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {id: id_2, username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  */
}

void _sortingTest(List<Map<String, dynamic>> data) {
  var result = QueryBuilder(data)
      .orderBy("username")
      .orderBy("email")
      .orderBy("age", descending: true)
      .orderBy("country")
      .build();

  result.output(
      "Sorted output: Sorted by username(asc), email(asc), age(des) and country(asc)");
  /*
  Sorted output: Sorted by username(asc), email(asc), age(des) and country(asc)
  {id: id_1, username: daniel_white, email: daniel_white@example.com, age: 43, country: India}
  {id: id_7, username: emma_smith, email: emma_smith@example.com, age: 49, country: Germany}
  {id: id_8, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Canada}
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {id: id_12, username: olivia_adams, email: olivia_adams@demo.com, age: null, country: US}
  {id: id_2, username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {id: id_3, username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {id: id_13, username: olivia_adams, email: olivia_adams@yahoo.com, age: 53, country: Australia}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  {id: id_5, username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {id: id_9, username: peter_brown, email: peter_brown@hotmail.com, age: 65, country: Brazil}
  {id: id_10, username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {id: id_11, username: null, email: sarah_carter@gmail.com, age: 55, country: Japan}
  */
}

void _selectionTest() {
  List<Map<String, dynamic>> data = [
    {'username': 'alice', 'age': 25, 'country': 'USA'},
    {'username': 'bob', 'age': 30, 'country': 'Canada'},
    {'username': 'charlie', 'age': 35, 'country': 'Australia'},
    {'username': 'daniel', 'age': 40, 'country': 'UK'},
    {'username': 'emma', 'age': 45, 'country': 'Germany'}
  ];

  // Data selection with QueryBuilder like endAt
  var endAt = QueryBuilder(data).endAt(['daniel']).build();
  endAt.output("Selection output: endAt");
  /*
  Selection output: endAt
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  */

  // Data selection with QueryBuilder like startAtDocument
  var endAtDocument = QueryBuilder(data).endAtDocument(
      {'username': 'daniel', 'age': 40, 'country': 'UK'}).build();
  endAtDocument.output("Selection output: endAtDocument");
  /*
  Selection output: endAtDocument
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  */

  // Data selection with QueryBuilder like endBefore
  var endBefore = QueryBuilder(data).endBefore(['daniel']).build();
  endBefore.output("Selection output: endBefore");
  /*
  Selection output: endBefore
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  */

  // Data selection with QueryBuilder like endBeforeDocument
  var endBeforeDocument = QueryBuilder(data).endBeforeDocument(
      {'username': 'daniel', 'age': 40, 'country': 'UK'}).build();
  endBeforeDocument.output("Selection output: endBeforeDocument");
  /*
  Selection output: endBeforeDocument
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  */

  // Data selection with QueryBuilder like startAt
  var startAt = QueryBuilder(data).startAt(['bob']).build();
  startAt.output("Selection output: startAt");
  /*
  Selection output: startAt
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}
  */

  // Data selection with QueryBuilder like startAtDocument
  var startAtDocument = QueryBuilder(data).startAtDocument(
      {'username': 'bob', 'age': 30, 'country': 'Canada'}).build();
  startAtDocument.output("Selection output: startAtDocument");
  /*
  Selection output: startAtDocument
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}
  */

  // Data selection with QueryBuilder like startAfter
  var startAfter = QueryBuilder(data).startAfter(['bob']).build();
  startAfter.output("Selection output: startAfter");
  /*
  Selection output: startAfter
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}
  */

  // Data selection with QueryBuilder like startAfterDocument
  var startAfterDocument = QueryBuilder(data).startAfterDocument(
      {'username': 'bob', 'age': 30, 'country': 'Canada'}).build();
  startAfterDocument.output("Selection output: startAfterDocument");
  /*
  Selection output: startAfterDocument
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}
  */

  // Data selection with QueryBuilder like startAt and endAt
  var startAtEndAt = QueryBuilder(data).startAt(
    ["bob", 30],
  ).endAt(
    ['daniel', 40],
  ).build();
  startAtEndAt.output("Selection output: startAtEndAt");
  /*
  Selection output: startAtEndAt
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  */

  // Data selection with QueryBuilder like startAtDocument and endAtDocument
  var startAtDocumentEndAtDocument = QueryBuilder(data).startAtDocument(
    {'username': 'bob', 'age': 30, 'country': 'Canada'},
  ).endAtDocument(
    {'username': 'daniel', 'age': 40, 'country': 'UK'},
  ).build();
  startAtDocumentEndAtDocument
      .output("Selection output: startAtDocumentEndAtDocument");
  /*
  Selection output: startAtDocumentEndAtDocument
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  */

  // Data selection with QueryBuilder like startAfter and endBefore
  var startAfterEndBefore = QueryBuilder(data).startAfter(
    ["bob", 30],
  ).endBefore(
    ['daniel', 40],
  ).build();
  startAfterEndBefore.output("Selection output: startAfterEndBefore");
  /*
  Selection output: startAfterEndBefore
  {username: charlie, age: 35, country: Australia}
  */

  // Data selection with QueryBuilder like startAfterDocument and endBeforeDocument
  var startAfterDocumentEndBeforeDocument =
      QueryBuilder(data).startAfterDocument(
    {'username': 'bob', 'age': 30, 'country': 'Canada'},
  ).endBeforeDocument(
    {'username': 'daniel', 'age': 40, 'country': 'UK'},
  ).build();
  startAfterDocumentEndBeforeDocument
      .output("Selection output: startAfterDocumentEndBeforeDocument");
  /*
  Selection output: startAfterDocumentEndBeforeDocument
  {username: charlie, age: 35, country: Australia}
  */
}

void _pagination(List<Map<String, dynamic>> data) {
  // Simple pagination
  var simple = QueryBuilder(data)
      .where("username", isNull: false)
      .where("country", isEqualTo: "Japan")
      .orderBy("age", descending: true)
      .limit(3)
      .build();
  simple.output("Pagination output: simple");
  /*
  Pagination output: simple:
  {id: id_2, username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {id: id_10, username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  */

  // Complex pagination
  var pagination = QueryBuilder(data)
      .where("username", isNull: false)
      .startAfter(["id_3"])
      .limit(3)
      .build();
  pagination.output("Pagination output: selection");
  /*
  Pagination output: complex
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {id: id_5, username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  */
}

extension on List {
  void output(String name) {
    print('\n$name');
    forEach(print);
  }
}

class QueryBuilder {
  final QueryBuilder? parent;
  List<Map<String, dynamic>> _data;
  Map<String, Sorting> orders;

  QueryBuilder(
    this._data, [
    this.parent,
    Map<String, Sorting>? orders,
  ]) : orders = orders ?? {};

  QueryBuilder _filter(Filter filter) {
    if (filter.type.isAndFilter) {
      _data = _applyAndFilter(filter.field as List<Filter>);
    } else if (filter.type.isOrFilter) {
      _data = _applyOrFilter(filter.field as List<Filter>);
    } else {
      _data = _applySingleFilter(filter);
    }
    return this;
  }

  List<Map<String, dynamic>> _applySingleFilter(Filter filter) {
    return _data.where((doc) {
      final i = doc[filter.field];
      return (filter.isEqualTo == null || i == filter.isEqualTo) &&
          (filter.isNotEqualTo == null || i != filter.isNotEqualTo) &&
          (filter.isLessThan == null || i < filter.isLessThan) &&
          (filter.isLessThanOrEqualTo == null ||
              i <= filter.isLessThanOrEqualTo) &&
          (filter.isGreaterThan == null || i > filter.isGreaterThan) &&
          (filter.isGreaterThanOrEqualTo == null ||
              i >= filter.isGreaterThanOrEqualTo) &&
          (filter.arrayContains == null ||
              (i is Iterable && i.contains(filter.arrayContains))) &&
          (filter.arrayContainsAny == null ||
              (i is Iterable &&
                  i.any((e) => filter.arrayContainsAny!.contains(e)))) &&
          (filter.whereIn == null || filter.whereIn!.contains(i)) &&
          (filter.whereNotIn == null || !filter.whereNotIn!.contains(i)) &&
          (filter.isNull == null || (i == null) == filter.isNull);
    }).toList();
  }

  List<Map<String, dynamic>> _applyAndFilter(List<Filter> filters) {
    List<Map<String, dynamic>> result = _data;
    for (var filter in filters) {
      result = QueryBuilder(result)._applySingleFilter(filter);
    }
    return result;
  }

  List<Map<String, dynamic>> _applyOrFilter(List<Filter> filters) {
    List<Map<String, dynamic>> result = [];
    for (var filter in filters) {
      result.addAll(QueryBuilder(_data)._applySingleFilter(filter));
    }
    return result.toSet().toList();
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
    if (field is Filter) {
      return _filter(field);
    } else {
      _data = _data.where((doc) {
        final i = doc[field];
        if (isEqualTo != null && i == isEqualTo) {
          return true;
        } else if (isNotEqualTo != null && i != isNotEqualTo) {
          return true;
        } else if (isLessThan != null && i != null && i < isLessThan) {
          return true;
        } else if (isLessThanOrEqualTo != null &&
            i != null &&
            i <= isLessThanOrEqualTo) {
          return true;
        } else if (isGreaterThan != null && i != null && i > isGreaterThan) {
          return true;
        } else if (isGreaterThanOrEqualTo != null &&
            i != null &&
            i >= isGreaterThanOrEqualTo) {
          return true;
        } else if (arrayContains != null &&
            i is Iterable &&
            i.contains(arrayContains)) {
          return true;
        } else if (arrayNotContains != null &&
            i is Iterable &&
            !i.contains(arrayNotContains)) {
          return true;
        } else if (arrayContainsAny != null &&
            i is Iterable &&
            i.any((e) => arrayContainsAny.contains(e))) {
          return true;
        } else if (arrayNotContainsAny != null &&
            i is Iterable &&
            !i.any((e) => arrayNotContainsAny.contains(e))) {
          return true;
        } else if (whereIn != null && whereIn.contains(i)) {
          return true;
        } else if (whereNotIn != null && whereNotIn.contains(i)) {
          return true;
        } else if (isNull != null && (i == null) == isNull) {
          return true;
        } else {
          return false;
        }
      }).toList();
      return QueryBuilder(List.from(_data), this, orders);
    }
  }

  QueryBuilder _applyOrders() {
    _data.sort((a, b) {
      int i = 0;
      while (i < orders.length) {
        var sort = orders.values.elementAt(i);
        var field = sort.field;
        final x = a[field];
        final y = b[field];

        // If both values are null, consider them equal
        if (x == null && y == null) {
          i++;
          continue; // Skip to the next field
        }

        // If x is null, and y is not, place a at the end
        if (x == null && y != null) return 1;

        // If y is null, and x is not, place b at the end
        if (y == null && x != null) return -1;

        // Perform regular comparison
        var comparison = x.compareTo(y);
        if (comparison != 0) {
          // If descending is provided and true for this field, reverse the comparison
          return sort.descending ? -comparison : comparison;
        }
        i++;
      }
      return 0;
    });
    return QueryBuilder(List.from(_data), this, orders);
  }

  QueryBuilder orderBy(String field, {bool descending = false}) {
    orders[field] = Sorting(field, descending: descending);
    return _applyOrders();
  }

  QueryBuilder endAt(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        try {
          final a = doc.values.elementAtOrNull(i);
          final b = values[i];
          if (a != null && b != null) {
            if (a.compareTo(b) > 0) return false;
            if (a.compareTo(b) < 0) return true;
          }
        } catch (_) {}
      }
      return true;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder endAtDocument(Map<String, dynamic> document) {
    _data = _data.takeWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        try {
          var field = doc.keys.elementAtOrNull(i);
          var a = doc[field];
          var b = document[field];
          if (a != null && b != null) {
            if (a.compareTo(b) <= 0) return true;
            if (a.compareTo(b) > 0) return false;
          }
        } catch (_) {}
      }
      return false;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder endBefore(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        try {
          final a = doc.values.elementAtOrNull(i);
          final b = values[i];
          if (a != null && b != null) {
            if (a.compareTo(b) >= 0) return false;
          }
        } catch (_) {}
      }
      return true;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder endBeforeDocument(Map<String, dynamic> document) {
    _data = _data.takeWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        try {
          var field = doc.keys.elementAtOrNull(i);
          var a = doc[field];
          var b = document[field];
          if (a != null && b != null) {
            if (a.compareTo(b) < 0) return true;
            if (a.compareTo(b) > 0) return false;
          }
        } catch (_) {}
      }
      return false;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder startAt(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        try {
          final a = doc.values.elementAtOrNull(i);
          final b = values.elementAtOrNull(i);
          if (a != null && b != null) {
            if (a.compareTo(b) < 0) return false;
            if (a.compareTo(b) > 0) return true;
          }
        } catch (_) {}
      }
      return true;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder startAtDocument(Map<String, dynamic> document) {
    _data = _data.skipWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        try {
          var field = doc.keys.elementAtOrNull(i);
          final a = doc[field];
          final b = document[field];
          if (a != null && b != null) {
            if (a.compareTo(b) < 0) return true;
            if (a.compareTo(b) > 0) return false;
          }
        } catch (_) {}
      }
      return false;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder startAfter(List<dynamic> values) {
    _data = _data.where((doc) {
      for (int i = 0; i < values.length; i++) {
        try {
          final a = doc.values.elementAtOrNull(i);
          final b = values.elementAtOrNull(i);
          if (a != null && b != null) {
            if (a.compareTo(b) <= 0) return false;
          }
        } catch (_) {}
      }
      return true;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder startAfterDocument(Map<String, dynamic> document) {
    _data = _data.skipWhile((doc) {
      for (int i = 0; i < doc.length; i++) {
        try {
          var field = doc.keys.elementAtOrNull(i);
          final a = doc[field];
          final b = document[field];
          if (a != null && b != null) {
            if (a.compareTo(b) <= 0) return true;
            if (a.compareTo(b) > 0) return false;
          }
        } catch (_) {}
      }
      return false;
    }).toList();
    return QueryBuilder(List.from(_data), this);
  }

  QueryBuilder limit(int limit) {
    _data = _data.take(limit).toList();
    return QueryBuilder(List.from(_data), this);
  }

  List<Map<String, dynamic>> build() => _data;

  Future<List<Map<String, dynamic>>> execute([int executionTime = 100]) {
    return Future.delayed(Duration(milliseconds: executionTime)).then((_) {
      return build();
    });
  }
}
