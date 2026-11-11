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
