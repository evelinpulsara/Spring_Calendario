// Métricas de rendimiento (tema 1 del curso: INP, Event Loop y renderizado).
//
// INP (Interaction to Next Paint) = Input Delay + Processing Duration + Presentation Delay
//   - Input Delay:        desde el clic hasta que el Main Thread empieza a atenderlo
//                         (si está ocupado con una tarea larga, hay espera).
//   - Processing:         lo que tardan los manejadores del evento (JS).
//   - Presentation Delay: Style → Layout → Paint → Composite del siguiente frame.
// Umbrales: bueno ≤ 200 ms, necesita mejora ≤ 500 ms, pobre > 500 ms.
//
// Se guarda en window.springVitals y la app Flutter lo muestra en Perfil.
(function () {
  const vitals = (window.springVitals = {
    inp: null,
    rating: null,
    inputDelay: null,
    processing: null,
    presentation: null,
    interactions: 0,
    longTasks: 0,
    fcp: null,
    ttfb: null,
    supported: false,
    serviceWorker: false,
    crossOriginIsolated: !!window.crossOriginIsolated,
  });

  const rate = (ms) => (ms <= 200 ? 'good' : ms <= 500 ? 'needs-improvement' : 'poor');

  // Peor duración por interacción (un clic genera varios eventos: pointerdown, pointerup, click).
  const worstByInteraction = new Map();

  function updateInp() {
    const list = [...worstByInteraction.values()].sort((a, b) => b.duration - a.duration);
    if (!list.length) return;
    // Con pocas interacciones INP es la peor; con muchas, se ignora 1 de cada 50 (p98).
    const entry = list[Math.min(list.length - 1, Math.floor(list.length / 50))];
    vitals.inp = Math.round(entry.duration);
    vitals.rating = rate(entry.duration);
    vitals.inputDelay = Math.round(entry.processingStart - entry.startTime);
    vitals.processing = Math.round(entry.processingEnd - entry.processingStart);
    vitals.presentation = Math.max(
      0,
      Math.round(entry.startTime + entry.duration - entry.processingEnd),
    );
    vitals.interactions = list.length;
  }

  try {
    // Event Timing API (Chrome/Edge/Firefox; Safari aún no la tiene).
    new PerformanceObserver((list) => {
      for (const e of list.getEntries()) {
        if (!e.interactionId) continue;
        const prev = worstByInteraction.get(e.interactionId);
        if (!prev || e.duration > prev.duration) worstByInteraction.set(e.interactionId, e);
      }
      updateInp();
    }).observe({ type: 'event', durationThreshold: 16, buffered: true });
    vitals.supported = true;
  } catch (_) {}

  try {
    // Tareas largas (> 50 ms) que bloquean el Main Thread.
    new PerformanceObserver((list) => {
      vitals.longTasks += list.getEntries().length;
    }).observe({ type: 'longtask', buffered: true });
  } catch (_) {}

  try {
    // FCP: primer contenido pintado (el esqueleto HTML estático de index.html).
    new PerformanceObserver((list) => {
      for (const e of list.getEntries()) {
        if (e.name === 'first-contentful-paint') vitals.fcp = Math.round(e.startTime);
      }
    }).observe({ type: 'paint', buffered: true });
  } catch (_) {}

  try {
    const nav = performance.getEntriesByType('navigation')[0];
    if (nav) vitals.ttfb = Math.round(nav.responseStart);
  } catch (_) {}
})();
