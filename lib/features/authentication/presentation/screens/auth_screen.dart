import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/core/utils/validators.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';

/// Local (simulated) login / register screen.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.startInLoginMode = false});

  final bool startInLoginMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin = widget.startInLoginMode;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = context.read<SessionController>();
    final success = _isLogin
        ? await session.login(email: _emailController.text, password: _passwordController.text)
        : await session.register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (success && mounted) {
      // Usuaria nueva (o sin cuestionario): primero las preguntas de su ciclo.
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.afterLogin(session.user?.cycleSetupCompleted ?? false),
        (_) => false,
      );
    }
  }

  void _fillDemoCredentials() {
    setState(() => _isLogin = true);
    _emailController.text = AppConstants.demoEmail;
    _passwordController.text = AppConstants.demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: CenteredContent(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLogin
                          ? AppLanguage.tr('Bienvenida de nuevo', 'Welcome back')
                          : AppLanguage.tr('Crea tu cuenta', 'Create your account'),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? AppLanguage.tr('Inicia sesión para seguir registrando tu ciclo.',
                              'Log in to continue tracking your cycle.')
                          : AppLanguage.tr(
                              'En este prototipo tus datos se guardan en este dispositivo.',
                              'In this MVP your data is saved on this device.'),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 28),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                            labelText: AppLanguage.tr('Nombre', 'Name'),
                            prefixIcon: const Icon(Icons.person_outline)),
                        validator: (v) =>
                            Validators.requiredField(v, AppLanguage.tr('El nombre', 'Name')),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: AppLanguage.tr('Correo electrónico', 'Email'),
                          prefixIcon: const Icon(Icons.mail_outline)),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Contraseña', 'Password'),
