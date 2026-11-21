# Tracker Pokémon – Flutter web

Página web en Flutter que muestra estadísticas de los jugadores de la app de Pokémon
que el equipo desarrolla en clase: ranking, perfil de cada jugador, su equipo, batallas,
mochila y Pokédex. El backend (ASP.NET Core) lo hace otra parte del equipo; este
repositorio es solo el frontend.

## Reglas del proyecto

- **Solo lectura.** El tracker nunca modifica datos del juego. El único POST permitido es
  el login. No llamar a ningún POST, PUT, PATCH ni DELETE del backend.
- **Cada jugador inicia sesión con su propia cuenta.** No hay cuenta compartida ni
  credenciales en el código: todo lo que se compila a web es legible desde el navegador.
- **Nunca mostrar email ni otros datos de Identity**, aunque algún endpoint los devolviera.
  Los usuarios se muestran solo con `id` y `userName`.
- **Generación 1 (151 especies).** El total real lo da el backend en `pokedex.total`;
  no lo escribas fijo en el código.
- **Sin tiempo real.** Los datos se recargan al abrir cada pantalla y con un botón de refrescar.

## Backend

- URL base: `https://backpokemon.runasp.net` (definirla en un solo lugar, por ejemplo
  con `--dart-define=API_URL=...`).
- Todo requiere `Authorization: Bearer <token>`, salvo login y los catálogos públicos.
- La guía completa de endpoints del backend está en `docs/` (agregar ahí el .md del equipo).

### CORS (estado al 2026-11-21)

El backend **todavía no tiene CORS configurado**: la petición OPTIONS responde 405 sin
cabeceras `Access-Control-*`, así que Chrome bloquea todas las llamadas desde Flutter web,
incluido `localhost`. El equipo de backend va a agregar `AllowAnyOrigin()`.

Mientras no esté publicado, desarrollar con:

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

En Flutter web un fallo de CORS aparece como `ClientException: XMLHttpRequest error`
(o `DioException [connection error]`). El error real solo se ve en la consola de Chrome (F12).
Un 500 del backend también puede verse como error de CORS: revisar el status en la
pestaña Network antes de culpar a CORS.

Para comprobar si ya quedó:

```bash
curl.exe -i -X OPTIONS "https://backpokemon.runasp.net/api/tracker/usuarios" -H "Origin: http://localhost:5000" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: authorization"
```

Debe responder 204 con `Access-Control-Allow-Origin: *`.

## Pantallas y rutas (go_router)

Usar `go_router` para que cada perfil tenga una URL que se pueda compartir.

| Ruta | Pantalla |
|---|---|
| `/login` | Login |
| `/` | Ranking + buscador de jugadores |
| `/usuario/:id` | Perfil: pestañas Resumen, Equipo, Batallas, Mochila, Pokédex |
| `/usuario/:id/pokemon/:pokemonUserId` | Detalle de un Pokémon |
| `/yo` | Mi perfil: igual que el perfil + pestañas Tamagotchi e Intercambios |

Si no hay token o el token expiró, redirigir a `/login` y volver después a la ruta pedida.
Sin ruta pedida (abrir la app o hacer login directo), se entra a `/yo`: el progreso
personal es lo primero (decisión del 2026-11-21).

## Endpoints que usa el tracker

Las rutas por `userId` funcionan para **cualquier** jugador con cualquier token válido.
El `userId` es un string (GUID), no un número.

### Sesión y búsqueda

| Endpoint | Devuelve | Uso |
|---|---|---|
| `POST /api/Auth/login` body `{ userName, password }` | `{ token, expiration }` | Token válido 24 h. Guardarlo en `sessionStorage` (sobrevive a F5, se borra al cerrar la pestaña; nunca `localStorage`); ante un 401 o al pasar `expiration`, volver a `/login`. Credenciales incorrectas → 401 `{ message }`. |
| `GET /api/tracker/usuarios` | Página `{ total, pagina, tamano, items[] }`; cada item `{ posicion, id, userName, victorias, derrotas, winRate, totalPokemon, especiesRegistradas }` | Ranking. Query opcionales: `orden` (`winrate`, `victorias`, `pokedex`, `pokemon`, `nombre`; por defecto `nombre`), `pagina`, `tamano` (1–100), `search`, `minBatallas` (por defecto 5). **Incluye** al usuario actual. Un `orden` inválido da 400. |
| `GET /api/Users?search=` | `[{ id, userName }]` | Alternativa de búsqueda: mínimo 2 caracteres, máximo 50 resultados, **excluye** al usuario actual. Preferir `tracker/usuarios?search=`. |

El id propio sale del JWT: claim `sub`, `nameid` o
`http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier`.

### Perfil de un jugador

Al abrir un perfil, pedir el resumen y luego cada pestaña al abrirla (no todo de golpe).

| Endpoint | Devuelve | Pestaña |
|---|---|---|
| `GET /api/tracker/usuarios/{userId}/resumen` | `{ id, userName, pokemon: { total, sanos, afectados, debilitados, enCrianza, crianzaMuertos }, pokedex: { registrados, total }, batallas: { victorias, derrotas, huidas, winRate }, objetos: { total, distintos }, intercambiosConfirmados }` | Resumen. 404 si el usuario no existe. |
| `GET /api/PokemonUsers/usuario/{userId}` | Arreglo de Pokémon: `id`, `idPokemon` (especie), `nombre`, `fechaObtencion` (puede ser null), `origen` (`Desconocido`, `Inicial`, `Captura`, `Intercambio`), `pokemonEstado` { `vidaActual`, `vidaTotal`, `estado` (número), `estadoNombre`, `ataqueBase`, `defensaBase`, `velocidadBase`, `tipoPrimario`, `tipoSecundario`, `urlFrontal`, `urlTrasera` } y `crianza` (null o { `hambre`, `energia`, `higiene`, `vivo`, `fechaAdopcion`, `fechaMuerte` }) | Equipo y detalle del Pokémon |
| `GET /api/Batallas/usuario/{userId}?pagina=1&tamano=20` | Página `{ total, pagina, tamano, items[] }`; cada item `{ id, fecha, resultado, idPokemonRival, pokemon: { id, idPokemon, nombre, urlFrontal } }` | Batallas, de la más reciente a la más antigua. Filtro opcional `resultado` (`Victoria`, `Derrota`, `Huida`). Usar scroll infinito o "cargar más". |
| `GET /api/Batallas/usuario/{userId}/resumen` | `{ total, victorias, derrotas, huidas, winRate, rachaActual, mejorPokemon, rivalMasEnfrentado }` | Encabezado de la pestaña Batallas. Los tres últimos pueden ser null. |
| `GET /api/Inventario/usuario/{userId}` | Arreglo de objetos con `cantidad` y los datos del objeto | Mochila |
| `GET /api/Pokedex/usuario/{userId}` | `{ registrados, total, especies: [{ idPokemon, fecha }] }` | Pokédex. Solo trae las especies registradas. |

### Solo en "Mi perfil" (`/yo`)

| Endpoint | Uso |
|---|---|
| `GET /api/me/pokemon` | Agrega `available` y `reserved` a cada Pokémon (si está reservado en un intercambio) |
| `GET /api/tamagotchi` | Pestaña Tamagotchi: `hambre`, `energia`, `higiene`, `vidaActual`, `vidaTotal`, `estado`, `vivo`, `fechaAdopcion` |
| `GET /api/me/trades` | Pestaña Intercambios; separar por `role` (`sent` / `received`). Filtro opcional `status`. |

**No usar `GET /api/Inventario` ni `GET /api/me/inventory`:** consultar el inventario propio
le acredita pokébolas al jugador (efecto secundario del backend). Para la mochila propia
usar `GET /api/Inventario/usuario/{miId}`.

### Catálogos públicos (pedir una vez y cachear)

| Endpoint | Uso |
|---|---|
| `GET /api/Estados` | Tabla id → nombre de estado (1 Sano … 7 Congelado) |
| `GET /api/generation/1` | `pokemon_species[]` con `name` y `url`; el id de la especie es el último número de la `url`. Fuente de nombres para la Pokédex y los rivales. |

### No usar

- `GET /api/pokemon/{id}` por cada Pokémon o rival: son decenas de llamadas por perfil.
- El CRUD antiguo `/api/Intercambios`.
- Cualquier ruta de escritura o de GameAdmin.

### Verificado contra el servidor real (2026-11-21, cuenta de prueba `ash`)

Esto manda sobre las tablas de arriba cuando no coinciden.

- **Login:** el JWT trae el id en el claim largo `.../claims/nameidentifier` y el nombre en
  `.../claims/name`. `expiration` viene con `Z`.
- **Ranking:** `minBatallas` debe ser ≥ 1, y `pagina` o `tamano` fuera de rango dan 400 con
  texto plano. `minBatallas` **no saca jugadores de la lista**: con el valor por defecto
  aparecen todos (7 jugadores, todos con 0 victorias y 0 derrotas y `winRate: null`).
- **`GET /api/Batallas/usuario/{id}/resumen` responde 500 con cuerpo vacío para todos los
  jugadores**, incluso para uno con batallas. Bug del backend: el encabezado de Batallas usa
  `batallas` de `tracker/usuarios/{id}/resumen` (victorias, derrotas, huidas, winRate) y
  trata `rachaActual`, `mejorPokemon` y `rivalMasEnfrentado` como opcionales.
- **Resumen:** 404 en formato ProblemDetails (`title: "Not Found"`).
- **Pokémon del jugador:** coincide con la guía y trae campos extra (`idUsuario`,
  `pokemonEstado.idPokemonUser`, `pokemonEstado.idPokeball`). `fechaObtencion` llega
  **sin `Z`**. `nombre` llega con mayúsculas inconsistentes (`marill`, `Pikachu`):
  capitalizar al mostrar.
- **Especies fuera de la Gen 1:** `ash` tiene un Marill (#183), y la Pokédex lo cuenta en
  `registrados` aunque `total` sea 151. La cuadrícula muestra 1..`total`; las especies con id
  mayor a `total` van aparte (por ejemplo, "Otras especies"), sin romper el conteo.
- **Batallas:** `pokemon` es el Pokémon **del jugador**; el rival solo viene como
  `idPokemonRival`. `fecha` llega sin `Z`.
- **Mochila:** cada elemento es `{ id, idItem, idUser, cantidad, item: { id, nombre,
  urlImagen, descripcion, tipoJuego, multiplicadorCaptura, … } }`, con los datos del objeto
  anidados en `item`. `nombre` viene en inglés con guiones (`poke-ball`): mostrarlo como
  "Poke Ball". La descripción está en inglés.
- **`GET /api/me/pokemon`** tiene **otra forma** que `PokemonUsers`: es plano (`vidaActual`,
  `vidaTotal`), `estado` es **texto** (`"Sano"`), no número, y no trae `pokemonEstado` ni
  sprites. Usarlo solo para `available`/`reserved`, cruzando por `id`.
- **`GET /api/tamagotchi` devuelve un arreglo** (vacío para `ash`), no un objeto. Su forma
  interna sigue sin verificarse.
- **`GET /api/me/trades`:** `[]` para `ash`; su forma interna sigue sin verificarse.
- **Mensajes de error:** los 400 llegan en texto plano en español; los 404, en ProblemDetails.

## Reglas de presentación

- **Sprites por id:** `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{idPokemon}.png`.
  Sirven para rivales y para la cuadrícula de la Pokédex. Para el equipo, preferir `urlFrontal`.
- **Pokédex:** cuadrícula de `total` casillas. Registrada → sprite a color y fecha;
  no registrada → silueta gris con `ColorFiltered`.
- **winRate** = victorias / (victorias + derrotas); las huidas no cuentan. Lo calcula el
  backend. Si viene `null`, mostrar "—", nunca 0 %.
- **Estado de salud:** `vidaActual == 0` → Debilitado; `estadoNombre != "Sano"` → afectado.
- **Crianza muerta** (`crianza.vivo == false`): mostrar el Pokémon atenuado con un indicador.
- **Origen `Desconocido`** son Pokémon anteriores a la migración: no mostrar la etiqueta.
- **Fechas:** el backend las genera en UTC, pero a veces llegan sin `Z`. Parsearlas
  siempre como UTC y convertirlas a hora local al mostrarlas.
- Mostrar el error del backend al usuario solo como un mensaje genérico con opción de reintentar.

## Cliente HTTP

- Un solo cliente que agregue el token, maneje 401 (ir a login) y lance errores tipados.
- **No asumir que los errores son JSON:** algunos son texto plano, otros JSON de
  validación y otros vienen vacíos. Leer el cuerpo como texto y parsear solo si se puede.
- Modelos tolerantes: campos nuevos o faltantes no deben tronar la app
  (`fromJson` con valores por defecto y nullables).
- Las formas de respuesta ya se verificaron contra el servidor real (ver "Verificado contra
  el servidor real"), salvo Tamagotchi e Intercambios. Si algo más no coincide, ajustar el
  modelo y anotar la diferencia en esa sección.

## Pendientes del equipo de backend

- Configurar CORS con `AllowAnyOrigin()` (ver arriba).
- Confirmar que `GET /api/Inventario/usuario/{userId}` no acredita pokébolas. Prueba del
  2026-11-21: con una llamada, el total de objetos de `ash` siguió en 14 (sin cambio).
- Corregir el 500 de `GET /api/Batallas/usuario/{userId}/resumen` (falla con todos los
  jugadores).
