---
version: 1
slug: "lib-features-perfil-perfil-screen-dart"
primary_target: "lib/features/perfil/perfil_screen.dart"
related_targets: ["lib/features/login/login_screen.dart","lib/features/shared"]
---

## Scope

Perfil de jugador (`/usuario/:id` y `/yo`), primera superficie del mundo visual; el shell
(barra superior, búsqueda) y el login la heredan. Modo: Operate. Audiencia: jugadores del
grupo, en computadora y celular por igual, y proyectado en clase. Tarea: entender en
segundos el progreso propio (Pokédex, equipo, batallas, mochila) y saltar a otro jugador.
Construcción en código (sin generación de imágenes en esta sesión).

## Direction contract

THESIS: Las cifras del jugador se componen como un especimen tipográfico de pixeles: el
progreso de la Pokédex es una cifra bitmap a escala de póster, del mismo grano que los
sprites de la Gen 1. Rechaza el dashboard de tarjetas redondeadas con dona y KPIs.

OWN-WORLD: Papel blanco hueso, tinta casi negra y un solo rojo de pokébola como acento
sintético. Reglas negras de 2 px, esquinas rectas, franjas negras con etiqueta bitmap como
encabezado de sección, cuadro rojo como marcador de estado y trama de puntos para lo vacío o
lo pendiente. Silkscreen solo en cifras grandes y etiquetas cortas en mayúsculas; Archivo
para todo el texto de interfaz. Los colores de tipo y estado viven solo dentro de la lámina de
cada Pokémon. Cifras tabulares, barras a escala exacta y todo acomodado en celdas de un
módulo.

STORY: El jugador abre su perfil y lee primero cuánto lleva de la Pokédex; después su equipo
y sus batallas. Cambia de pestaña, vuelve al ranking o busca a otro jugador desde la barra
superior. Con pocos datos, cada vacío explica qué falta y cómo se llena.

FIRST VIEWPORT: Barra superior de 58 px con regla de 2 px: marca bitmap "TRACKER POKÉMON",
navegación Ranking / Mi perfil, campo de búsqueda y usuario. Columna principal: nombre en
bitmap a 48 px, pestañas con regla de 2 px y la cifra "001/151" en bitmap a unos 200 px sobre
su etiqueta y su tira de puntos a escala exacta; debajo, una fila de cuatro cifras. Columna
derecha de 420 px con regla izquierda: el equipo, con el sprite en pixeles nítidos y su tabla.
En celular, una sola columna, la cifra a unos 96 px y las pestañas desplazables.

FORM: especimen bitmap (retador del catálogo `emigre-bitmap-specimen`, competitivo, elegido por
el usuario por encima de la dirección asignada; no es de la lista propia). seed: 6f1ed2dc3d203994.
Movimiento característico: los sprites solo escalan en múltiplos enteros de pixel, nunca
suavizados, y las cifras grandes comparten ese grano.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Resolved

- Destino después del login: Mi perfil (`/yo`), salvo que se haya pedido otra ruta
  (2026-11-21).
