// Web Worker (tema 3 del curso: paralelismo real en el navegador).
//
// Corre en un HILO SEPARADO del Main Thread: arma el CSV con todos los
// registros y calcula un resumen sin congelar la interfaz (el Main Thread
// sigue libre para pintar y responder clics → mejor INP).
//
// Un worker NO tiene acceso al DOM: recibe los datos con postMessage y
// devuelve el resultado también con postMessage (los datos se copian con
// "structured clone"; no se comparte memoria).

self.onmessage = (event) => {
  const started = performance.now();
  const { periodDays = [], symptoms = [], intimacy = [], language = 'es' } = event.data || {};
  const es = language === 'es';

  const rows = [];
  for (const p of periodDays) rows.push([p.date, es ? 'periodo' : 'period', p.flow, '']);
  for (const s of symptoms) rows.push([s.date, es ? 'sintoma' : 'symptom', s.type, String(s.intensity)]);
  for (const i of intimacy) rows.push([i.date, es ? 'relacion' : 'intimacy', i.protection, '']);
  rows.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));

  // Resumen: síntoma más frecuente e intensidad promedio por síntoma.
  const bySymptom = {};
  for (const s of symptoms) {
    const acc = (bySymptom[s.type] ||= { count: 0, total: 0 });
    acc.count += 1;
    acc.total += Number(s.intensity) || 0;
  }
  const summary = Object.entries(bySymptom)
    .map(([type, { count, total }]) => ({ type, count, average: +(total / count).toFixed(2) }))
    .sort((a, b) => b.count - a.count);

  const header = es ? ['fecha', 'tipo', 'detalle', 'intensidad'] : ['date', 'kind', 'detail', 'intensity'];
  const escape = (v) => (/[",\n]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v);
  const csv = [header, ...rows].map((r) => r.map(escape).join(',')).join('\n');

  self.postMessage({
    csv,
    rows: rows.length,
    summary,
    workerMs: +(performance.now() - started).toFixed(2),
  });
};
