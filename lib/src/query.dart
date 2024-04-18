import 'filter.dart';

class Query {
  final Object field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final Object? arrayNotContains;
  final Iterable<Object?>? arrayContainsAny;
  final Iterable<Object?>? arrayNotContainsAny;
  final Iterable<Object?>? whereIn;
  final Iterable<Object?>? whereNotIn;
  final bool? isNull;

  const Query(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayNotContains,
    this.arrayContainsAny,
    this.arrayNotContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  const Query.filter(Filter filter) : this(filter);
}
