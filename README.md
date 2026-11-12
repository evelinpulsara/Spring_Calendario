# Spring Calendario (Frontend)

App Flutter para seguir el ciclo menstrual, síntomas y bienestar, con un asistente
de IA. Funciona como app en el celular y como página web en la computadora.

Backend (Spring Boot + PostgreSQL + Gemini): https://github.com/evelinpulsara/Spring_Backend

## Correr en tu computadora

1. Enciende el backend (ver su README):
   ```bash
   cd ../backend && ./mvnw spring-boot:run
   ```
2. Corre la app:
   ```bash
   flutter pub get
   flutter run -d chrome
   ```
3. Entra con la cuenta de prueba **demo@spring.app / Spring1234** o crea una cuenta.

Por defecto la app usa el backend en `http://localhost:8080`. Otras opciones:

```bash
# Otro backend
flutter run -d chrome --dart-define=API_URL=https://mi-backend.onrender.com
# Sin backend (datos de prueba en memoria)
flutter run -d chrome --dart-define=USE_BACKEND=false
```

## Desplegar en Vercel

1. Entra a https://vercel.com con tu cuenta de GitHub → **Add New → Project** →
   importa el repositorio `Spring_Calendario`.
2. Framework Preset: **Other**. No cambies los comandos: `vercel.json` ya instala
   Flutter y compila la web.
3. En **Environment Variables** agrega:
   `API_URL` = la URL del backend en Render (ej. `https://spring-backend.onrender.com`).
4. **Deploy**. Copia la URL que te da Vercel y agrégala en Render como
   `CORS_ALLOWED_ORIGINS` (si no, el navegador bloquea las peticiones).

## Tests

```bash
flutter test
```

`test/e2e_backend_test.dart` prueba la app contra el backend real; se salta sola si
el backend no está encendido.
