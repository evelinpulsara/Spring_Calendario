{{flutter_js}}
{{flutter_build_config}}

// Arranque de Flutter SIN su Service Worker (Flutter lo marcó como obsoleto y
// el suyo se desregistra solo, lo que borraría el nuestro). El Service Worker
// de la app es web/sw.js y se registra en index.html.
_flutter.loader.load();
