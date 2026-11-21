# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Especificación del proyecto

Las reglas del proyecto, rutas, endpoints a usar y reglas de presentación están en
`docs/CLAUDE.md` (importado abajo). La guía completa del backend, con todos los endpoints
y ejemplos de respuesta, está en `docs/endpoints.md`: consultarla por sección (`## Tracker`,
`## Usuarios`, `### Datos de otro jugador`, `## Errores comunes`) en vez de leerla entera.

@docs/CLAUDE.md

## Estado actual (actualizar al avanzar)

- **Fase 0 (base) lista:** cliente HTTP, sesión, router con redirecciones y login funcional.
- Ranking, perfil, detalle de Pokémon y `/yo` son marcadores (`EnConstruccion`).
- Siguiente: Fase 1 (dirección visual → tokens de tema), luego las pantallas.
- Solo existe la plataforma **web** (`web/`).
- Repo: `origin` = GitHub `Etor23/tracker_pokeclase`, rama principal `master`.

## Comandos

Toolchain: Flutter 3.47.0 (stable), Dart SDK `^3.13.0`.

```bash
flutter pub get                                   # instalar dependencias
flutter run -d chrome --web-browser-flag "--disable-web-security"   # mientras el backend no tenga CORS
flutter run -d chrome --dart-define=API_URL=https://backpokemon.runasp.net
flutter analyze                                   # lints (flutter_lints, ver analysis_options.yaml)
dart format lib test
flutter test                                      # todas las pruebas
flutter test test/core/api_client_test.dart       # un archivo
flutter test --plain-name "texto plano"           # una prueba por nombre
flutter build web
```

## Arquitectura

```
main.dart  → arma SessionController + ApiClient y los pasa a TrackerApp
app.dart   → MultiProvider (sesión, ApiClient, repositorios) + MaterialApp.router
core/      → config, api/ (cliente y errores), session/, router.dart, theme/
data/      → json.dart (lectores tolerantes) y repositorios por dominio
features/  → una carpeta por pantalla
```

- **Estado: `provider`.** Los repositorios se registran en `app.dart` con `Provider` y se
  leen con `context.read<...>()`; el estado de cada pantalla va en un `ChangeNotifier`.
- **`ApiClient` solo expone `get()` y `login()`.** Así se impone la regla de solo lectura:
  no agregar métodos de escritura. Lanza excepciones selladas (`ApiException`); en la UI se
  muestran con `mensajeParaUsuario(error)`, nunca el texto del backend.
- **Sesión:** `SessionController` (ChangeNotifier) guarda la sesión en `sessionStorage`
  mediante `SessionStore` (importación condicional: web real vs. memoria en las pruebas).
  La expiración se revisa al leer `session`, sin temporizadores. Un 401 en una ruta con
  token llama a `expire()`.
- **Navegación:** el router escucha la sesión (`refreshListenable`), y
  `redirigirSegunSesion` manda a `/login?from=...` y de regreso. Al hacer login no se navega
  a mano. Las rutas se arman con `Rutas.usuario(id)` / `Rutas.pokemon(id, n)`.
- **Modelos:** los `fromJson` usan los lectores de `data/json.dart` (`json.integer('x')`,
  `json.utcDateOrNull('fecha')`, `json.objectList('items')`…), que nunca lanzan.
- **Pruebas:** `TrackerApp` recibe sus dependencias, así que las pruebas de widgets usan
  `MockClient` (`package:http/testing.dart`) y `MemorySessionStore`. `test/helpers.dart`
  tiene `fakeJwt` / `tokenPrueba`.

## Notas de Dart/Flutter

- **Importar `package:material_ui/material_ui.dart`, no `package:flutter/material.dart`.**
  En Flutter 3.47 Material vive en el paquete `material_ui`, y `go_router` reconoce la app
  por el `MaterialApp` de ese paquete; mezclar ambos rompe las páginas de Material.
- El código usa *dot shorthands* (`.all(16)`, `mainAxisAlignment: .center`), válidos desde
  Dart 3.10, y parámetros nombrados privados (`required this._store`). No "corregirlos".
- `http.Response('texto')` en las pruebas codifica en Latin-1; usar
  `http.Response.bytes(utf8.encode(...), status)` para texto con acentos.

## Diseño de interfaz

Para trabajo de UI usar el skill `impeccable` (`.claude/skills/impeccable/`, con sus agentes
revisores en `.claude/agents/`) y `better-ui` para el pulido de superficies e íconos.

- Definir una dirección visual concreta antes de implementar.
- Evitar la estética genérica de IA: degradados morados, tarjetas con brillo, esquinas
  demasiado redondeadas, *hero* genérico y cuadrículas de tarjetas repetidas.
- Dar carácter con tipografía, espacio en blanco, composición y jerarquía.
- Paleta sobria y con propósito. Colores, tipografía y espaciado viven como tokens en un solo
  lugar (`core/theme/`: `ThemeData` + un `ThemeExtension` propio); los widgets no usan
  colores ni medidas sueltos.
- Interacciones cuidadas en vez de animaciones innecesarias.
- Usar las referencias de diseño que se den, sin copiarlas a ciegas.
- Revisar el resultado renderizado en escritorio y móvil: `flutter run -d chrome` y cambiar el
  tamaño de la ventana o usar el modo dispositivo de DevTools (F12). Corregir inconsistencias.
- Prioridad: calidad visual, usabilidad, accesibilidad y comportamiento responsivo.
