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
- **Fase 1 (mundo visual) en cierre:** tokens, tema, marco de la app, login y perfil →
  pestaña Resumen con datos reales.
- **Fase 2 (pantallas) en curso**, en la rama `fase-2-pantallas`: ranking listo, con búsqueda,
  orden y página en la URL (`/?orden=winrate&q=ash`) y carga por páginas.
- Pendientes (marcadores `EnConstruccion`/`NotaVacia`): detalle de Pokémon y las pestañas
  Equipo, Batallas, Mochila, Pokédex, Tamagotchi e Intercambios.
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

# Capturas de regresión visual (test/capturas/goldens). Solo corren con CAPTURAS
# porque el renderizado de fuentes cambia entre sistemas operativos.
CAPTURAS=1 flutter test test/capturas --update-goldens   # generar
CAPTURAS=1 flutter test test/capturas                    # comparar
```

Las capturas usan las respuestas reales guardadas en `test/fixtures/` (cuenta de prueba
`ash`), un perfil sintético "demo" y los sprites de `test/fixtures/sprites/`. Son la forma de
ver el resultado sin navegador, porque la app necesita sesión y CORS.

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
`PRODUCT.md` guarda el contexto del producto, y el contrato de dirección del mundo visual
está en `.impeccable/surfaces/`.

**Mundo visual: "especimen bitmap".** Papel, tinta y un solo rojo de pokébola; reglas negras
de 2 px y esquinas rectas; franjas negras (`FranjaTitulo`) como encabezados; borde de
pixeles y cuadro rojo (`NotaVacia`) para vacíos y errores.

- **Tokens en `core/theme/tokens.dart`:** `Paleta`, `Espacio` (módulo de 8 px) y `Tipos`.
  Los widgets no usan colores ni medidas sueltos.
- **Silkscreen** (bitmap) solo para cifras grandes y etiquetas cortas en mayúsculas, y siempre
  con `Tipos.bitmap(n)` donde `n` es múltiplo de 8 (si no, el pixel no cae entero; hay un
  `assert`). Deja 1/8 de em de margen izquierdo: compensarlo en cifras grandes. **Archivo**
  para todo el texto de interfaz. Ambas fuentes van como assets (`assets/fonts/`).
- **Colores en cuarentena:** los de tipo y salud (`pokemon_colores.dart`) solo dentro de la
  lámina de un Pokémon, nunca en el marco. Todos tienen al menos 4.5:1 con texto blanco.
- **Sprites con `PixelSprite`:** escala entera (96 px × n) y `FilterQuality.none`, nunca
  suavizados.
- Las barras van a escala exacta del dato y los números usan cifras tabulares.
- Un solo momento de movimiento por pantalla, que respete `MediaQuery.disableAnimationsOf`.

Reglas generales:

- Definir una dirección visual concreta antes de implementar.
- Evitar la estética genérica de IA: degradados morados, tarjetas con brillo, esquinas
  demasiado redondeadas, *hero* genérico y cuadrículas de tarjetas repetidas.
- Dar carácter con tipografía, espacio en blanco, composición y jerarquía.
- Interacciones cuidadas en vez de animaciones innecesarias.
- Usar las referencias de diseño que se den, sin copiarlas a ciegas.
- Revisar el resultado renderizado en escritorio y móvil: `flutter run -d chrome` y cambiar el
  tamaño de la ventana o usar el modo dispositivo de DevTools (F12). Corregir inconsistencias.
- Prioridad: calidad visual, usabilidad, accesibilidad y comportamiento responsivo.
