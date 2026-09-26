# LunaFlow

Menstrual cycle and wellness tracking MVP built with Flutter (academic prototype).
It does not provide medical advice or diagnosis.

## Run

```bash
flutter create . --project-name lunaflow   # generates android/ios/web folders (keeps lib/)
flutter pub get
flutter run
flutter test
```

Demo account: `demo@lunaflow.app` / `Luna1234` (button "Use demo account" on the login screen).
Demo data is seeded in memory (`AppConstants.seedDemoData`). Set it to `false` for an empty app.

## Architecture (feature-based Clean Architecture)

```
lib/
  core/        constants, theme, routes, utils, di (AppDependencies = composition root)
  shared/      reusable widgets (LunarCard, MoonWidget, MainShell...)
  features/<feature>/
    domain/        entities, repository interfaces, pure services (no Flutter, no storage)
    data/          repository / service implementations (in-memory today)
    presentation/  controllers (ChangeNotifier) + screens + widgets
```

Dependency rule: presentation -> domain <- data. Screens never create repositories;
`AppDependencies` wires everything and Provider exposes the controllers.

## Where to extend

* Database / backend: implement `UserRepository`, `CycleRepository`, `SymptomRepository`
  (and optionally `PredictionRepository`) with Supabase, Firebase or a REST API, then change the
  lines marked `>>> DATABASE` in `lib/core/di/app_dependencies.dart`.
* Real AI: implement `AiInsightService` (see `MockAiInsightService`) and change the line marked
  `>>> AI` in the same file. Call your backend, not the AI provider directly, so no API key ships in the app.
* Persistence without a backend: add `shared_preferences`/`sqflite` implementations of the repositories.
