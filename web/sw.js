// Service Worker (tema 3 del curso: workers como proxy de red).
//
// Intercepta las peticiones de la página para que la app abra aunque no haya
// internet. Estrategia "network-first": siempre intenta traer la versión
// nueva de Vercel y guarda una copia; si no hay red, usa la copia.
// Así nunca se queda una versión vieja después de un despliegue.
//
// No toca las llamadas al backend (otro origen): esos datos siempre van en vivo.

const CACHE = 'spring-shell-v1';

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || url.origin !== self.location.origin) return;

  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(async () => {
        const cached = await caches.match(request);
        if (cached) return cached;
        // Sin red y sin copia: para la navegación, devolver el index guardado (app de una sola página).
        if (request.mode === 'navigate') {
          const shell = await caches.match('/');
          if (shell) return shell;
        }
        return Response.error();
      }),
  );
});
