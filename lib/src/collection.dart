import 'dart:async' show StreamController, StreamSubscription;

import 'exceptions.dart' show InvalidQueryException;
import 'field_path.dart' show FieldPath;

typedef DocumentId = String;

enum CollectionChangeType { added, modified, removed }

class CollectionChange {
  final CollectionChangeType type;
  final DocumentId id;
  final Map<String, dynamic>? document;
  final Map<String, dynamic>? previousDocument;

  const CollectionChange._({
    required this.type,
    required this.id,
    this.document,
    this.previousDocument,
  });

  factory CollectionChange.added(DocumentId id, Map<String, dynamic> doc) =>
      CollectionChange._(
        type: CollectionChangeType.added,
        id: id,
        document: doc,
      );

  factory CollectionChange.modified(
    DocumentId id,
    Map<String, dynamic> doc,
    Map<String, dynamic> previous,
  ) =>
      CollectionChange._(
        type: CollectionChangeType.modified,
        id: id,
        document: doc,
        previousDocument: previous,
      );

  factory CollectionChange.removed(
    DocumentId id,
    Map<String, dynamic> previous,
  ) =>
      CollectionChange._(
        type: CollectionChangeType.removed,
        id: id,
        previousDocument: previous,
      );
}

class Collection {
  final String idField;
  final Map<DocumentId, Map<String, dynamic>> _docs = {};
  final StreamController<List<CollectionChange>> _changes =
      StreamController<List<CollectionChange>>.broadcast(sync: true);

  Collection({this.idField = 'id'});

  factory Collection.from(
    Iterable<Map<String, dynamic>> docs, {
    String idField = 'id',
  }) {
    final c = Collection(idField: idField);
    for (final d in docs) {
      final id = c._extractId(d);
      c._docs[id] = c._snapshot(d);
    }
    return c;
  }

  Stream<List<CollectionChange>> get changes => _changes.stream;

  Stream<List<Map<String, dynamic>>> snapshots() {
    late StreamController<List<Map<String, dynamic>>> ctrl;
    StreamSubscription<List<CollectionChange>>? sub;
    ctrl = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        if (_changes.isClosed) {
          ctrl.add(documents);
          ctrl.close();
          return;
        }
        sub = _changes.stream.listen(
          (_) {
            if (!ctrl.isClosed) ctrl.add(documents);
          },
          onError: (Object e, StackTrace s) {
            if (!ctrl.isClosed) ctrl.addError(e, s);
          },
          onDone: () {
            if (!ctrl.isClosed) ctrl.close();
          },
        );
        ctrl.add(documents);
      },
      onCancel: () => sub?.cancel(),
    );
    return ctrl.stream;
  }

  int get length => _docs.length;

  bool get isEmpty => _docs.isEmpty;

  bool get isNotEmpty => _docs.isNotEmpty;

  List<Map<String, dynamic>> get documents =>
      List<Map<String, dynamic>>.unmodifiable(_docs.values);

  Iterable<DocumentId> get ids => _docs.keys;

  Map<String, dynamic>? doc(DocumentId id) => _docs[id];

  bool contains(DocumentId id) => _docs.containsKey(id);

  void add(Map<String, dynamic> document) {
    final id = _extractId(document);
    if (_docs.containsKey(id)) {
      throw InvalidQueryException('Document with id "$id" already exists');
    }
    final stored = _snapshot(document);
    _docs[id] = stored;
    _emit([CollectionChange.added(id, stored)]);
  }

  void set(DocumentId id, Map<String, dynamic> document) {
    final raw = Map<String, dynamic>.of(document);
    raw[idField] = id;
    final stored = Map<String, dynamic>.unmodifiable(raw);
    final previous = _docs[id];
    _docs[id] = stored;
    if (previous == null) {
      _emit([CollectionChange.added(id, stored)]);
    } else {
      _emit([CollectionChange.modified(id, stored, previous)]);
    }
  }

  void update(DocumentId id, Map<String, dynamic> patch) {
    final previous = _docs[id];
    if (previous == null) {
      throw InvalidQueryException('Document with id "$id" not found');
    }
    final merged = Map<String, dynamic>.of(previous)..addAll(patch);
    merged[idField] = id;
    final stored = Map<String, dynamic>.unmodifiable(merged);
    _docs[id] = stored;
    _emit([CollectionChange.modified(id, stored, previous)]);
  }

  bool remove(DocumentId id) {
    final removed = _docs.remove(id);
    if (removed == null) return false;
    _emit([CollectionChange.removed(id, removed)]);
    return true;
  }

  void clear() {
    if (_docs.isEmpty) return;
    final batch = <CollectionChange>[];
    for (final entry in _docs.entries) {
      batch.add(CollectionChange.removed(entry.key, entry.value));
    }
    _docs.clear();
    _emit(batch);
  }

  void batch(void Function(BatchScope scope) operations) {
    final snapshot = Map<DocumentId, Map<String, dynamic>>.of(_docs);
    final scope = BatchScope._(this);
    try {
      operations(scope);
    } catch (_) {
      _docs
        ..clear()
        ..addAll(snapshot);
      rethrow;
    }
    if (scope._pending.isNotEmpty) {
      _emit(List<CollectionChange>.unmodifiable(scope._pending));
    }
  }

  Future<void> dispose() async {
    if (!_changes.isClosed) await _changes.close();
  }

  DocumentId _extractId(Map<String, dynamic> doc) {
    final raw = FieldPath.resolve(doc, idField);
    if (raw == null) {
      throw InvalidQueryException(
        'Document is missing required id field "$idField"',
      );
    }
    return raw.toString();
  }

  Map<String, dynamic> _snapshot(Map<String, dynamic> doc) {
    final copy = Map<String, dynamic>.of(doc);
    return Map<String, dynamic>.unmodifiable(copy);
  }

  void _emit(List<CollectionChange> batch) {
    if (_changes.isClosed) return;
    _changes.add(batch);
  }
}

class BatchScope {
  final Collection _owner;
  final List<CollectionChange> _pending = [];

  BatchScope._(this._owner);

  void add(Map<String, dynamic> document) {
    final id = _owner._extractId(document);
    if (_owner._docs.containsKey(id)) {
      throw InvalidQueryException('Document with id "$id" already exists');
    }
    final stored = _owner._snapshot(document);
    _owner._docs[id] = stored;
    _pending.add(CollectionChange.added(id, stored));
  }

  void set(DocumentId id, Map<String, dynamic> document) {
    final raw = Map<String, dynamic>.of(document);
    raw[_owner.idField] = id;
    final stored = Map<String, dynamic>.unmodifiable(raw);
    final previous = _owner._docs[id];
    _owner._docs[id] = stored;
    if (previous == null) {
      _pending.add(CollectionChange.added(id, stored));
    } else {
      _pending.add(CollectionChange.modified(id, stored, previous));
    }
  }

  void update(DocumentId id, Map<String, dynamic> patch) {
    final previous = _owner._docs[id];
    if (previous == null) {
      throw InvalidQueryException('Document with id "$id" not found');
    }
    final merged = Map<String, dynamic>.of(previous)..addAll(patch);
    merged[_owner.idField] = id;
    final stored = Map<String, dynamic>.unmodifiable(merged);
    _owner._docs[id] = stored;
    _pending.add(CollectionChange.modified(id, stored, previous));
  }

  bool remove(DocumentId id) {
    final removed = _owner._docs.remove(id);
    if (removed == null) return false;
    _pending.add(CollectionChange.removed(id, removed));
    return true;
  }
}
