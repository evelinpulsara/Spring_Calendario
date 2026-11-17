import 'package:material_ui/material_ui.dart';
import 'package:spring_calendario/app.dart';
import 'package:spring_calendario/core/di/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SpringApp(dependencies: AppDependencies()));
}
