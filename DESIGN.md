---
name: Tracker Pokémon
description: Estadísticas de los jugadores del grupo compuestas como un especimen tipográfico de pixeles.
colors:
  rojo-pokebola: "#D7001A"
  tinta: "#0A0A0A"
  papel-hueso: "#F2F0EB"
  tinta-suave: "#4A4843"
  tenue: "#6E6B64"
  linea: "#CFCBC2"
  hueco: "#E6E3DC"
  blanco: "#FFFFFF"
  salud-sano: "#2E7D4F"
  salud-afectado: "#A86500"
  salud-debilitado: "#8A1C1C"
  tipo-normal: "#787561"
  tipo-fuego: "#C84D1C"
  tipo-agua: "#2F6FD0"
  tipo-planta: "#39842F"
  tipo-electrico: "#936E00"
  tipo-hielo: "#29808B"
  tipo-lucha: "#B23128"
  tipo-veneno: "#8E3F99"
  tipo-tierra: "#90702A"
  tipo-volador: "#666DC1"
  tipo-psiquico: "#CF3E6D"
  tipo-bicho: "#667E10"
  tipo-roca: "#857437"
  tipo-fantasma: "#5E4A8F"
  tipo-dragon: "#5A3FD1"
  tipo-siniestro: "#4F4238"
  tipo-acero: "#647787"
  tipo-hada: "#C2497F"
typography:
  display:
    fontFamily: "Silkscreen"
    fontSize: "192px"
    fontWeight: 400
    lineHeight: 1
    letterSpacing: "0em"
    fontFeature: "tnum"
  headline:
    fontFamily: "Silkscreen"
    fontSize: "48px"
    fontWeight: 400
    lineHeight: 1
    letterSpacing: "0em"
    fontFeature: "tnum"
  label:
    fontFamily: "Silkscreen"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1
    letterSpacing: "0em"
    fontFeature: "tnum"
  title:
    fontFamily: "Archivo"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.2
  body:
    fontFamily: "Archivo"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.45
  body-soft:
    fontFamily: "Archivo"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.45
  small:
    fontFamily: "Archivo"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.35
  data:
    fontFamily: "Archivo"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.3
    fontFeature: "tnum"
  chip:
    fontFamily: "Archivo"
    fontSize: "13px"
    fontWeight: 700
    lineHeight: 1.35
rounded:
  none: "0px"
spacing:
  xs: "4px"
  s: "8px"
  m: "16px"
  l: "24px"
  xl: "32px"
  xxl: "48px"
  regla: "2px"
  margen-movil: "16px"
  margen-escritorio: "40px"
components:
  button-primary:
    backgroundColor: "{colors.rojo-pokebola}"
    textColor: "{colors.blanco}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    padding: "0 24px"
    height: "48px"
  button-primary-disabled:
    backgroundColor: "{colors.linea}"
    textColor: "{colors.tenue}"
  button-outline:
    backgroundColor: "{colors.papel-hueso}"
    textColor: "{colors.tinta}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    height: "40px"
  button-text:
    textColor: "{colors.tinta}"
    rounded: "{rounded.none}"
  input:
    backgroundColor: "{colors.blanco}"
    textColor: "{colors.tinta}"
    typography: "{typography.body}"
    rounded: "{rounded.none}"
    padding: "14px 16px"
  franja-titulo:
    backgroundColor: "{colors.tinta}"
    textColor: "{colors.papel-hueso}"
    typography: "{typography.label}"
    rounded: "{rounded.none}"
    padding: "0 16px"
    height: "40px"
  lamina-pokemon:
    backgroundColor: "{colors.papel-hueso}"
    textColor: "{colors.tinta}"
    rounded: "{rounded.none}"
    padding: "16px"
  chip-tipo:
    textColor: "{colors.blanco}"
    typography: "{typography.chip}"
    rounded: "{rounded.none}"
    padding: "3px 8px"
  nav-link-active:
    textColor: "{colors.rojo-pokebola}"
  nav-bar-movil:
    backgroundColor: "{colors.papel-hueso}"
    height: "64px"
  nav-bar-movil-indicador:
    backgroundColor: "{colors.rojo-pokebola}"
    textColor: "{colors.blanco}"
    rounded: "{rounded.none}"
---

# Design System: Tracker Pokémon

## Overview

**Creative North Star: "El especimen bitmap"**

Cada perfil se compone como la hoja de muestra de una fuente de pixeles: el dato más importante (cuántas especies lleva el jugador en la Pokédex) es una cifra bitmap a escala de póster, del mismo grano que los sprites de la Generación 1, y todo lo demás se ordena debajo en una retícula de celdas, reglas negras y etiquetas cortas en mayúsculas. Es papel, tinta y un solo rojo de pokébola; nada brilla, nada flota, nada está redondeado.

La densidad es de tabla impresa, no de dashboard: las cifras se leen a distancia (el tracker se proyecta en clase) y los textos de apoyo son pequeños y secundarios. Lo vacío no se esconde: se marca con una trama de puntos y se explica con una nota de borde punteado y cuadro rojo. El sistema rechaza explícitamente el dashboard de tarjetas redondeadas con dona y KPIs.

Los colores de los tipos Pokémon y de la salud existen, pero en cuarentena: solo aparecen dentro de la lámina de cada Pokémon, que es la única pieza del mundo donde el dato del juego trae su propio color.

**Key Characteristics:**
- Silkscreen (bitmap) para cifras y etiquetas; Archivo para todo el texto de interfaz.
- Papel hueso, tinta casi negra y un único acento rojo.
- Esquinas rectas en todo; reglas de 2 px como estructura.
- Sprites en pixeles nítidos, solo a escala entera.
- Trama de puntos de 2 px como textura de lo vacío o lo pendiente.
- Un solo momento de movimiento: el barrido de la tira de la Pokédex.

## Colors

Tres tintas de imprenta (papel, tinta y rojo) con grises cálidos de apoyo; los colores del juego viven aparte, en cuarentena.

### Primary
- **Rojo pokébola** (rojo-pokebola): el único acento. Botón principal, registro en la tira de la Pokédex, "POKÉMON" en la marca, subrayado de la pestaña y del enlace activos, indicador de la barra inferior en celular, foco de teclado, errores y el cuadro marcador de las notas. Tiene 4.6:1 sobre papel y 5.3:1 con texto blanco encima.

### Neutral
- **Tinta** (tinta): texto principal, cifras bitmap, reglas estructurales de 2 px, franjas de título, bordes de láminas y campos, cursor del barrido.
- **Papel hueso** (papel-hueso): fondo de la página, de las láminas y de la barra superior; texto sobre las franjas de tinta.
- **Tinta suave** (tinta-suave): texto secundario, etiquetas de dato bitmap, borde punteado de las notas y, al 45 % de opacidad, las celdas no registradas de la tira (7.9:1 sobre papel).
- **Tenue** (tenue): placeholders, el "/151" del total, texto de botón deshabilitado (4.6:1 sobre papel).
- **Línea** (linea): divisores finos de 1 px entre celdas de cifras, trama de puntos, fondo de botón deshabilitado, celdas pendientes durante el barrido.
- **Hueco** (hueco): fondo de la celda de sprite y del carril de las barras.
- **Blanco** (blanco): texto sobre rojo o sobre un color de tipo o salud, y fondo de los campos de texto.

### Colores en cuarentena (salud y tipos)
- **Salud** (salud-sano, salud-afectado, salud-debilitado): cuadro de 8 px junto al estado y relleno de la barra de PS.
- **Tipos** (tipo-*, 18 tonos): fondo de la etiqueta de tipo, siempre con texto blanco (al menos 4.6:1). Un tipo desconocido cae al gris tenue.

### Named Rules
**The Un Solo Rojo Rule.** El rojo pokébola es el único acento del marco de la app. Marca lo registrado, lo activo, lo enfocado y lo que necesita atención; nunca decora.

**The Cuarentena Rule.** Los colores de tipo y de salud solo existen dentro de la lámina de un Pokémon. El marco (barra, franjas, cifras, tira, notas) nunca los toma.

**The Color Nunca Solo Rule.** Un color de tipo o de salud siempre va con su texto ("Eléctrico", "Quemado"); el color nunca es la única señal.

## Typography

**Display Font:** Silkscreen (bitmap, OFL, empaquetada en `assets/fonts/`)
**Body Font:** Archivo (400, 500, 600, 700; OFL, empaquetada)

**Character:** Silkscreen pone el grano de pixel de los sprites en las cifras y etiquetas; Archivo, una grotesca sobria, carga todo lo que se lee como frase. El contraste entre ambas es la voz del sistema.

### Hierarchy
- **Display** (Silkscreen 400, 192 px en columnas de 760 px o más, 144 px desde 560 px, 96 px por debajo; altura 1): la cifra de la Pokédex, una por pantalla. El total ("/151") va a la mitad del tamaño y en tenue.
- **Headline** (Silkscreen 400, 48 px en escritorio y 32 px en celular; altura 1): nombre del jugador, valores de la fila de cifras, marca del login.
- **Label** (Silkscreen 400, 16 px, mayúsculas): franjas de título, etiquetas de dato ("POKÉMON", "WIN RATE"), pie de la cifra, número de especie, texto de botones con relleno y contorno. La marca de la barra usa 24 px en escritorio y 16 px en celular.
- **Title** (Archivo 700, 20 px, 1.2): nombre del Pokémon en la lámina.
- **Body** (Archivo 400, 16 px, 1.45): texto corrido y campos.
- **Body soft** (Archivo 400, 15 px, 1.45, tinta suave): notas, descripciones y detalles bajo una cifra en pantallas anchas.
- **Small** (Archivo 400, 13 px, 1.35, tinta suave): detalles en celular (menos de 900 px), fechas, tooltips.
- **Data** (Archivo 600, 16 px, 1.3, cifras tabulares): nombre de usuario en la barra y valores de las barras (15 px en escritorio, 14 px en celular).
- **Chip** (Archivo 700, 13 px, blanco): etiqueta de tipo.
- Interfaz de pestañas y enlaces: Archivo 15 px, 700 activa y 600 inactiva.

### Named Rules
**The Múltiplo de Ocho Rule.** Silkscreen solo se usa en tamaños múltiplos de 8 px, para que cada pixel del glifo caiga entero. El código lo impone con una aserción en `Tipos.bitmap`.

**The Octavo de Em Rule.** Silkscreen deja 1/8 de em de margen a la izquierda de cada glifo. Una cifra bitmap que debe arrancar en el borde de la columna se desplaza −tamaño/8 en x (así está la cifra de la Pokédex).

**The Cifras Tabulares Rule.** Toda cifra (Silkscreen y el estilo Data) lleva `tabularFigures`, para que las columnas de números se alineen.

**The Bitmap Breve Rule.** Silkscreen solo para cifras grandes y etiquetas cortas en mayúsculas. Ninguna frase, descripción ni texto de ayuda va en bitmap.

## Layout

Retícula de 8 px (con un medio paso de 4 px): todo se acomoda en celdas completas. Márgenes laterales de 40 px desde 700 px de ancho y 16 px por debajo.

- **Barra superior:** 64 px en escritorio y 56 px en celular, sobre papel y con regla inferior de 2 px. En escritorio lleva marca, enlaces Ranking / Mi perfil, campo de búsqueda de 280 px, usuario y "Salir". Desde 900 px es escritorio; por debajo la navegación baja a una barra inferior de 64 px con regla superior de 2 px.
- **Perfil:** encabezado con el nombre en bitmap y una línea pequeña; pestañas desplazables de 48 px de alto alineadas al inicio, sobre regla de 2 px; contenido con 24 px arriba y 48 px abajo.
- **Resumen:** desde 1000 px de columna, dos columnas: la principal flexible y una columna de equipo de 420 px, separadas 32 px. Por debajo, una sola columna con el equipo después.
- **Fila de cifras:** tabla con regla superior de 2 px en tinta y divisores internos de 1 px en línea; cuatro columnas en ancho, dos por debajo de 640 px. Celdas con 16 px de relleno (la primera sin relleno izquierdo, para que su texto arranque en el borde).
- **Login:** columna centrada de 400 px como máximo.

**The Celda Completa Rule.** Los espacios salen de la escala de `Espacio` (4, 8, 16, 24, 32, 48) y las reglas miden 2 px. Un espacio nuevo se elige de la escala, no se inventa.

## Elevation & Depth

Plano por completo. No hay sombras ni elevación: los botones y menús declaran elevación 0, el splash de Material está apagado (`NoSplash`) y la jerarquía se construye con reglas de 2 px, franjas de tinta y contraste de escala tipográfica. La única "profundidad" es la trama de puntos detrás de un sprite y en los bloques de carga, que se lee como textura de impresión, no como capa. Las respuestas de estado (hover, pulsado) son velos planos de tinta al 8 % o al 12 %.

**The Papel Plano Rule.** Nada flota sobre el papel. La separación se dibuja con una regla, nunca con una sombra.

## Shapes

Esquinas rectas en todo (radio 0): botones, campos, láminas, chips, indicadores de navegación, menús y hasta el pulgar de la barra de desplazamiento. Las formas son rectángulos y cuadros: el cuadro de 8 px es el marcador (rojo en las notas, color de salud en la lámina), la celda cuadrada es la unidad de la tira de la Pokédex, y los bordes punteados se dibujan con cuadros de 2 px separados 2 px.

- **Regla estructural:** 2 px de tinta (bordes de lámina, campos, botones, franjas, barras).
- **Divisor fino:** 1 px en línea.
- **Foco:** regla roja de 3 px.
- **Indicador activo:** subrayado rojo de 4 px (pestañas y enlaces de navegación).

**The Esquina Recta Rule.** Ningún radio. Un rectángulo redondeado no pertenece a este mundo.

## Components

### Buttons
- **Shape:** rectos (0 px), con regla de tinta de 2 px.
- **Primario (relleno):** rojo con texto blanco en etiqueta bitmap de 16 px y mayúsculas ("ENTRAR"); alto mínimo de 48 px y 24 px de relleno lateral. Deshabilitado: fondo línea y texto tenue. El indicador de progreso dentro del botón va en tinta.
- **Contorno:** papel con texto en tinta y etiqueta bitmap en mayúsculas ("REINTENTAR", "VER LOS 5 POKÉMON"); alto mínimo de 40 px.
- **Texto e ícono:** sin borde, en tinta; Archivo 600 a 15 px para el texto.
- **Hover / Pulsado:** velo de tinta plano (12 % en el primario, 8 % en los demás); sin onda ni elevación.
- **Foco:** el borde pasa a regla roja de 3 px en todos los botones, también en los que no tienen borde.

### Chips
- **Etiqueta de tipo:** rectángulo con el color del tipo, Archivo 700 a 13 px en blanco, relleno de 3 × 8 px, separación de 4 px. Solo dentro de la lámina.

### Cards / Containers
- **Lámina de Pokémon:** la única tarjeta. Esquinas rectas, papel, regla de tinta de 2 px, 16 px de relleno. Sprite a la izquierda (192 px a escala 2 si el ancho es de 360 px o más, 96 px a escala 1 por debajo), nombre en Title, número de especie en etiqueta bitmap, chips de tipo, salud (cuadro de 8 px en color de salud y su nombre real). Debajo, las barras de dato. Toda la lámina es un enlace al detalle.
- **Sin sombra** (ver Elevation & Depth).

### Inputs / Fields
- **Estilo:** fondo blanco, regla de tinta de 2 px, esquinas rectas, relleno de 14 × 16 px, compacto. Etiqueta en tinta suave que pasa a tinta al flotar; placeholder en tenue.
- **Foco:** regla roja de 2 px; foco con error, regla roja de 3 px.
- **Error:** regla roja y texto de error rojo en Archivo 600.

### Navigation
- **Escritorio:** enlaces de texto en Archivo 600 a 15 px; el activo cambia a rojo y lleva un subrayado rojo de 4 px.
- **Pestañas:** Archivo 15 px (700 activa, 600 inactiva), subrayado rojo de 4 px al ancho de la etiqueta, regla de tinta de 2 px debajo de toda la fila, desplazables y alineadas al inicio.
- **Celular:** barra inferior de Material sobre papel, 64 px, regla superior de 2 px; el destino activo lleva un indicador rojo recto con ícono blanco. En un perfil ajeno no hay destino resaltado.

### Franja de título
Encabezado de sección: franja de tinta de 40 px con la etiqueta bitmap de 16 px en papel y mayúsculas, 16 px de relleno lateral y un conteo opcional a la derecha ("EQUIPO 5"). Es un encabezado semántico.

### Cifra de la Pokédex
La cifra registrada con tres dígitos ("023") en Display, el total a la mitad del tamaño en tenue, compensada 1/8 de em a la izquierda y con escala hacia abajo si no cabe; debajo, el pie "REGISTRADAS EN LA POKÉDEX" en etiqueta bitmap y la tira.

### Tira de la Pokédex
La Pokédex completa como tira de celdas, una por especie del total que da el backend. Celdas cuadradas de al menos 8 px con 2 px de separación; se agregan filas hasta que cada celda llegue a 8 px, y el sobrante se reparte en los huecos para cerrar exacto en el borde derecho. Registrada: rojo sólido. No registrada: damero de cuadros de 2 px en tinta suave al 45 %. Es el dato, no una barra decorativa.

**The Un Solo Movimiento Rule.** Al aparecer, un cursor de tinta recorre la tira una vez en 700 ms (lineal) y voltea cada celda al pasar; las pendientes se ven en trama de línea. Es el único movimiento del perfil. Con "reducir movimiento" activo la tira aparece completa, sin barrido.

### Barra de dato
Etiqueta de 84 px, carril de 8 px en hueco con el relleno a la fracción exacta (PS en el color de salud, ataque, defensa y velocidad en tinta sobre un máximo de 255) y valor alineado a la derecha en 72 px con cifras tabulares.

**The Escala Exacta Rule.** Una barra mide exactamente su fracción del máximo. Sin mínimos visibles, sin redondeos, sin degradados.

### Sprite en pixeles
Sprites de PokeAPI (96 × 96) a escala entera (1×, 2×), con `FilterQuality.none` y sin antialias, sobre una celda en hueco con trama de puntos. Atenuado (crianza muerta o no registrado): escala de grises al 45 % de opacidad. Si falla la carga, la celda muestra el número de especie en bitmap tenue.

**The Pixel Entero Rule.** Un sprite solo escala en múltiplos enteros de 96 px y nunca se suaviza; las cifras grandes comparten ese grano.

### Nota vacía
Explica un dato vacío, pendiente o fallido: borde punteado de cuadros de 2 px en tinta suave, 16 px de relleno, cuadro rojo de 8 px como marcador y el mensaje en Body soft, con una acción opcional ("REINTENTAR") debajo. Los bloques de carga son trama de puntos del tamaño del contenido que llega.

**The Vacío Explicado Rule.** Un dato vacío nunca se esconde ni se muestra en cero falso: lleva una nota que dice qué falta y cómo se llena, y un win rate nulo se escribe "—".

## Do's and Don'ts

### Do:
- **Do** usar Silkscreen solo en múltiplos de 8 px y compensar 1/8 de em a la izquierda cuando la cifra deba arrancar en el borde.
- **Do** escalar sprites solo en enteros, con `FilterQuality.none`, sobre la celda en hueco con trama.
- **Do** dibujar las barras a la fracción exacta del dato y escribir toda cifra con dígitos tabulares.
- **Do** abrir cada sección con la franja de tinta y etiqueta bitmap, y estructurar con reglas de 2 px en tinta y divisores de 1 px en línea.
- **Do** marcar lo vacío o lo pendiente con la trama de puntos y explicarlo con la nota de borde punteado y cuadro rojo.
- **Do** tomar colores, medidas y estilos de `lib/core/theme/` (`Paleta`, `Espacio`, `Tipos`).
- **Do** mostrar el foco de teclado como regla roja de 3 px.

### Don't:
- **Don't** redondear esquinas ni usar sombras o elevación.
- **Don't** usar los colores de tipo o de salud fuera de la lámina de un Pokémon.
- **Don't** agregar un segundo color de acento ni usar el rojo como decoración.
- **Don't** suavizar ni escalar un sprite a un factor fraccionario.
- **Don't** escribir frases o texto de ayuda en Silkscreen, ni usarlo en tamaños que no sean múltiplos de 8.
- **Don't** agregar movimiento más allá del barrido de la tira, ni un barrido que ignore "reducir movimiento".
- **Don't** componer el perfil como dashboard de tarjetas redondeadas con dona y KPIs.
