import 'package:flutter/material.dart';
import 'package:lunaflow/app.dart';
import 'package:lunaflow/core/di/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LunaFlowApp(dependencies: AppDependencies()));
}
