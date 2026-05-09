import 'comparators.dart' show Comparators;
import 'field_path.dart' show FieldPath;
import 'filter.dart' show Filter;

abstract final class FilterEngine {
  const FilterEngine._();

  static bool matchesConditions(
    Map<String, dynamic> doc, {
    required Object field,
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
    Set<Object?>? whereInSet,
    Set<Object?>? whereNotInSet,
    bool? isNull,
  }) {
    final value = FieldPath.resolve(doc, field);

    if (isNull != null && (value == null) != isNull) return false;
    if (isEqualTo != null && value != isEqualTo) return false;
    if (isNotEqualTo != null && value == isNotEqualTo) return false;

    if (isLessThan != null && !Comparators.isLessThan(value, isLessThan)) {
      return false;
    }
    if (isLessThanOrEqualTo != null &&
        !Comparators.isLessThanOrEqual(value, isLessThanOrEqualTo)) {
      return false;
    }
    if (isGreaterThan != null &&
        !Comparators.isGreaterThan(value, isGreaterThan)) {
      return false;
    }
    if (isGreaterThanOrEqualTo != null &&
        !Comparators.isGreaterThanOrEqual(value, isGreaterThanOrEqualTo)) {
      return false;
    }

    if (arrayContains != null &&
        !Comparators.iterableContains(value, arrayContains)) {
      return false;
    }
    if (arrayNotContains != null &&
        Comparators.iterableContains(value, arrayNotContains)) {
      return false;
    }
    if (arrayContainsAny != null &&
        !Comparators.iterableContainsAny(value, arrayContainsAny)) {
      return false;
    }
    if (arrayNotContainsAny != null &&
        Comparators.iterableContainsAny(value, arrayNotContainsAny)) {
      return false;
    }

    if (whereInSet != null && !whereInSet.contains(value)) return false;
    if (whereNotInSet != null && whereNotInSet.contains(value)) return false;

    return true;
  }

  static bool matchesFilter(Map<String, dynamic> doc, Filter filter) {
    if (filter.type.isAndFilter) {
      final children = filter.field as List<Filter>;
      for (final child in children) {
        if (!matchesFilter(doc, child)) return false;
      }
      return true;
    }
    if (filter.type.isOrFilter) {
      final children = filter.field as List<Filter>;
      if (children.isEmpty) return false;
      for (final child in children) {
        if (matchesFilter(doc, child)) return true;
      }
      return false;
    }
    return matchesConditions(
      doc,
      field: filter.field,
      isEqualTo: filter.isEqualTo,
      isNotEqualTo: filter.isNotEqualTo,
      isLessThan: filter.isLessThan,
      isLessThanOrEqualTo: filter.isLessThanOrEqualTo,
      isGreaterThan: filter.isGreaterThan,
      isGreaterThanOrEqualTo: filter.isGreaterThanOrEqualTo,
      arrayContains: filter.arrayContains,
      arrayNotContains: filter.arrayNotContains,
      arrayContainsAny: filter.arrayContainsAny,
      arrayNotContainsAny: filter.arrayNotContainsAny,
      whereInSet: _toSet(filter.whereIn),
      whereNotInSet: _toSet(filter.whereNotIn),
      isNull: filter.isNull,
    );
  }

  static Set<Object?>? _toSet(Iterable<Object?>? values) {
    if (values == null) return null;
    return values is Set<Object?> ? values : values.toSet();
  }
}
