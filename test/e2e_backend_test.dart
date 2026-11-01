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
