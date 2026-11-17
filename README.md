# Spring — Frontend

Spring es una app para seguir el ciclo menstrual: registra periodos, síntomas y relaciones,
predice el próximo periodo con IA y se sincroniza en vivo entre celular y computadora.

- **App en línea:** https://spring-calendario.vercel.app
- **Cuenta demo:** `demo@spring.app` / `Spring1234` (ya tiene varios meses de datos)
- **Backend:** https://github.com/evelinpulsara/Spring_Backend

> La primera carga puede tardar unos 50 s mientras el servidor gratuito de Render se enciende.

## Cómo funciona

```
Flutter web (Vercel)  ──REST + JWT──►  Spring Boot (Render)  ──►  PostgreSQL (Supabase)
        ▲                                     │
        └────────── avisos en vivo (SSE) ─────┘──►  Gemini (IA)
```

La app es Flutter web con Provider. Cada módulo (`lib/features/`) separa dominio, datos y
presentación. Si el backend o la IA no responden, la app usa un cálculo local y no se cae.

## Temas del curso

Se pueden ver en vivo en **Perfil → Rendimiento y tiempo real**.

| Tema | Qué se implementó | Dónde |
|------|-------------------|-------|
| 1. Rendimiento e INP | Mide el INP (entrada + procesamiento + pintado), el FCP y las tareas largas; en Safari lo estima siguiendo el Event Loop | `web/perf/web_vitals.js` |
| 2. Validación en runtime | Las respuestas del servidor se parsean a tipos seguros según el contrato `openapi.yaml` | `lib/core/network/json_parse.dart` |
| 3. Workers | Web Worker que arma el CSV en otro hilo (botón *Exportar mis datos*); Service Worker para abrir sin internet | `web/workers/`, `web/sw.js` |
| 4. Rendering | CSR con un esqueleto HTML estático que se pinta antes que Flutter | `web/index.html` |
| 5. Tiempo real | Conexión SSE con reconexión, pausa en segundo plano y recarga solo de lo que cambió | `lib/core/realtime/` |

**Patrones de diseño:** Repository, Strategy (IA remota o local), Observer (Provider),
Abstract Factory (`lib/core/di/repository_factory.dart`) y Mixin (`lib/core/network/json_endpoint.dart`).

Más detalle en [TEMAS_DEL_CURSO.md](TEMAS_DEL_CURSO.md).

## Ejecutar

```bash
flutter pub get
flutter run -d chrome --dart-define=USE_BACKEND=false   # sin backend, con datos de prueba
flutter test                                            # pruebas
```
