import 'package:flutter_test/flutter_test.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/features/authentication/data/repositories/local_user_repository.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';

void main() {
  test('las preguntas del ciclo solo se hacen la primera vez', () async {
    final session = SessionController(LocalUserRepository());

    await session.register(name: 'Ana', email: 'ana@correo.com', password: '123456');
    expect(AppRoutes.afterLogin(session.user!.cycleSetupCompleted), AppRoutes.cycleSetup);

    await session.updateProfile(session.user!.copyWith(
      ageGroup: AgeGroup.teen,
      averagePeriodDuration: 6,
      averageCycleLength: 32,
      cycleSetupCompleted: true,
    ));

    await session.logout();
    await session.login(email: 'ana@correo.com', password: '123456');
    expect(AppRoutes.afterLogin(session.user!.cycleSetupCompleted), AppRoutes.home);
    expect(session.user!.ageGroup, AgeGroup.teen);
    expect(session.user!.averagePeriodDuration, 6);
    expect(session.user!.averageCycleLength, 32);
  });
}
