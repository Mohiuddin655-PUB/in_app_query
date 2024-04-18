import 'filter.dart';
import 'sorting.dart';

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

  QueryBuilder limitToLast(int limit) {
    _data = _data.toList().reversed.take(limit).toList();
    return QueryBuilder(List.from(_data), this);
  }

  List<Map<String, dynamic>> build() => _data;

  Future<List<Map<String, dynamic>>> execute([int executionTime = 100]) {
    return Future.delayed(Duration(milliseconds: executionTime)).then((_) {
      return build();
    });
  }
}
