import 'package:material_ui/material_ui.dart';

/// Paleta del mundo "especimen bitmap": papel, tinta y un solo rojo de
/// pokébola. Los colores de tipo y estado NO van aquí: viven solo dentro de la
/// lámina de cada Pokémon (ver `pokemon_colores.dart`).
abstract final class Paleta {
  static const papel = Color(0xFFF2F0EB);
  static const tinta = Color(0xFF0A0A0A);

  /// Rojo de acento. 4.6:1 sobre papel y 5.3:1 con texto blanco encima.
  static const rojo = Color(0xFFD7001A);

  /// Texto secundario (7.9:1 sobre papel).
  static const tintaSuave = Color(0xFF4A4843);

  /// Texto tenue y placeholders (4.6:1 sobre papel).
  static const tenue = Color(0xFF6E6B64);

  /// Reglas finas y celdas vacías.
  static const linea = Color(0xFFCFCBC2);

  /// Fondo de las celdas de sprite.
  static const hueco = Color(0xFFE6E3DC);
}

/// Espaciado en un módulo de 8 px; todo se acomoda en celdas completas.
abstract final class Espacio {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Ancho de la regla principal (bordes, divisiones).
  static const double regla = 2;

  /// Margen lateral de la página según el ancho disponible.
  static double margen(double ancho) => ancho >= 700 ? 40 : 16;
}

/// Tipografía. Silkscreen (bitmap) solo en cifras grandes y etiquetas cortas,
/// siempre en múltiplos de 8 px para que el pixel caiga entero. Archivo para
/// todo el texto de interfaz.
abstract final class Tipos {
  static const _tabular = [FontFeature.tabularFigures()];

  /// Silkscreen a un tamaño múltiplo de 8.
  static TextStyle bitmap(double size, {Color color = Paleta.tinta}) {
    assert(size % 8 == 0, 'Silkscreen solo en múltiplos de 8 px');
    return TextStyle(
      fontFamily: 'Silkscreen',
      fontSize: size,
      height: 1,
      color: color,
      fontFeatures: _tabular,
    );
  }

  /// Etiqueta corta en mayúsculas (franjas, encabezados de dato).
  static final etiqueta = bitmap(16);

  static const cuerpo = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 16,
    height: 1.45,
    color: Paleta.tinta,
  );

  static const cuerpoSuave = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 15,
    height: 1.45,
    color: Paleta.tintaSuave,
  );

  static const pequeno = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 13,
    height: 1.35,
    color: Paleta.tintaSuave,
  );

  static const titulo = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Paleta.tinta,
  );

  /// Cifras de interfaz (tablas, filas de datos).
  static const dato = TextStyle(
    fontFamily: 'Archivo',
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: Paleta.tinta,
    fontFeatures: _tabular,
  );
}
