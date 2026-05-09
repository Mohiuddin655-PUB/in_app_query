class QueryException implements Exception {
  final String message;
  final Object? cause;

  const QueryException(this.message, [this.cause]);

  @override
  String toString() => cause == null
      ? 'QueryException: $message'
      : 'QueryException: $message ($cause)';
}

class InvalidQueryException extends QueryException {
  const InvalidQueryException(super.message, [super.cause]);

  @override
  String toString() => 'InvalidQueryException: $message';
}

class CursorException extends QueryException {
  const CursorException(super.message, [super.cause]);

  @override
  String toString() => 'CursorException: $message';
}
