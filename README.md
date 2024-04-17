## Usage QueryBuilder

```dart
import 'package:in_app_query/in_app_query.dart';

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
  _all(data);
  _queryTest(data);
  _sortingTest(data);
  _selectionTest();
}

void _all(List<Map<String, dynamic>> data) {
  // QueryBuilder query
  var simple = QueryBuilder(data)
      .where("username", isNull: false)
      .where("country", isEqualTo: "Japan")
      .orderBy("age", descending: true)
      .limit(3)
      .build();
  simple.output("OUTPUT: SIMPLE");
  /*
  OUTPUT:
  {id: id_2, username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {id: id_10, username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  */

  // QueryBuilder pagination
  var pagination = QueryBuilder(data)
      .where("username", isNull: false)
      .startAfter(["id_3"])
      .limit(3)
      .build();

  pagination.output("OUTPUT: PAGINATION");
  /*
  OUTPUT:
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {id: id_5, username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  */
}

void _queryTest(List<Map<String, dynamic>> data) {
  // QueryBuilder build
  var result = QueryBuilder(data)
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

  result.output("OUTPUT: Query by username == olivia_adams and age <= 50");
  /*
  OUTPUT: Query by username == olivia_adams and age <= 50
  {id: id_3, username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  */
}

void _sortingTest(List<Map<String, dynamic>> data) {
  // QueryBuilder with multiple orderBy statements
  var result = QueryBuilder(data)
      .orderBy("username")
      .orderBy("email")
      .orderBy("age", descending: true)
      .orderBy("country")
      .build();

  result.output("OUTPUTS: Sorted by username(asc), age(des) and country(asc)");
  /*
  OUTPUTS: Sorted by username(asc), age(des) and country(asc)
  {id: id_1, username: daniel_white, email: daniel_white@example.com, age: 43, country: India}
  {id: id_7, username: emma_smith, email: emma_smith@example.com, age: 49, country: Germany}
  {id: id_8, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Canada}
  {id: id_4, username: olivia_adams, email: olivia_adams@demo.com, age: 53, country: Japan}
  {id: id_2, username: olivia_adams, email: olivia_adams@hotmail.com, age: 57, country: Japan}
  {id: id_3, username: olivia_adams, email: olivia_adams@test.com, age: 36, country: Brazil}
  {id: id_6, username: olivia_adams, email: olivia_adams@yahoo.com, age: 30, country: Brazil}
  {id: id_5, username: peter_brown, email: peter_brown@gmail.com, age: 57, country: China}
  {id: id_9, username: peter_brown, email: peter_brown@hotmail.com, age: 65, country: Brazil}
  {id: id_10, username: sarah_carter, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {id: id_11, username: null, email: sarah_carter@gmail.com, age: 55, country: Japan}
  {id: id_12, username: olivia_adams, email: olivia_adams@demo.com, age: null, country: US}
  {id: id_13, username: olivia_adams, email: olivia_adams@yahoo.com, age: 53, country: Australia}
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
  // Data selection with QueryBuilder like startAt
  var startAt = QueryBuilder(data).startAt(['charlie']).build();
  startAt.output("Selection output: startAt");

  // Data selection with QueryBuilder like endAt
  var endAt = QueryBuilder(data).endAt(['charlie']).build();
  endAt.output("Selection output: endAt");

  // Data selection with QueryBuilder like startAfter
  var startAfter = QueryBuilder(data).startAfter(['charlie']).build();
  startAfter.output("Selection output: startAfter");

  // Data selection with QueryBuilder like endBefore
  var endBefore = QueryBuilder(data).endBefore(['charlie']).build();
  endBefore.output("Selection output: endBefore");

  // Data selection with QueryBuilder like startAfterDocument
  var startAfterDocument = QueryBuilder(data).startAfterDocument(
      {'username': 'charlie', 'age': 35, 'country': 'Australia'}).build();
  startAfterDocument.output("Selection output: startAfterDocument");

  // Data selection with QueryBuilder like endBeforeDocument
  var endBeforeDocument = QueryBuilder(data).endBeforeDocument(
      {'username': 'charlie', 'age': 35, 'country': 'Australia'}).build();
  endBeforeDocument.output("Selection output: endBeforeDocument");

  // Data selection with QueryBuilder like startAtEndAt
  var startAtEndAt =
  QueryBuilder(data).startAt(['bob']).endAt(["daniel"]).build();
  startAtEndAt.output("Selection output: startAtEndAt");

  // Data selection with QueryBuilder like startAfter and endBefore
  var startAfterEndBefore =
  QueryBuilder(data).startAfter(['bob']).endBefore(["daniel"]).build();
  startAfterEndBefore.output("Selection output: startAfterEndBefore");

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
  OUTPUTS:

  Selection output: startAt
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Selection output: endAt
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}

  Selection output: startAfter
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Selection output: endBefore
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}

  Selection output: startAfterDocument
  {username: daniel, age: 40, country: UK}
  {username: emma, age: 45, country: Germany}

  Selection output: endBeforeDocument
  {username: alice, age: 25, country: USA}
  {username: bob, age: 30, country: Canada}

  Selection output: startAtEndAt
  {username: bob, age: 30, country: Canada}
  {username: charlie, age: 35, country: Australia}
  {username: daniel, age: 40, country: UK}

  Selection output: startAfterEndBefore
  {username: charlie, age: 35, country: Australia}

  Selection output: startAfterDocumentEndBeforeDocument
  {username: charlie, age: 35, country: Australia}
  */
}

extension on List {
  void output(String name) {
    print('\n$name');
    forEach(print);
  }
}
```
