# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Jugadores del grupo de clase que juegan la app de Pokémon para Android que desarrolla el
equipo. Entran al tracker desde la computadora o el celular, por igual, para ver su propio
progreso (colección, Pokédex, equipo, batallas, mochila) y, en segundo lugar, para ver los
perfiles de sus compañeros y compararse.

Audiencia secundaria: el grupo y el profesor durante la presentación del proyecto en clase,
proyectado o en pantalla compartida.

## Product Purpose

Una página web de solo lectura que muestra las estadísticas de cada jugador del juego de
clase: un ranking con buscador, el perfil de cada jugador (resumen, equipo, batallas,
mochila, Pokédex), el detalle de cada Pokémon y "Mi perfil", con las pestañas extra de
Tamagotchi e Intercambios. Tiene éxito si un jugador entiende en segundos cómo va su
colección y qué le falta.

## Positioning

Es el único lugar fuera del juego donde se ven los datos reales de los jugadores del grupo.
Cada perfil tiene una URL que se puede compartir.

## Operating Context

- Cada jugador inicia sesión con su propia cuenta del juego; no hay cuenta compartida.
- Se usa por igual en computadora y en celular, en Flutter web.
- Se presenta en clase: tiene que leerse bien a distancia en un proyector.
- No es en tiempo real: los datos se recargan al abrir cada pantalla y con un botón de
  refrescar.

## Capabilities and Constraints

- Solo lectura: el único POST es el login. Las reglas completas y los endpoints están en
  `docs/CLAUDE.md`.
- Generación 1 (151 especies), aunque el backend también acepta especies de otras
  generaciones (un Marill #183 cuenta en `registrados`).
- Nunca mostrar email ni otros datos de Identity; los usuarios se muestran solo con `id` y
  `userName`.
- Los sprites vienen del repositorio público de PokeAPI (`urlFrontal` o por id de especie).
- Todavía hay pocos datos reales (7 jugadores, casi sin batallas), así que los estados vacíos
  son lo más frecuente hoy.
- Después del login, o al abrir la app sin ruta, se entra a "Mi perfil" (`/yo`); un link
  compartido lleva a su ruta (decidido el 2026-11-21).

## Brand Commitments

- Paleta pedida por el usuario: los colores de una pokébola, rojo, negro y blanco.
- Estética de panel de estadísticas, con relación real a Pokémon (tipos, estados, sprites,
  Pokédex), sin copiar la interfaz, los personajes ni el arte de ningún juego existente.
- Interfaz en español.

## Evidence on Hand

- Datos reales del backend, verificados el 2026-11-21 (ver `docs/CLAUDE.md`).
- No hay logotipo, ilustraciones ni fotografía propia. No inventar testimonios ni cifras.

## Product Principles

1. Lo personal primero: el jugador ve su progreso antes que el de los demás.
2. Los números deben ser ciertos: `winRate` nulo se muestra como "—", nunca como 0 %; el total
   de la Pokédex lo da el backend.
3. Un dato vacío se explica, no se esconde: con pocos datos, los estados vacíos son la
   experiencia principal.
4. Legible a distancia: lo que importa tiene que entenderse en un proyector.

## Accessibility & Inclusion

Contraste suficiente para un proyector y para pantallas de celular al aire libre. El color
de un tipo o de un estado nunca es la única señal: siempre va acompañado de texto o de un
ícono.
