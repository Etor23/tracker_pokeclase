# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Especificación del proyecto

Las reglas del proyecto, rutas, endpoints a usar y reglas de presentación están en
`docs/CLAUDE.md` (importado abajo). La guía completa del backend, con todos los endpoints
y ejemplos de respuesta, está en `docs/endpoints.md`: consultarla por sección (`## Tracker`,
`## Usuarios`, `### Datos de otro jugador`, `## Errores comunes`) en vez de leerla entera.

@docs/CLAUDE.md

## Estado actual (actualizar o borrar al empezar la implementación)

- `lib/main.dart` y `test/widget_test.dart` todavía son la plantilla del contador de
  `flutter create`. Nada de la especificación está implementado.
- Aún no se agregan dependencias (`go_router`, cliente HTTP, etc.) a `pubspec.yaml`.
- Solo existe la plataforma **web** (`web/`); no hay `android/` ni `ios/`.
- No es un repositorio git.

## Comandos

Toolchain: Flutter 3.47.0 (stable), Dart SDK `^3.13.0`.

```bash
flutter pub get                                   # instalar dependencias
flutter run -d chrome --web-browser-flag "--disable-web-security"   # mientras el backend no tenga CORS
flutter run -d chrome --dart-define=API_URL=https://backpokemon.runasp.net
flutter analyze                                   # lints (flutter_lints, ver analysis_options.yaml)
flutter test                                      # todas las pruebas
flutter test test/widget_test.dart                # un archivo
flutter test --plain-name "Counter increments smoke test"   # una prueba por nombre
flutter build web
```

## Notas de Dart/Flutter

- El código usa *dot shorthands* (`.fromSeed(...)`, `mainAxisAlignment: .center`), válidos
  desde Dart 3.10. No "corregirlos".

## Diseño de interfaz

Para trabajo de UI usar el skill `impeccable` (`.claude/skills/impeccable/`, con sus agentes
revisores en `.claude/agents/`) y `better-ui` para el pulido de superficies e íconos.

- Definir una dirección visual concreta antes de implementar.
- Evitar la estética genérica de IA: degradados morados, tarjetas con brillo, esquinas
  demasiado redondeadas, *hero* genérico y cuadrículas de tarjetas repetidas.
- Dar carácter con tipografía, espacio en blanco, composición y jerarquía.
- Paleta sobria y con propósito. Colores, tipografía y espaciado viven como tokens en un solo
  lugar (`ThemeData` + un `ThemeExtension` propio); los widgets no usan colores ni medidas
  sueltos.
- Interacciones cuidadas en vez de animaciones innecesarias.
- Usar las referencias de diseño que se den, sin copiarlas a ciegas.
- Revisar el resultado renderizado en escritorio y móvil: `flutter run -d chrome` y cambiar el
  tamaño de la ventana o usar el modo dispositivo de DevTools (F12). Corregir inconsistencias.
- Prioridad: calidad visual, usabilidad, accesibilidad y comportamiento responsivo.
