import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:spring_calendario/core/di/repository_factory.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_endpoint.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/core/realtime/realtime_sync.dart';
import 'package:spring_calendario/core/realtime/sse_connection.dart';
import 'package:spring_calendario/features/cycle/data/repositories/api_cycle_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/in_memory_cycle_repository.dart';

class _SilentSse implements SseConnection {
  @override
  bool get isSupported => false;

  @override
  void open(String url,
      {required List<String> eventNames,
      required void Function(String event, String data) onEvent,
      required void Function() onError}) {}

  @override
  void close() {}
}

class _Remote with FallbackOnError {
  @override
  String get fallbackReason => 'prueba';
}

void main() {
  group('RepositoryFactory (Abstract Factory)', () {
    test('elige la familia de repositorios según el entorno', () {
      final api = ApiClient(client: MockClient((_) async => http.Response('[]', 200)));
      expect(RepositoryFactory(useBackend: true, api: api).cycles(), isA<ApiCycleRepository>());
      expect(RepositoryFactory(useBackend: false, api: api).cycles(), isA<InMemoryCycleRepository>());
    });
  });

  group('RealtimeSync', () {
    late RealtimeService realtime;
    late Map<RealtimeResource, int> loads;
    late RealtimeSync sync;

    setUp(() {
      realtime = RealtimeService(
        ApiClient(client: MockClient((_) async => http.Response('{}', 500))),
        connection: _SilentSse(),
      );
      loads = {for (final r in RealtimeResource.values) r: 0};
      Future<void> Function() counter(RealtimeResource r) => () async => loads[r] = loads[r]! + 1;
      sync = RealtimeSync(
        realtime,
        {
          RealtimeResource.periodDays: counter(RealtimeResource.periodDays),
          RealtimeResource.symptoms: counter(RealtimeResource.symptoms),
          RealtimeResource.intimacy: counter(RealtimeResource.intimacy),
        },
        debounce: const Duration(milliseconds: 10),
      )..attach();
    });

    tearDown(() {
      sync.dispose();
      realtime.dispose();
    });

    test('agrupa varios avisos seguidos y recarga solo lo que cambió', () async {
      realtime.debugEmit(RealtimeResource.symptoms);
      realtime.debugEmit(RealtimeResource.symptoms);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(loads[RealtimeResource.symptoms], 1);
      expect(loads[RealtimeResource.periodDays], 0);
    });

    test('"all" recarga todo', () async {
      realtime.debugEmit(RealtimeResource.all);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(loads[RealtimeResource.periodDays], 1);
      expect(loads[RealtimeResource.symptoms], 1);
      expect(loads[RealtimeResource.intimacy], 1);
    });
  });

  test('FallbackOnError usa el respaldo si la llamada remota falla', () async {
    final remote = _Remote();
    expect(await remote.remoteOr(() async => 'nube', () async => 'local'), 'nube');
    expect(await remote.remoteOr<String>(() => throw const ApiError(503, 'x'), () async => 'local'), 'local');
  });
}
