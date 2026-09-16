import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_colors.dart';
import 'package:lunaflow/core/utils/validators.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';

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
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'Welcome back' : 'Create your account',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? 'Log in to continue tracking your cycle.'
                      : 'Your data stays on this device in the MVP.',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 28),
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => Validators.requiredField(v, 'Name'),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: Validators.password,
                ),
                if (session.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(session.errorMessage!,
                      style: const TextStyle(color: AppColors.deepPink, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: session.isBusy ? null : _submit,
                  child: session.isBusy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isLogin ? 'Log in' : 'Create account'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    session.clearError();
                    setState(() => _isLogin = !_isLogin);
                  },
                  child: Text(_isLogin
                      ? "Don't have an account? Register"
                      : 'Already have an account? Log in'),
                ),
                if (AppConstants.seedDemoData)
                  TextButton.icon(
                    onPressed: _fillDemoCredentials,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('Use demo account'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
