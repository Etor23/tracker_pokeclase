import 'package:material_ui/material_ui.dart';

/// Colores en cuarentena: solo se usan DENTRO de la lámina de un Pokémon
/// (chips de tipo, barra de vida). El marco de la app nunca los toma.
///
/// El backend manda los tipos en inglés (`water`, `fairy`). Todos los colores
/// tienen al menos 4.6:1 con texto blanco encima.
abstract final class TiposPokemon {
  static const _datos = <String, (String, Color)>{
    'normal': ('Normal', Color(0xFF787561)),
    'fire': ('Fuego', Color(0xFFC84D1C)),
    'water': ('Agua', Color(0xFF2F6FD0)),
    'grass': ('Planta', Color(0xFF39842F)),
    'electric': ('Eléctrico', Color(0xFF936E00)),
    'ice': ('Hielo', Color(0xFF29808B)),
    'fighting': ('Lucha', Color(0xFFB23128)),
    'poison': ('Veneno', Color(0xFF8E3F99)),
    'ground': ('Tierra', Color(0xFF90702A)),
    'flying': ('Volador', Color(0xFF666DC1)),
    'psychic': ('Psíquico', Color(0xFFCF3E6D)),
    'bug': ('Bicho', Color(0xFF667E10)),
    'rock': ('Roca', Color(0xFF857437)),
    'ghost': ('Fantasma', Color(0xFF5E4A8F)),
    'dragon': ('Dragón', Color(0xFF5A3FD1)),
    'dark': ('Siniestro', Color(0xFF4F4238)),
    'steel': ('Acero', Color(0xFF647787)),
    'fairy': ('Hada', Color(0xFFC2497F)),
  };

  /// Nombre en español; si el tipo es desconocido se muestra tal cual.
  static String nombre(String tipo) => _datos[tipo.toLowerCase()]?.$1 ?? tipo;

  static Color color(String tipo) =>
      _datos[tipo.toLowerCase()]?.$2 ?? const Color(0xFF6E6B64);
}

/// Salud de un Pokémon según las reglas de presentación.
enum Salud {
  sano('Sano', Color(0xFF2E7D4F)),
  afectado('Afectado', Color(0xFFA86500)),
  debilitado('Debilitado', Color(0xFF8A1C1C));

  const Salud(this.etiqueta, this.color);

  final String etiqueta;
  final Color color;
}
