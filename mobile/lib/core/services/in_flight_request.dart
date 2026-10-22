class InFlightRequest<T> {
  final Map<Object, Future<T>> _requests = {};

  Future<T> run(Object key, Future<T> Function() request) {
    final current = _requests[key];
    if (current != null) return current;

    final pending = request();
    _requests[key] = pending;

    return pending.whenComplete(() {
      if (identical(_requests[key], pending)) {
        _requests.remove(key);
      }
    });
  }
}
