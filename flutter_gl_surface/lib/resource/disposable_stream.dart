import 'dart:async';

class DisposableStream {
  final _disposable = <StreamSubscription>[];

  void add(StreamSubscription v) {
    _disposable.add(v);
  }

  void dispose() {
    for (var it in _disposable) {
      it.cancel();
    }
    _disposable.clear();
  }
}
