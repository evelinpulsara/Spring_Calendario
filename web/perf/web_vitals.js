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
    estimated: false,
    serviceWorker: false,
    crossOriginIsolated: !!window.crossOriginIsolated,
  });

  const rate = (ms) => (ms <= 200 ? 'good' : ms <= 500 ? 'needs-improvement' : 'poor');

  const worstByInteraction = new Map();

  function record(id, it) {
    const prev = worstByInteraction.get(id);
    if (!prev || it.duration > prev.duration) worstByInteraction.set(id, it);
    const list = [...worstByInteraction.values()].sort((a, b) => b.duration - a.duration);
    const worst = list[Math.min(list.length - 1, Math.floor(list.length / 50))];
    vitals.inp = Math.round(worst.duration);
    vitals.rating = rate(worst.duration);
    vitals.inputDelay = Math.max(0, Math.round(worst.inputDelay));
    vitals.processing = Math.max(0, Math.round(worst.processing));
    vitals.presentation = Math.max(0, Math.round(worst.presentation));
    vitals.interactions = list.length;
  }

  const types = (window.PerformanceObserver && PerformanceObserver.supportedEntryTypes) || [];

  if (types.includes('event')) {
    new PerformanceObserver((list) => {
      for (const e of list.getEntries()) {
        if (!e.interactionId) continue;
        record(e.interactionId, {
          duration: e.duration,
          inputDelay: e.processingStart - e.startTime,
          processing: e.processingEnd - e.processingStart,
          presentation: e.startTime + e.duration - e.processingEnd,
        });
      }
    }).observe({ type: 'event', durationThreshold: 16, buffered: true });
    vitals.supported = true;
  } else {
    let nextId = 0;
    const onInput = (event) => {
      const id = ++nextId;
      const handlerStart = performance.now();
      let start = event.timeStamp;
      if (!(start > 0 && start <= handlerStart)) start = handlerStart;
      setTimeout(() => {
        const processingEnd = performance.now();
        requestAnimationFrame(() => {
          setTimeout(() => {
            const end = performance.now();
            record(id, {
              duration: end - start,
              inputDelay: handlerStart - start,
              processing: processingEnd - handlerStart,
              presentation: end - processingEnd,
            });
          }, 0);
        });
      }, 0);
    };
    for (const type of ['pointerup', 'keydown']) {
      window.addEventListener(type, onInput, { capture: true, passive: true });
    }
    vitals.supported = true;
    vitals.estimated = true;
  }

  if (types.includes('longtask')) {
    new PerformanceObserver((list) => {
      vitals.longTasks += list.getEntries().length;
    }).observe({ type: 'longtask', buffered: true });
  }

  if (types.includes('paint')) {
    new PerformanceObserver((list) => {
      for (const e of list.getEntries()) {
        if (e.name === 'first-contentful-paint') vitals.fcp = Math.round(e.startTime);
      }
    }).observe({ type: 'paint', buffered: true });
  }

  try {
    const nav = performance.getEntriesByType('navigation')[0];
    if (nav) vitals.ttfb = Math.round(nav.responseStart);
  } catch (_) {}
})();
