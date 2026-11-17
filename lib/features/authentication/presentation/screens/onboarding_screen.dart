import 'package:flutter/material.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';
import 'package:spring_calendario/shared/widgets/moon_widget.dart';

class _OnboardingPageData {
  const _OnboardingPageData(this.title, this.text, this.moonProgress);
  final String title;
  final String text;
  final double moonProgress;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static List<_OnboardingPageData> get _pages => AppLanguage.isSpanish
      ? const [
          _OnboardingPageData(
            'Sigue tu ciclo',
            'Registra tus días de menstruación y mira cada fase de tu ciclo en un solo lugar tranquilo.',
            0.12,
          ),
          _OnboardingPageData(
            'Entiende tu cuerpo',
            'Registra cólicos, ánimo, sueño y más. Spring predice tu próxima menstruación y tu ventana fértil.',
            0.3,
          ),
          _OnboardingPageData(
            'Conoce al Asistente Spring',
            'Recibe consejos amables y personalizados según los patrones de tus propios datos.',
            0.5,
          ),
        ]
      : const [
          _OnboardingPageData(
            'Follow your cycle',
            'Log your period days and see every phase of your cycle in one calm place.',
            0.12,
          ),
          _OnboardingPageData(
            'Understand your body',
            'Track cramps, mood, sleep and more. Spring predicts your next period and fertile window.',
            0.3,
          ),
          _OnboardingPageData(
            'Meet Spring Assistant',
            'Get gentle, personalised insights based on the patterns in your own data.',
            0.5,
          ),
        ];

  final PageController _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: CenteredContent(
        maxWidth: 520,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.heroGradient,
                          ),
                          child: MoonWidget(size: 150, progress: page.moonProgress),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, height: 1.45, color: AppColors.textMuted),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.purple : AppColors.lavender,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.auth, arguments: false),
                  child: Text(AppLanguage.tr('Comenzar', 'Get Started')),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.auth, arguments: true),
                child: Text(AppLanguage.tr('Ya tengo una cuenta', 'I already have an account')),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
