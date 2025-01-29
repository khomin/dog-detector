// Semaphore class to manage concurrency
import 'dart:async';

class Semaphore {
  final int _maxConcurrent;
  int _currentConcurrent = 0;
  final _queue = <Completer<void>>[];

  Semaphore(this._maxConcurrent);

  Future<void> acquire() {
    if (_currentConcurrent < _maxConcurrent) {
      _currentConcurrent++;
      return Future.value();
    } else {
      final completer = Completer<void>();
      _queue.add(completer);
      return completer.future;
    }
  }

  void release() {
    if (_queue.isNotEmpty) {
      final completer = _queue.removeAt(0);
      completer.complete();
    } else {
      _currentConcurrent--;
    }
  }
}
