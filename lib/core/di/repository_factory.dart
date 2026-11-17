import 'package:spring_calendario/core/network/api_client.dart';
import 'package:spring_calendario/features/authentication/data/repositories/api_user_repository.dart';
import 'package:spring_calendario/features/authentication/data/repositories/local_user_repository.dart';
import 'package:spring_calendario/features/authentication/domain/repositories/user_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/api_cycle_repository.dart';
import 'package:spring_calendario/features/cycle/data/repositories/in_memory_cycle_repository.dart';
import 'package:spring_calendario/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:spring_calendario/features/intimacy/data/repositories/api_intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/data/repositories/in_memory_intimacy_repository.dart';
import 'package:spring_calendario/features/intimacy/domain/repositories/intimacy_repository.dart';
import 'package:spring_calendario/features/symptoms/data/repositories/api_symptom_repository.dart';
import 'package:spring_calendario/features/symptoms/data/repositories/in_memory_symptom_repository.dart';
import 'package:spring_calendario/features/symptoms/domain/repositories/symptom_repository.dart';

abstract interface class RepositoryFactory {
  factory RepositoryFactory({required bool useBackend, required ApiClient api}) =>
      useBackend ? ApiRepositoryFactory(api) : const LocalRepositoryFactory();

  UserRepository users();
  CycleRepository cycles();
  SymptomRepository symptoms();
  IntimacyRepository intimacy();
}

class ApiRepositoryFactory implements RepositoryFactory {
  const ApiRepositoryFactory(this._api);

  final ApiClient _api;

  @override
  UserRepository users() => ApiUserRepository(_api);

  @override
  CycleRepository cycles() => ApiCycleRepository(_api);

  @override
  SymptomRepository symptoms() => ApiSymptomRepository(_api);

  @override
  IntimacyRepository intimacy() => ApiIntimacyRepository(_api);
}

class LocalRepositoryFactory implements RepositoryFactory {
  const LocalRepositoryFactory();

  @override
  UserRepository users() => LocalUserRepository();

  @override
  CycleRepository cycles() => InMemoryCycleRepository();

  @override
  SymptomRepository symptoms() => InMemorySymptomRepository();

  @override
  IntimacyRepository intimacy() => InMemoryIntimacyRepository();
}
