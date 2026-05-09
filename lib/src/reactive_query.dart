import 'dart:async' show StreamController, StreamSubscription;

import 'builder.dart'
    show
        QueryBuilder,
        Collection,
        QueryDocuments,
        CollectionChange,
        QueryDocument;

class ReactiveQuery {
  final Collection _collection;
  final QueryBuilder Function(QueryBuilder builder) _build;

  const ReactiveQuery._(this._collection, this._build);

  factory ReactiveQuery({
    required Collection source,
    required QueryBuilder Function(QueryBuilder builder) query,
  }) =>
      ReactiveQuery._(source, query);

  Stream<QueryDocuments> watch() {
    late StreamController<QueryDocuments> ctrl;
    StreamSubscription<List<CollectionChange>>? sub;
    ctrl = StreamController<QueryDocuments>(
      onListen: () {
        sub = _collection.changes.listen(
          (_) {
            if (ctrl.isClosed) return;
            try {
              ctrl.add(_execute());
            } catch (e, s) {
              ctrl.addError(e, s);
            }
          },
          onError: (Object e, StackTrace s) {
            if (!ctrl.isClosed) ctrl.addError(e, s);
          },
          onDone: () {
            if (!ctrl.isClosed) ctrl.close();
          },
        );
        try {
          ctrl.add(_execute());
        } catch (e, s) {
          ctrl.addError(e, s);
        }
      },
      onCancel: () => sub?.cancel(),
    );
    return ctrl.stream;
  }

  Stream<QueryDocument?> watchFirst() {
    return watch().map((batch) => batch.isEmpty ? null : batch.first);
  }

  Stream<int> watchCount() {
    return watch().map((batch) => batch.length);
  }

  QueryDocuments now() => _execute();

  QueryDocuments _execute() {
    return _build(QueryBuilder(_collection.documents)).build();
  }
}
