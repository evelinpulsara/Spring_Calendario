import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/core/network/json_parse.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/core/realtime/sse_connection.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/profile/presentation/widgets/tech_panel_card.dart';

class FakeSse implements SseConnection {
  String? openedUrl;
  void Function(String, String)? emit;
  void Function()? fail;
  int closes = 0;

  @override
  bool get isSupported => true;

  @override
  void open(String url,
      {required List<String> eventNames,
      required void Function(String event, String data) onEvent,
      required void Function() onError}) {
    openedUrl = url;
    emit = onEvent;
    fail = onError;
  }

  @override
  void close() => closes++;
}

void main() {
  group('JsonObject (parsear según el contrato)', () {
    test('convierte JSON válido en datos tipados', () {
      final list = JsonObject.parseList(
        jsonDecode('[{"date":"2026-11-01","flow":"heavy","n":3}]'),
        'period-days',
      );
      expect(list.single.date('date'), DateTime(2026, 11, 1));
      expect(list.single.enumValue('flow', FlowIntensity.values), FlowIntensity.heavy);
      expect(list.single.integer('n', min: 1, max: 5), 3);
    });

    test('falla con un error claro si el servidor rompe el contrato', () {
      final j = JsonObject.parse({'flow': 'muy-fuerte', 'date': '01/11/2026', 'n': 9}, 'x');
      expect(() => j.enumValue('flow', FlowIntensity.values), throwsA(isA<ContractViolation>()));
      expect(() => j.date('date'), throwsA(isA<ContractViolation>()));
      expect(() => j.integer('n', min: 1, max: 5), throwsA(isA<ContractViolation>()));
      expect(() => j.string('falta'), throwsA(isA<ContractViolation>()));
      expect(() => JsonObject.parseList({'no': 'lista'}, 'x'), throwsA(isA<ContractViolation>()));
    });
  });

  group('RealtimeEvent', () {
    test('parsea el evento records-changed', () {
      final e = RealtimeEvent.parse(
          '{"type":"records-changed","resource":"symptoms","at":"2026-11-16T20:00:00Z"}');
      expect(e.resource, RealtimeResource.symptoms);
    });

    test('rechaza eventos que no cumplen el contrato', () {
      expect(() => RealtimeEvent.parse('no-json'), throwsA(isA<ContractViolation>()));
      expect(() => RealtimeEvent.parse('{"resource":"otro","at":"2026-11-16T20:00:00Z"}'),
          throwsA(isA<ContractViolation>()));
    });
  });

  group('RealtimeService', () {
    late FakeSse sse;
    late RealtimeService service;

    setUp(() {
      final api = ApiClient(
        baseUrl: 'https://api.test',
        client: MockClient((request) async {
          expect(request.url.path, '/api/events/ticket');
          return http.Response('{"ticket":"abc 123"}', 200);
        }),
      );
      sse = FakeSse();
      service = RealtimeService(api, connection: sse);
    });

    tearDown(() => service.dispose());

    test('pide un ticket, abre el stream y avisa los cambios', () async {
      final received = <RealtimeEvent>[];
      service.changes.listen(received.add);

      service.start();
      await Future<void>.delayed(Duration.zero);
      expect(sse.openedUrl, 'https://api.test/api/events/stream?ticket=abc+123');
      expect(service.status, RealtimeStatus.connecting);

      sse.emit!('connected', 'ok');
      expect(service.status, RealtimeStatus.live);

      sse.emit!('records-changed', '{"resource":"period-days","at":"2026-11-16T20:00:00Z"}');
      sse.emit!('records-changed', '{"roto":true}');
      await Future<void>.delayed(Duration.zero);
      expect(received.map((e) => e.resource), [RealtimeResource.periodDays]);
      expect(service.eventsReceived, 1);
    });

    test('si se corta, cierra y reintenta con un ticket nuevo', () async {
      service.start();
      await Future<void>.delayed(Duration.zero);
      sse.fail!();
      expect(service.status, RealtimeStatus.retrying);
      expect(sse.closes, greaterThan(0));

      service.stop();
      expect(service.status, RealtimeStatus.off);
    });

    test('en el celular: pausa en segundo plano y al volver reconecta y recarga todo', () async {
      final received = <RealtimeEvent>[];
      service.changes.listen(received.add);
      service.start();
      await Future<void>.delayed(Duration.zero);
      sse.emit!('connected', 'ok');

      service.pause();
      expect(service.status, RealtimeStatus.paused);
      final closesBefore = sse.closes;
      sse.fail!();
      expect(service.status, RealtimeStatus.paused);
      expect(sse.closes, greaterThanOrEqualTo(closesBefore));

      sse.openedUrl = null;
      service.resume();
      await Future<void>.delayed(Duration.zero);
      expect(sse.openedUrl, isNotNull);
      expect(received.single.resource, RealtimeResource.all);
    });
  });

  testWidgets('el panel técnico cabe en la pantalla de un celular', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final realtime = RealtimeService(
      ApiClient(client: MockClient((_) async => http.Response('{}', 500))),
      connection: FakeSse(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: realtime,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: TechPanelCard())),
        ),
      ),
    );
    expect(find.text('Rendimiento y tiempo real'), findsOneWidget);
    expect(find.text('Exportar mis datos (CSV)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
