abstract final class Comparators {
  const Comparators._();

  static bool isLessThan(Object? a, Object? b) {
    if (a == null || b == null) return false;
    final cmp = _safeCompare(a, b);
    return cmp != null && cmp < 0;
  }

  static bool isLessThanOrEqual(Object? a, Object? b) {
    if (a == null || b == null) return false;
    final cmp = _safeCompare(a, b);
    return cmp != null && cmp <= 0;
  }

  static bool isGreaterThan(Object? a, Object? b) {
    if (a == null || b == null) return false;
    final cmp = _safeCompare(a, b);
    return cmp != null && cmp > 0;
  }

  static bool isGreaterThanOrEqual(Object? a, Object? b) {
    if (a == null || b == null) return false;
    final cmp = _safeCompare(a, b);
    return cmp != null && cmp >= 0;
  }

  static bool iterableContains(Object? value, Object? target) =>
      value is Iterable && value.contains(target);

  static bool iterableContainsAny(Object? value, Iterable<Object?> targets) {
    if (value is! Iterable) return false;
    if (targets.isEmpty) return false;
    final set = targets is Set<Object?> ? targets : targets.toSet();
    return value.any(set.contains);
  }

  static int compare(Object? a, Object? b) {
    if (identical(a, b)) return 0;
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return _safeCompare(a, b) ?? 0;
  }

  static int? _safeCompare(Object a, Object b) {
    if (a is num && b is num) return a.compareTo(b);
    if (a is String && b is String) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    if (a is bool && b is bool) {
      if (a == b) return 0;
      return a ? 1 : -1;
    }
    if (a is Comparable && b is Comparable && a.runtimeType == b.runtimeType) {
      try {
        return a.compareTo(b);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
