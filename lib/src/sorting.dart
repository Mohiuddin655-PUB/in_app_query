import 'package:meta/meta.dart' show immutable;

@immutable
class Sorting {
  final String field;
  final bool descending;

  const Sorting(this.field, {this.descending = false});

  Sorting copyWith({String? field, bool? descending}) {
    return Sorting(
      field ?? this.field,
      descending: descending ?? this.descending,
    );
  }

  @override
  int get hashCode => Object.hash(field, descending);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sorting &&
        other.field == field &&
        other.descending == descending;
  }

  @override
  String toString() => 'Sorting(field: $field, descending: $descending)';
}
