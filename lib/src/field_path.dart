import 'package:meta/meta.dart' show immutable;

enum FieldPathType { documentId }

@immutable
class FieldPath {
  static const String documentIdKey = '__name__';
  static const String defaultIdField = 'id';

  final List<String> segments;

  const FieldPath._(this.segments);

  static FieldPathType get documentId => FieldPathType.documentId;

  factory FieldPath(String path) {
    if (path.isEmpty) {
      throw ArgumentError('FieldPath cannot be empty');
    }
    if (!path.contains('.')) {
      return FieldPath._(List.unmodifiable([path]));
    }
    final parts = path.split('.');
    for (final p in parts) {
      if (p.isEmpty) {
        throw ArgumentError('FieldPath segment cannot be empty: "$path"');
      }
    }
    return FieldPath._(List.unmodifiable(parts));
  }

  static Object? resolve(Map<String, dynamic> doc, Object field) {
    if (field is FieldPathType) {
      if (field == FieldPathType.documentId) return doc[defaultIdField];
      return null;
    }
    if (field is String) {
      if (field == documentIdKey) return doc[defaultIdField];
      if (!field.contains('.')) return doc[field];
      return _resolveDotted(doc, field.split('.'));
    }
    if (field is FieldPath) {
      if (field.segments.length == 1) {
        final first = field.segments.first;
        if (first == documentIdKey) return doc[defaultIdField];
        return doc[first];
      }
      return _resolveDotted(doc, field.segments);
    }
    return doc[field];
  }

  static String stableKey(Object field) {
    if (field is FieldPathType) {
      if (field == FieldPathType.documentId) return documentIdKey;
    }
    if (field is FieldPath) return field.path;
    return field.toString();
  }

  static Object? _resolveDotted(Map<String, dynamic> doc, List<String> parts) {
    Object? current = doc;
    for (final part in parts) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
      if (current == null) return null;
    }
    return current;
  }

  String get path => segments.join('.');

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldPath) return false;
    if (other.segments.length != segments.length) return false;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  @override
  String toString() => path;
}
