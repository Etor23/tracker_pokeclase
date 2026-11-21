# Guía de endpoints – BackPokemon (MonsterASP)

## Preparación

Todas las peticiones de esta guía se muestran como se llenan en **Thunder Client** (la extensión de VS Code); en Postman es lo mismo. El servidor es `https://backpokemon.runasp.net` y casi todo exige un token (🔒), que se obtiene con el login.

### Preparación única: variables

Crea un entorno con dos variables y actívalo:

| Variable | Valor |
| --- | --- |
| `baseUrl` | `https://backpokemon.runasp.net` |
| `token` | vacía; la llena el login |

- **Thunder Client:** pestaña *Env* → *New Environment* → agrega las dos variables → márcalo como activo.
- **Postman:** *Environments* → *New* → agrega las dos variables → selecciónalo arriba a la derecha.

### Cómo leer las tarjetas de esta guía

Cada petición aparece así, y cada línea es un campo de Thunder Client:

```text
Método   POST
URL      {{baseUrl}}/api/capturas
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Query    nombre = valor
Body     JSON (el cuadro de código de abajo)
```

| Línea | Dónde se llena |
| --- | --- |
| Método y URL | La barra superior: elige el método y pega la URL |
| Auth | Pestaña *Auth* → *Bearer* → campo *Token*: `{{token}}` (en Postman: *Authorization* → *Bearer Token*) |
| Headers | Pestaña *Headers*: el nombre a la izquierda y el valor a la derecha |
| Query | Pestaña *Query* (*Params* en Postman): una fila por parámetro |
| Body | Pestaña *Body* → *JSON* (en Postman: *Body* → *raw* → *JSON*); pega el cuadro de código |

Reglas rápidas:

- Si la tarjeta no tiene línea Auth, la ruta es pública.
- Los GET sin parámetros solo llevan método, URL y Auth.
- Los textos entre `< >`, como `<ID_USUARIO>`, se reemplazan por el valor real.
- Si usas la pestaña Auth, no agregues a mano la cabecera `Authorization`: se duplicaría ("Bearer Bearer ...") y el servidor respondería 401.
- Al elegir el cuerpo JSON, `Content-Type` se agrega solo en ambas herramientas; si una petición falla por eso, añádela a mano.

### 1. Registrar un usuario (público)

```text
Método   POST
URL      {{baseUrl}}/api/Auth/register
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "userName": "ash",
  "email": "ash@correo.com",
  "password": "Pikachu123!"
}
```

La contraseña debe tener mayúscula, minúscula, número y símbolo (mínimo 6 caracteres). Responde `Usuario registrado correctamente`; da 400 si el usuario ya existe o la contraseña no cumple.

### 2. Iniciar sesión y guardar el token (público)

```text
Método   POST
URL      {{baseUrl}}/api/Auth/login
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "userName": "ash",
  "password": "Pikachu123!"
}
```

Para que el token se guarde solo en la variable `token`:

- **Thunder Client:** pestaña *Vars* → *Set Env Variable* → nombre `token`, valor `json.token`.
- **Postman:** pestaña *Tests* → pega esta línea.

```javascript
pm.environment.set("token", pm.response.json().token);
```

La respuesta trae `token` y `expiration`. El token dura 24 horas; después hay que repetir el login. Si prefieres hacerlo a mano, copia el `token` de la respuesta y pégalo en la variable.

### 3. Primera petición protegida

```text
Método   GET
URL      {{baseUrl}}/api/Batallas
Auth     Bearer {{token}}
```

Devuelve una lista (vacía al principio). Si responde 401, revisa que `{{token}}` tenga valor (haz login otra vez), que el entorno esté activo y que no haya cabeceras `Authorization` duplicadas.

### Dos jugadores a la vez

Los intercambios necesitan dos usuarios. Crea un segundo entorno (o una variable `token2`) con el login del otro jugador y usa `{{token2}}` en las peticiones que le tocan a él.

**Códigos de respuesta comunes**

| Código | Significado |
| --- | --- |
| 200 / 201 / 204 | Correcto (204 = sin contenido) |
| 400 | Datos inválidos; el texto indica cuál |
| 401 | Falta el token, es inválido o expiró |
| 403 | Estás autenticado pero no tienes el rol o el recurso es de otro usuario |
| 404 | No existe, o no es tuyo |
| 409 | Conflicto de estado (ya existe, expiró, sin stock, etc.) |

**Notación en esta guía:** `{id}` en una ruta se reemplaza por el número o texto real. 🔒 = requiere token; 🔒 GameAdmin = además requiere ese rol (solo para el administrador del juego).

## Batallas

Base: `/api/Batallas`. Todas requieren token (🔒). `resultado` acepta `Victoria`, `Derrota` o `Huida` (o 1, 2, 3). Un jugador solo ve y modifica sus propias batallas.

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/Batallas` | Mis batallas, de la más reciente a la más antigua |
| GET | `/api/Batallas/{id}` | Detalle de una batalla mía (404 si no es tuya) |
| GET | `/api/Batallas/usuario/{userId}` | Historial paginado de cualquier usuario |
| GET | `/api/Batallas/usuario/{userId}/resumen` | Estadísticas de un usuario |
| POST | `/api/Batallas` | Registrar el resultado de una batalla |
| PUT | `/api/Batallas/{id}` | Corregir una batalla mía |
| DELETE | `/api/Batallas/{id}` | Borrar una batalla mía |
| POST | `/api/Batallas/recompensa` | 🔒 GameAdmin: batalla con premio de objeto |

**Historial de un usuario**

```text
Método   GET
URL      {{baseUrl}}/api/Batallas/usuario/<ID_USUARIO>
Auth     Bearer {{token}}
Query    resultado = Victoria   (opcional)
         pagina = 1             (opcional)
         tamano = 20            (opcional)
```

Parámetros opcionales: `resultado` (Victoria, Derrota, Huida), `pagina` (desde 1) y `tamano` (1 a 100). Devuelve `total`, `pagina`, `tamano` e `items`, cada uno con el Pokémon retador y su imagen frontal. El `<ID_USUARIO>` es el campo `id` del usuario (ver la sección Usuarios).

**Resumen**

```text
Método   GET
URL      {{baseUrl}}/api/Batallas/usuario/<ID_USUARIO>/resumen
Auth     Bearer {{token}}
```

Devuelve `total`, `victorias`, `derrotas`, `huidas`, `winRate` (victorias entre victorias más derrotas; `null` si no hay decisiones), `rachaActual`, `mejorPokemon` y `rivalMasEnfrentado`. Da 404 si el usuario no existe.

**Registrar una batalla (jugador normal)**

```text
Método   POST
URL      {{baseUrl}}/api/Batallas
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "pokemonUserR": 1,
  "idPokemonRival": 25,
  "resultado": "Victoria",
  "llaveIdempotencia": "3f2a9c1e-5b7d-4e8a-9c21-7d4e5f6a8b90"
}
```

- `pokemonUserR`: el `id` de tu Pokémon en tu colección (no el número de la Pokédex). Debe ser tuyo, si no da 403.
- `idPokemonRival`: número de especie del rival, de 1 a 151 (`Game:TotalSpecies`).
- `llaveIdempotencia`: GUID opcional. Si repites la misma llave, no se duplica y te devuelve la batalla ya guardada.
- Respuesta 201 con la batalla. **No entrega premios** a los jugadores normales.

**Editar y borrar**

Editar:

```text
Método   PUT
URL      {{baseUrl}}/api/Batallas/5
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "pokemonUserR": 1,
  "idPokemonRival": 25,
  "resultado": "Derrota"
}
```

Borrar:

```text
Método   DELETE
URL      {{baseUrl}}/api/Batallas/5
Auth     Bearer {{token}}
```

Ambas responden 204. Si la batalla ya entregó una recompensa, dan 409 y no se puede editar ni borrar.

**Batalla con recompensa (solo GameAdmin)**

```text
Método   POST
URL      {{baseUrl}}/api/Batallas/recompensa
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "llaveIdempotencia": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "pokemonUserR": 1,
  "idPokemonRival": 25,
  "pokemonUserGanador": 1
}
```

Si `pokemonUserGanador` es igual a `pokemonUserR`, cuenta como victoria; si no, derrota. Entrega un objeto aleatorio. Antes hay que sincronizar el catálogo de objetos (ver Usuarios → Items), si no responde 409. El formato antiguo de `POST /api/Batallas` (con `pokemonUserGanador` y sin `resultado`) también solo lo acepta GameAdmin.

## Capturas

El flujo de captura usa tres grupos de rutas: encuentros (los Pokémon salvajes), objetos del campo y capturas. Todas requieren token (🔒), salvo las marcadas con GameAdmin.

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/encuentros/cercanos` | Pokémon salvajes cerca de unas coordenadas |
| POST | `/api/capturas` | Lanzar una Poké Ball a un encuentro |
| POST | `/api/encuentros/{id}/bayas` | Dar una baya al Pokémon para facilitar la captura |
| GET | `/api/me/capturas` | Mi historial de capturas |
| GET | `/api/me/capturas/{id}` | Detalle de una captura mía |
| GET | `/api/objetos-campo/cercanos` | Objetos tirados en el mapa cerca de ti |
| POST | `/api/objetos-campo/{id}/recoger` | Recoger un objeto del mapa |
| POST | `/api/encuentros` | 🔒 GameAdmin: crear un encuentro manual |
| PUT | `/api/encuentros/{id}/estado` | 🔒 GameAdmin: cambiar el estado de un encuentro |
| POST | `/api/objetos-campo` | 🔒 GameAdmin: colocar un objeto en el mapa |

**1. Buscar encuentros cercanos**

```text
Método   GET
URL      {{baseUrl}}/api/encuentros/cercanos
Auth     Bearer {{token}}
Query    latitud = 19.4326
         longitud = -99.1332
         radioMetros = 1000   (opcional)
```

`latitud` (-90 a 90) y `longitud` (-180 a 180) son obligatorias; `radioMetros` es opcional (por defecto 1000, máximo 5000). Cada zona de aproximadamente 1 km genera un Pokémon compartido que dura 1 hora. Devuelve `id`, `pokemonId`, `pokemonNombre`, coordenadas, `fechaExpiracion`, `dormido`, `comiendo`, `jugadorDetectado` y `tiroPorLaEspaldaDisponible`. Esta llamada también recarga pokébolas si ya toca (cada 30 minutos). Si PokeAPI no responde, da 502.

**2. Ver tus pokébolas**

Necesitas el `idItem` del objeto Poké Ball, que sale de tu inventario (sección Usuarios → Inventario):

```text
Método   GET
URL      {{baseUrl}}/api/Inventario
Auth     Bearer {{token}}
```

**Las pokébolas no se entregan solas:** se acreditan en el momento en que consultas el inventario (o buscas encuentros cercanos). Cada 30 minutos te corresponde una tanda de 10 Poké Ball más 5 bolas extra al azar (Great Ball o Ultra Ball), con un tope de 100 de cada tipo. La primera consulta de un jugador nuevo entrega la primera tanda; si pasas horas sin conectarte, al volver recibes todas las tandas acumuladas hasta el tope.

**3. Lanzar la Poké Ball**

```text
Método   POST
URL      {{baseUrl}}/api/capturas
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "encuentroId": 1,
  "pokeballItemId": 3
}
```

La respuesta trae `captured` (true o false), `remainingPokeballs`, el detalle de la captura (`capture`, con probabilidades y multiplicadores), el `pokemon` capturado si hubo éxito y un `message`. Errores típicos: 404 si el encuentro no existe, 409 si expiró, si ya lo capturaste o si no te quedan de esa bola, y 400 si el objeto no es una Poké Ball.

**4. Dar una baya (opcional, antes de lanzar)**

```text
Método   POST
URL      {{baseUrl}}/api/encuentros/1/bayas
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "bayaItemId": 7
}
```

El Pokémon queda "comiendo" unos 30 segundos (`comiendoHasta`), lo que sube la probabilidad. Gasta una baya de tu inventario.

**5. Consultar capturas**

Lista:

```text
Método   GET
URL      {{baseUrl}}/api/me/capturas
Auth     Bearer {{token}}
Query    success = true   (opcional)
```

Detalle:

```text
Método   GET
URL      {{baseUrl}}/api/me/capturas/12
Auth     Bearer {{token}}
```

`success=true` o `false` filtra por capturas exitosas o fallidas.

**Objetos del campo**

Ver los cercanos:

```text
Método   GET
URL      {{baseUrl}}/api/objetos-campo/cercanos
Auth     Bearer {{token}}
Query    latitud = 19.4326
         longitud = -99.1332
         radioMetros = 500   (opcional)
```

Recoger uno:

```text
Método   POST
URL      {{baseUrl}}/api/objetos-campo/4/recoger
Auth     Bearer {{token}}
Query    latitud = 19.4326
         longitud = -99.1332
```

Para recoger, `latitud` y `longitud` van en la URL y debes estar a menos de 50 metros; si no da 400. Si otro jugador ya lo recogió o expiró, da 409.

**Endpoints de GameAdmin**

Crear un encuentro manual (dura 1 hora):

```text
Método   POST
URL      {{baseUrl}}/api/encuentros
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "pokemonId": 25,
  "latitud": 19.4326,
  "longitud": -99.1332,
  "dormido": true
}
```

Cambiar el estado de un encuentro para un usuario:

```text
Método   PUT
URL      {{baseUrl}}/api/encuentros/1/estado
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "dormido": false,
  "usuarioId": "<ID_USUARIO>",
  "jugadorDetectado": false,
  "tiroPorLaEspaldaDisponible": true,
  "calidadTiroDisponible": "excelente"
}
```

Colocar un objeto en el mapa:

```text
Método   POST
URL      {{baseUrl}}/api/objetos-campo
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "itemId": 3,
  "latitud": 19.4326,
  "longitud": -99.1332,
  "cantidad": 5,
  "duracionMinutos": 60
}
```

`calidadTiroDisponible` acepta `normal`, `bueno`, `excelente` o `perfecto`. `PUT .../estado` responde 204. El objeto del campo debe ser una Poké Ball o una baya, y el catálogo de objetos debe estar sincronizado.

### Flujo de prueba completo: de cero a tu primera captura

Es la secuencia con la que se comprobó que todo funciona en el servidor. Se hace con un jugador normal; solo el paso 0 necesita un administrador.

**0. Sincronizar el catálogo (una sola vez, GameAdmin)**

```text
Método   POST
URL      {{baseUrl}}/api/Items/sync/capture-items
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
```

Responde `added`, `updated` y `total`. Tarda unos segundos porque consulta PokeAPI. Sin este paso el inventario sale vacío y no se puede capturar. Si da 502, PokeAPI no respondió: repite la petición.

**1. Registrar y entrar como jugador**

Usa los pasos 1 y 2 de Preparación (registro y login) y deja el token en `{{token}}`.

**2. Consultar el inventario: aquí te dan las pokébolas**

```text
Método   GET
URL      {{baseUrl}}/api/Inventario
Auth     Bearer {{token}}
```

El jugador nuevo empieza sin nada; esta consulta le acredita la primera tanda (10 Poké Ball y 5 bolas extra). Después llegan otras cada 30 minutos, siempre que consultes el inventario o busques encuentros. Anota el `idItem` de `poke-ball`: es tu `pokeballItemId`.

**3. Buscar un encuentro**

```text
Método   GET
URL      {{baseUrl}}/api/encuentros/cercanos
Auth     Bearer {{token}}
Query    latitud = 19.4326
         longitud = -99.1332
```

Anota el `id` del encuentro (por ejemplo, un Marill). Dura 1 hora; si expira (409 al lanzar), vuelve a consultar.

**4. Lanzar la pokébola**

```text
Método   POST
URL      {{baseUrl}}/api/capturas
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "encuentroId": 1,
  "pokeballItemId": <idItem de poke-ball>
}
```

Si todo sale bien responde `captured: true`, `remainingPokeballs: 9` (de 10 te queda 9) y el `pokemon` capturado, con su `id`, vida completa y estado Sano. Si `captured` es false, repite el lanzamiento mientras te queden bolas: cada intento depende de la probabilidad.

**5. Comprobar que quedó en tu cuenta**

```text
Método   GET
URL      {{baseUrl}}/api/me/pokemon
Auth     Bearer {{token}}
```

```text
Método   GET
URL      {{baseUrl}}/api/Pokedex
Auth     Bearer {{token}}
```

El Pokémon debe aparecer en tu colección y su especie en la Pokédex. El `id` que sale en `/api/me/pokemon` es el que usan Tamagotchi, Batallas e Intercambios.

## Intercambios

Un intercambio tiene cuatro pasos: el creador ofrece un Pokémon, el destinatario acepta ofreciendo otro, el creador confirma y los dos Pokémon cambian de dueño. Todas las rutas requieren token (🔒) y solo las ven los dos participantes. Funcionan con el prefijo `/api/trades` o `/trades`; esta guía usa `/api/trades`.

| Método | Ruta | Quién la usa | Para qué sirve |
| --- | --- | --- | --- |
| POST | `/api/trades` | Creador | Invitar a otro jugador a intercambiar |
| POST | `/api/trades/{id}/accept` | Destinatario | Aceptar ofreciendo un Pokémon propio |
| POST | `/api/trades/{id}/confirm` | Creador | Confirmar y ejecutar el cambio |
| POST | `/api/trades/{id}/cancel` | Cualquiera de los dos | Cancelar (creador) o rechazar (destinatario) |
| GET | `/api/me/trades` | Ambos | Mis intercambios, con filtro opcional `?status=` |
| GET | `/api/trades/{id}` | Ambos | Detalle de un intercambio |

**1. Crear la invitación (el creador)**

```text
Método   POST
URL      {{baseUrl}}/api/trades
Auth     Bearer {{token}}   (el creador)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "recipientUserId": "<ID_DEL_OTRO_USUARIO>",
  "pokemonUserId": 1
}
```

`pokemonUserId` es el `id` de tu Pokémon en tu colección. El `id` del destinatario sale de `GET /api/Users?search=...` (sección Usuarios). Responde 201 con `status` = `pending`. Da 400 si te invitas a ti mismo, 404 si el destinatario no existe y 409 si el Pokémon no es tuyo, está muerto o ya está reservado en otro intercambio.

**2. Aceptar (el destinatario, con su propio token)**

```text
Método   POST
URL      {{baseUrl}}/api/trades/1/accept
Auth     Bearer {{token2}}   (el destinatario)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "pokemonUserId": 8
}
```

Aquí `pokemonUserId` es el Pokémon que el destinatario da a cambio. El estado pasa a `accepted`. Solo el destinatario puede aceptar (si no, 403) y solo si está `pending` (si no, 409).

**3. Confirmar (el creador)**

```text
Método   POST
URL      {{baseUrl}}/api/trades/1/confirm
Auth     Bearer {{token}}   (el creador)
```

Ejecuta el intercambio: los dos Pokémon cambian de dueño, su origen pasa a `Intercambio` y se agregan a la Pokédex de cada uno. El estado pasa a `confirmed`. Solo el creador puede confirmar y solo si está `accepted`.

**Cancelar o rechazar**

```text
Método   POST
URL      {{baseUrl}}/api/trades/1/cancel
Auth     Bearer {{token}}   (cualquiera de los dos)
```

Si el destinatario cancela un intercambio `pending`, queda como `rejected`; en los demás casos queda como `cancelled`. Solo se puede cancelar mientras esté `pending` o `accepted`.

**Consultar**

Todos mis intercambios (con filtro opcional):

```text
Método   GET
URL      {{baseUrl}}/api/me/trades
Auth     Bearer {{token}}
Query    status = pending   (opcional)
```

Detalle de uno:

```text
Método   GET
URL      {{baseUrl}}/api/trades/1
Auth     Bearer {{token}}
```

Valores de `status`: `pending`, `accepted`, `confirmed`, `cancelled`, `rejected`. Cada intercambio trae `role` (`sent` o `received` según quién lo pide), `creator`, `recipient`, `offeredPokemon`, `recipientPokemon` y las fechas `createdAt`, `acceptedAt`, `confirmedAt`.

Si dos peticiones chocan a la vez, responde 409 con "El intercambio cambió en otra solicitud"; basta con volver a consultar y repetir.

**Para probarlo necesitas dos usuarios.** Registra un segundo usuario, haz login con él y guarda su token en la variable `token2` (en Thunder Client, crea otra petición de login y en *Vars* pon `token2` en lugar de `token`).

## Tamagotchi

Base: `/api/tamagotchi`. Todas requieren token (🔒). Un Pokémon de tu colección puede "adoptarse" como mascota; tienes un máximo de 4 vivas a la vez. Hambre, energía e higiene bajan con el tiempo (100 puntos cada 24 horas) y, si llegan a cero, le quitan vida; si la vida llega a 0, la mascota muere.

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/tamagotchi` | Mis mascotas, con su estado actualizado |
| GET | `/api/tamagotchi/{id}` | Una mascota mía |
| POST | `/api/tamagotchi` | Adoptar un Pokémon como mascota |
| POST | `/api/tamagotchi/{id}/actividad` | Alimentar, dormir, bañar o curar |
| DELETE | `/api/tamagotchi/{id}` | Liberar la mascota |

**Listar y consultar**

Todas mis mascotas:

```text
Método   GET
URL      {{baseUrl}}/api/tamagotchi
Auth     Bearer {{token}}
```

Una sola:

```text
Método   GET
URL      {{baseUrl}}/api/tamagotchi/1
Auth     Bearer {{token}}
```

Cada mascota trae `id`, `idPokemonUser`, `idPokemon`, `hambre`, `energia`, `higiene`, `vidaActual`, `vidaTotal`, `estado` (Sano, Dormido…), `vivo` y `fechaAdopcion`. Al consultar, el servidor aplica primero el desgaste por el tiempo transcurrido.

**Adoptar**

```text
Método   POST
URL      {{baseUrl}}/api/tamagotchi
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "idPokemonUser": 1
}
```

`idPokemonUser` es el `id` de tu Pokémon en tu colección. Responde 201. Errores: 400 si ya tienes 4 vivas o el Pokémon no tiene estado, 404 si no existe o no es tuyo, 409 si ya es una mascota.

**Actividades**

```text
Método   POST
URL      {{baseUrl}}/api/tamagotchi/1/actividad
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "tipo": "comer"
}
```

| `tipo` | Efecto |
| --- | --- |
| `comer` | Hambre +25 (máximo 100); estado a Sano |
| `dormir` | Energía +30; estado a Dormido |
| `bañar` (también `banar`) | Higiene +30; estado a Sano |
| `curar` | Vida +20 sin pasar de la vida total; estado a Sano |

Cualquier otro valor da 400. Si la mascota ya murió, también da 400 y el mensaje lo explica.

**Liberar**

```text
Método   DELETE
URL      {{baseUrl}}/api/tamagotchi/1
Auth     Bearer {{token}}
```

Responde 204. Borra la crianza, pero el Pokémon sigue en tu colección.

## Tracker

Base: `/api/tracker`. Ambas rutas requieren token (🔒) y muestran datos públicos de juego de cualquier jugador: ranking y resumen.

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/tracker/usuarios` | Ranking de jugadores, paginado y ordenable |
| GET | `/api/tracker/usuarios/{userId}/resumen` | Perfil completo de un jugador |

**Ranking**

```text
Método   GET
URL      {{baseUrl}}/api/tracker/usuarios
Auth     Bearer {{token}}
Query    orden = winrate
         pagina = 1
         tamano = 20
         minBatallas = 5
         search = ash
```

Todos los parámetros de Query son opcionales.

| Parámetro | Valores | Por defecto |
| --- | --- | --- |
| `orden` | `winrate`, `victorias`, `pokedex`, `pokemon`, `nombre` | `nombre` |
| `pagina` | 1 o más | 1 |
| `tamano` | 1 a 100 | 20 |
| `search` | parte del nombre de usuario (máx. 100 caracteres) | sin filtro |
| `minBatallas` | mínimo de batallas decididas para entrar al ranking de `winrate` | 5 |

Responde `total`, `pagina`, `tamano` e `items`; cada ítem trae `posicion`, `id`, `userName`, `victorias`, `derrotas`, `winRate`, `totalPokemon` y `especiesRegistradas`. En el orden por `winrate`, quienes no llegan a `minBatallas` quedan al final. Un valor de `orden` inválido da 400.

Respuesta de ejemplo:

```json
{
  "total": 1,
  "pagina": 1,
  "tamano": 20,
  "items": [
    {
      "posicion": 1,
      "id": "id-del-usuario",
      "userName": "mario",
      "victorias": 8,
      "derrotas": 2,
      "winRate": 0.8,
      "totalPokemon": 4,
      "especiesRegistradas": 5
    }
  ]
}
```

Notas: `minBatallas` cuenta victorias más derrotas (las huidas no cuentan) y `search` sí incluye a tu propia cuenta, a diferencia de `GET /api/Users?search=`, que te excluye.

**Resumen de un jugador**

```text
Método   GET
URL      {{baseUrl}}/api/tracker/usuarios/<ID_USUARIO>/resumen
Auth     Bearer {{token}}
```

Devuelve el jugador (`id`, `userName`) con cuatro bloques: `pokemon` (total, sanos, afectados por un estado, debilitados, en crianza y mascotas muertas), `pokedex` (registrados y total de especies), `batallas` (victorias, derrotas, huidas, `winRate`) y `objetos` (cantidad total y distintos), más `intercambiosConfirmados`. Da 404 si el usuario no existe.

El `<ID_USUARIO>` sale del campo `id` del ranking o de `GET /api/Users?search=...`.

### Datos de otro jugador (los que alimentan el tracker)

Estas rutas ya existían y se ampliaron: cualquier usuario autenticado puede consultar los datos públicos de otro jugador con su `<ID_USUARIO>`. Para tu propia cuenta hay rutas `/api/me/...`; no hace falta duplicarlas.

| Dato | Mi cuenta | Otro jugador |
| --- | --- | --- |
| Pokémon | `GET /api/me/pokemon` | `GET /api/PokemonUsers/usuario/{userId}` |
| Mochila | `GET /api/me/inventory` | `GET /api/Inventario/usuario/{userId}` |
| Pokédex | `GET /api/me/pokedex` | `GET /api/Pokedex/usuario/{userId}` |
| Batallas | `GET /api/Batallas` | `GET /api/Batallas/usuario/{userId}` (y `/resumen`) |
| Intercambios | `GET /api/me/trades` (acepta `status`) | solo los propios |
| Buscar jugadores | `GET /api/Users?search=mar` | devuelve solo `id` y nombre |

**Pokémon de un usuario**

```text
Método   GET
URL      {{baseUrl}}/api/PokemonUsers/usuario/<ID_USUARIO>
Auth     Bearer {{token}}
```

Devuelve cada Pokémon con su estado (`estado` conserva el número y `estadoNombre` trae el texto), `crianza`, `fechaObtencion` y `origen`, que puede ser `Desconocido`, `Inicial`, `Captura` o `Intercambio`.

**Mochila de un usuario**

```text
Método   GET
URL      {{baseUrl}}/api/Inventario/usuario/<ID_USUARIO>
Auth     Bearer {{token}}
```

Devuelve los objetos y sus cantidades. Para la tuya sigue usando `GET /api/me/inventory`.

**Pokédex de un usuario**

```text
Método   GET
URL      {{baseUrl}}/api/Pokedex/usuario/<ID_USUARIO>
Auth     Bearer {{token}}
```

Respuesta de ejemplo:

```json
{
  "registrados": 2,
  "total": 151,
  "especies": [
    { "idPokemon": 1, "fecha": "2026-10-01T15:00:00Z" },
    { "idPokemon": 25, "fecha": "2026-10-03T18:20:00Z" }
  ]
}
```

`total` sale de `Game:TotalSpecies` en la configuración del servidor (por defecto 151).

El historial y el resumen de batallas de otro jugador están en la sección Batallas (`/api/Batallas/usuario/{userId}` y `/resumen`).

## Usuarios

Todo lo que gira alrededor de la cuenta del jugador: buscar usuarios, sus Pokémon, su Pokédex, su inventario y el catálogo de objetos. 🔒 = requiere token; sin candado = público.

### Cuenta y búsqueda

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| POST | `/api/Auth/register` | Crear cuenta (público) |
| POST | `/api/Auth/login` | Obtener el token (público) |
| GET | `/api/Users?search=` | 🔒 Buscar usuarios por nombre |
| POST | `/api/Auth/register-with-roles` | 🔒 GameAdmin: crear usuario con roles |

```text
Método   GET
URL      {{baseUrl}}/api/Users
Auth     Bearer {{token}}
Query    search = as
```

`search` debe tener de 2 a 100 caracteres. Devuelve hasta 50 usuarios (`id` y `userName`), sin incluirte a ti. Ese `id` es el que se usa como `<ID_USUARIO>` en el resto de la guía.

```text
Método   POST
URL      {{baseUrl}}/api/Auth/register-with-roles
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "userName": "admin2",
  "email": "admin2@correo.com",
  "password": "Admin123!",
  "roles": ["GameAdmin"]
}
```

Responde 201 con `id`, `userName` y `roles`. Los roles deben empezar con letra y tener hasta 32 caracteres (letras, números, `-` y `_`). Acepta de 1 a 32 roles y crea los que aún no existan. Da 409 si el usuario o el correo ya existen. Solo puede usarlo quien ya sea GameAdmin.

### Mis Pokémon (`/api/me`)

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/me/pokemon` | Mis Pokémon con vida, estado y crianza |
| POST | `/api/me/pokemon/heal` | Curar a todos mis Pokémon |
| PATCH | `/api/me/pokemon/{id}/heal` | Curar a uno |

Listar (con filtros opcionales):

```text
Método   GET
URL      {{baseUrl}}/api/me/pokemon
Auth     Bearer {{token}}
Query    health_lt = 50    (opcional)
         available = true  (opcional)
```

Curar a todos:

```text
Método   POST
URL      {{baseUrl}}/api/me/pokemon/heal
Auth     Bearer {{token}}
```

Curar a uno:

```text
Método   PATCH
URL      {{baseUrl}}/api/me/pokemon/1/heal
Auth     Bearer {{token}}
```

Filtros opcionales: `health_lt` (0 a 100, solo los de vida actual menor a ese valor) y `available` (`true` = libres para intercambiar; `false` = reservados). Cada Pokémon trae `available`, `reserved` y, si es mascota, los datos de `crianza`. Curar deja la vida al máximo y el estado en Sano, pero no revive mascotas muertas (409 en el curado individual).

### Colección de Pokémon (`/api/PokemonUsers`)

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/PokemonUsers` | 🔒 Mi colección |
| GET | `/api/PokemonUsers/{id}` | 🔒 Un Pokémon mío |
| GET | `/api/PokemonUsers/usuario/{userId}` | 🔒 Colección pública de otro jugador, con estado y crianza |
| POST | `/api/PokemonUsers` | 🔒 Agregar un Pokémon a mi colección |
| PUT | `/api/PokemonUsers/{id}` | 🔒 Cambiar el apodo |
| DELETE | `/api/PokemonUsers/{id}` | 🔒 Eliminar un Pokémon |

```text
Método   POST
URL      {{baseUrl}}/api/PokemonUsers
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "idPokemon": 25,
  "nombre": "Pikachu",
  "idUsuario": "<MI_ID_USUARIO>"
}
```

`idUsuario` debe ser tu propio id, o da 403. En `PUT` hay que reenviar el mismo `idPokemon` (la especie no se puede cambiar, da 409) más el nuevo `nombre`. `DELETE` da 409 si el Pokémon tiene historial de intercambios. También responde bajo `/api/PokemonUser` (en singular).

### Estado de un Pokémon (`/api/PokemonEstado`)

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| POST | `/api/PokemonEstado` | 🔒 Crear el estado (vida, stats, tipos) de un Pokémon |
| PUT | `/api/PokemonEstado/{idPokemonUser}` | 🔒 Actualizar vida y estado |

```text
Método   PUT
URL      {{baseUrl}}/api/PokemonEstado/1
Auth     Bearer {{token}}
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "vidaActual": 35,
  "estado": 3
}
```

`estado` se envía como número: 1 Sano, 2 Dormido, 3 Quemado, 4 Envenenado, 5 Paralizado, 6 Confundido, 7 Congelado (la lista también sale en `GET /api/Estados`). `vidaActual` debe estar entre 0 y la vida total. El POST pide `idPokemonUser`, `vidaTotal`, `vidaActual`, `estado`, `idPokeball`, `ataqueBase`, `defensaBase`, `velocidadBase`, `tipoPrimario`, `tipoSecundario` (opcional), `urlFrontal` y `urlTrasera`; da 409 si ese Pokémon ya tiene estado.

### Pokédex

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/Pokedex` o `/api/me/pokedex` | 🔒 Mi Pokédex |
| GET | `/api/Pokedex/{id}` | 🔒 Una entrada mía |
| GET | `/api/Pokedex/usuario/{userId}` | 🔒 Pokédex de otro jugador |

La Pokédex de otro jugador devuelve `registrados`, `total` (151) y la lista de `especies` con su fecha. Las entradas se crean solas al capturar o intercambiar; no hay endpoint para agregarlas a mano.

### Inventario

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/Inventario` o `/api/me/inventory` | 🔒 Mi inventario (también recarga pokébolas si toca) |
| GET | `/api/Inventario/{id}` | 🔒 Una entrada mía |
| GET | `/api/Inventario/usuario/{userId}` | 🔒 Inventario de otro jugador |

Cada entrada trae `cantidad` y el objeto con `tipoJuego` (`ball` o `berry`), `multiplicadorCaptura` y `duracionSegundos`. El `idItem` de las Poké Balls y bayas es el que se usa en Capturas. También responde bajo `/api/ItemUser`.

### Catálogo de objetos (`/api/Items`)

| Método | Ruta | Para qué sirve |
| --- | --- | --- |
| GET | `/api/Items` | Público: todos los objetos |
| GET | `/api/Items/{id}` | Público: un objeto |
| POST | `/api/Items/sync/capture-items` | 🔒 GameAdmin: traer pokébolas y bayas desde PokeAPI |
| PUT | `/api/Items/{id}/regla-juego` | 🔒 GameAdmin: definir si es `ball` o `berry` |
| POST | `/api/Items` | 🔒 GameAdmin: crear un objeto |
| PUT | `/api/Items/{id}` | 🔒 GameAdmin: editarlo |
| DELETE | `/api/Items/{id}` | 🔒 GameAdmin: borrarlo (409 si ya está en inventarios o historial) |

Sincronizar el catálogo (hacerlo primero en una base vacía):

```text
Método   POST
URL      {{baseUrl}}/api/Items/sync/capture-items
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
```

Definir la regla de una pokébola:

```text
Método   PUT
URL      {{baseUrl}}/api/Items/3/regla-juego
Auth     Bearer {{token}}   (usuario con rol GameAdmin)
Headers  Content-Type: application/json
Body     JSON ↓
```

```json
{
  "tipo": "ball",
  "multiplicadorCaptura": 1.5
}
```

La sincronización responde `added`, `updated` y `total`. Trae todas las pokébolas y bayas de PokeAPI (más de cien objetos) y crea sola las reglas de `poke-ball` (1), `great-ball` (1.5), `ultra-ball` (2) y `razz-berry` (baya de 30 segundos). Para cualquier otra bola o baya hay que definir la regla a mano: para `ball` es obligatorio `multiplicadorCaptura` (0.01 a 10); para `berry`, `duracionSegundos` (1 a 86400). **Con la base nueva vacía, el catálogo está vacío:** hasta sincronizarlo nadie recibe pokébolas ni puede capturar.

### Datos de PokeAPI y estados (públicos)

| Ruta | Devuelve |
| --- | --- |
| `GET /api/Estados` | Los 7 estados posibles de un Pokémon |
| `GET /api/pokemon/{id}` | Datos de PokeAPI de un Pokémon |
| `GET /api/pokemon?offset=0&limit=20` | Lista paginada (limit de 1 a 100) |
| `GET /api/pokemon-species/{id}` y `GET /api/pokemon-species?limit=1` | Especies |
| `GET /api/generation/{id}` y `GET /api/generation?limit=50` | Generaciones |

Estas rutas reenvían la consulta a pokeapi.co; si PokeAPI no responde, dan 502 o 504.

## Errores comunes

| Síntoma | Causa probable |
| --- | --- |
| 401 en todo | Falta `Authorization: Bearer <token>` o el token expiró (dura 24 horas) |
| 403 en una ruta de GameAdmin | El usuario no tiene el rol o se usa un token anterior a asignarlo |
| 400 en `register` | La contraseña no cumple las reglas (mayúscula, minúscula, número y símbolo) |
| 404 en el rival o encuentro | El id no existe o pertenece a otro jugador |
| 409 en capturas | Encuentro expirado, ya capturado o sin pokébolas de ese tipo |
| 502 en encuentros o capturas | PokeAPI no respondió o el hosting bloquea la salida a pokeapi.co |
| 500 en todo | Revisa **Logs** en el panel del sitio; suele ser la cadena de conexión |