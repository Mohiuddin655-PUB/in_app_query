class Sorting {
  final String field;
  final bool descending;

  const Sorting(
    this.field, {
    this.descending = false,
  });

  @override
  int get hashCode => field.hashCode;

  @override
  bool operator ==(Object other) {
    return field.hashCode == other.hashCode;
  }

  @override
  String toString() {
    return field;
  }
}
