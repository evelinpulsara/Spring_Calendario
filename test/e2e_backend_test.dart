// Prueba de punta a punta contra el backend real (opcional).
// Requiere el backend encendido en http://localhost:8080:
//   cd backend && ./mvnw spring-boot:run
//   cd frontend && flutter test test/e2e_backend_test.dart
// Si el backend no está encendido, la prueba se salta sola.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/authentication/data/repositories/api_user_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/api_cycle_repository.dart';
import 'package:spring_calendario/features/cycle/domain/entities/flow_intensity.dart';
import 'package:spring_calendario/features/cycle/domain/entities/period_entry.dart';
import 'package:spring_calendario/features/intimacy/data/repositories/api_intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/symptoms/data/repositories/api_symptom_repository.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_entry.dart';
import 'package:spring_calendario/features/symptoms/domain/entities/symptom_type.dart';

Future<bool> _backendUp() async {
  try {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    final res = await (await client.getUrl(Uri.parse('http://localhost:8080/api/health'))).close();
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void main() {
  test('la app guarda y lee datos de la base de datos', () async {
    if (!await _backendUp()) {
      markTestSkipped('Backend apagado: prueba omitida');
      return;
    }
    SharedPreferences.setMockInitialValues({});
    final api = ApiClient(baseUrl: 'http://localhost:8080');
    final users = ApiUserRepository(api);
    final email = 'e2e-${DateTime.now().millisecondsSinceEpoch}@correo.com';

    final user = await users.register(name: 'Prueba', email: email, password: 'secreto123');
    expect(user.cycleSetupCompleted, isFalse);
    await users.updateUser(user.copyWith(cycleSetupCompleted: true, averagePeriodDuration: 6));

    final cycles = ApiCycleRepository(api);
    await cycles.savePeriodEntry(
        PeriodEntry(id: 'x', date: DateTime(2026, 10, 22), flow: FlowIntensity.heavy));
    final symptoms = ApiSymptomRepository(api);
    await symptoms.saveEntriesForDate(DateTime(2026, 10, 22), [
      SymptomEntry(id: 'a', date: DateTime(2026, 10, 22), type: SymptomType.cramps, intensity: 4),
    ]);
    final intimacy = ApiIntimacyRepository(api);
    await intimacy.save(
        IntimacyEntry(id: 'i', date: DateTime(2026, 11, 6), protection: ProtectionType.condom));

    // "Recargar la página": nueva instancia que recupera la sesión guardada.
    final reloaded = ApiUserRepository(ApiClient(baseUrl: 'http://localhost:8080'));
    final restored = await reloaded.getCurrentUser();
    expect(restored!.email, email);
    expect(restored.cycleSetupCompleted, isTrue);
    expect(restored.averagePeriodDuration, 6);

    expect((await cycles.getPeriodEntries()).single.flow, FlowIntensity.heavy);
    expect((await symptoms.getAllEntries()).single.type, SymptomType.cramps);
    expect((await intimacy.getAll()).single.protection, ProtectionType.condom);

    await cycles.clear();
    expect(await cycles.getPeriodEntries(), isEmpty);
    expect(await intimacy.getAll(), isEmpty);

    await users.logout();
    expect(await ApiUserRepository(api).getCurrentUser(), isNull);
  });
}
