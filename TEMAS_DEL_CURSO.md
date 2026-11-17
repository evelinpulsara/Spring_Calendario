# Temas del curso aplicados — Frontend (Spring_Calendario)

Curso: Programación Orientada a la Web. El backend (repo Spring_Backend) tiene su
propio `TEMAS_DEL_CURSO.md` con SSE, fan-out, escalado y el contrato OpenAPI.

Todo se puede ver en la app en **Perfil → Rendimiento y tiempo real** (solo en la web).

## Tema 1 — Métricas de rendimiento, Event Loop e INP

| Concepto | Dónde está |
|---|---|
| **INP = Input Delay + Processing + Presentation Delay** | `web/perf/web_vitals.js` usa la Event Timing API (`PerformanceObserver` tipo `event`), agrupa por `interactionId`, toma la peor interacción (p98 si hay más de 50) y calcula las 3 partes. |
| **Umbrales** bueno ≤ 200 ms / necesita mejora ≤ 500 ms / pobre > 500 ms | Mismo archivo (`rate`) y colores en `tech_panel_card.dart`. |
| **Tareas largas que bloquean el Main Thread** | Se cuentan con `PerformanceObserver` tipo `longtask` (> 50 ms). |
| **Event Loop (tasks vs microtasks)** | `tech_panel_card.dart#_export`: antes de mandar el trabajo al worker se hace `await WidgetsBinding.instance.endOfFrame`, para que primero se **pinte** el estado "Exportando…". Una microtask no lo lograría: la cola de microtasks se vacía antes de que el navegador pinte. Los eventos SSE llegan como *tasks* (`sse_connection_web.dart`). |
| **Main Thread vs Compositor Thread** | La animación del esqueleto inicial (`web/index.html`) usa solo `transform` y `opacity`, que corren en el Compositor Thread sin Layout ni Paint. |
| Safari / iPhone | No tiene Event Timing API: el INP se **estima** siguiendo el Event Loop (`setTimeout` → `requestAnimationFrame` → `setTimeout`) y en Perfil sale como "INP (estimado)". |

## Tema 3 — Paralelismo real en el navegador (Workers)

| Concepto | Dónde está |
|---|---|
| **Web Worker** | `web/workers/export_worker.js`: arma el CSV de todos los registros y un resumen en **otro hilo**. Botón **Perfil → Exportar mis datos (CSV)**. Muestra cuántos ms tardó dentro del worker. |
| **postMessage** | `lib/core/web/browser_features_web.dart`: envía los datos al worker y recibe el resultado (copia por *structured clone*). El worker no toca el DOM: la descarga la hace el Main Thread. |
| **Service Worker** (proxy de red, offline) | `web/sw.js` (registrado en `index.html`): estrategia *network-first*, guarda copia de la app y la usa si no hay internet. No intercepta la API (los datos van siempre en vivo). |
| Conflicto con Flutter | `web/flutter_bootstrap.js` propio: arranca Flutter **sin** su Service Worker obsoleto, que se desregistra solo y borraría el nuestro. |
| **SharedArrayBuffer / Atomics / crossOriginIsolated** | No se usan: requieren los headers COOP/COEP, que bloquearían recursos de otros orígenes, y el export no necesita memoria compartida (postMessage basta). La app muestra el valor real de `crossOriginIsolated` en `window.springVitals`. |

## Tema 4 — Patrones de rendering web

| Concepto | Dónde está |
|---|---|
| **CSR** | Flutter web es Client-Side Rendering: es un panel privado con sesión, sin necesidad de SEO, que es el caso ideal de CSR. |
| Cuello de botella de CSR: **FCP** | `web/index.html` trae un **esqueleto HTML/CSS estático** generado en el build (idea de **SSG**): se pinta apenas llega de la CDN de Vercel, antes de descargar `main.dart.js`, y se quita en el evento `flutter-first-frame`. El FCP se ve en Perfil. |
| ¿Por qué no SSR / ISR / Streaming SSR? | No hay contenido público que indexar y todo depende de la sesión de la usuaria; Flutter web no tiene SSR. |

## Tema 2 — Validación en runtime y contract-first (parte del frontend)

| Concepto | Dónde está |
|---|---|
| **Validar vs parsear** | `lib/core/network/json_parse.dart`: `jsonDecode` devuelve `dynamic` (el compilador no sabe qué mandó el servidor). En vez de solo revisar, se **parsea** a tipos seguros o se lanza `ContractViolation` con un mensaje claro. Es la misma idea que Zod en TypeScript (*type erasure*). |
| Siguiendo el contrato | Los repositorios `api_*_repository.dart` y los eventos SSE (`RealtimeEvent.parse`) usan las reglas de `openapi.yaml` del backend (enums, fechas YYYY-MM-DD, rangos). |

## Tema 5 — Tiempo real (parte del frontend)

`lib/core/realtime/realtime_service.dart`: pide el ticket, abre el `EventSource`,
reconecta con espera creciente (5 s, 10 s, 20 s… máx. 60 s) y, al llegar
`records-changed`, recarga **solo** lo que cambió, con *debounce* de 300 ms
(`lib/core/realtime/realtime_sync.dart`).

## Pruebas

`test/realtime_and_contract_test.dart`: parseo según el contrato, eventos inválidos,
conexión/reconexión del servicio de tiempo real.
