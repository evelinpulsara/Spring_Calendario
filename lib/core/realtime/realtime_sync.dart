import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';

typedef Loader = Future<void> Function();

class RealtimeSync {
  RealtimeSync(
    this._realtime,
    this._loaders, {
    Duration debounce = const Duration(milliseconds: 300),
  }) : _debounce = debounce;

  final RealtimeService _realtime;
  final Map<RealtimeResource, Loader> _loaders;
  final Duration _debounce;
  final Set<RealtimeResource> _pending = {};
  StreamSubscription<RealtimeEvent>? _subscription;
  Timer? _timer;

  void attach() {
    _subscription ??= _realtime.changes.listen(_onChange);
  }

  void _onChange(RealtimeEvent event) {
    _pending.add(event.resource);
    _timer?.cancel();
    _timer = Timer(_debounce, _flush);
  }

  void _flush() {
    final reloadAll = _pending.contains(RealtimeResource.all);
    _loaders.forEach((resource, load) {
      if (reloadAll || _pending.contains(resource)) {
        load().catchError((Object e) => debugPrint('No se pudo recargar ${resource.name}: $e'));
      }
    });
    _pending.clear();
  }

  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _subscription = null;
  }
}
