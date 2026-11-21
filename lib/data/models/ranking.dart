import '../json.dart';

/// Órdenes que acepta `GET /api/tracker/usuarios?orden=`.
enum OrdenRanking {
  pokedex('pokedex', 'Pokédex'),
  winrate('winrate', 'Win rate'),
  victorias('victorias', 'Victorias'),
  pokemon('pokemon', 'Pokémon'),
  nombre('nombre', 'Nombre');

  const OrdenRanking(this.valor, this.etiqueta);

  /// Valor del query string.
  final String valor;
  final String etiqueta;

  /// El orden por defecto del tracker (el del backend es `nombre`).
  static const porDefecto = OrdenRanking.pokedex;

  static OrdenRanking desde(String? valor) => OrdenRanking.values.firstWhere(
    (o) => o.valor == valor,
    orElse: () => porDefecto,
  );
}

/// Una página de `GET /api/tracker/usuarios`.
class PaginaRanking {
  const PaginaRanking({
    required this.total,
    required this.pagina,
    required this.filas,
  });

  factory PaginaRanking.fromJson(Json json) => PaginaRanking(
    total: json.integer('total'),
    pagina: json.integer('pagina', 1),
    filas: json.objectList('items').map(FilaRanking.fromJson).toList(),
  );

  final int total;
  final int pagina;
  final List<FilaRanking> filas;
}

class FilaRanking {
  const FilaRanking({
    required this.posicion,
    required this.id,
    required this.userName,
    required this.victorias,
    required this.derrotas,
    required this.winRate,
    required this.totalPokemon,
    required this.especiesRegistradas,
  });

  factory FilaRanking.fromJson(Json json) => FilaRanking(
    posicion: json.integer('posicion'),
    id: json.string('id'),
    userName: json.string('userName'),
    victorias: json.integer('victorias'),
    derrotas: json.integer('derrotas'),
    winRate: json.doubleOrNull('winRate'),
    totalPokemon: json.integer('totalPokemon'),
    especiesRegistradas: json.integer('especiesRegistradas'),
  );

  /// Posición dentro de los resultados. Con búsqueda, el backend la renumera
  /// sobre lo filtrado: ya no es el lugar en el ranking general.
  final int posicion;
  final String id;
  final String userName;
  final int victorias;
  final int derrotas;
  final double? winRate;
  final int totalPokemon;
  final int especiesRegistradas;
}
