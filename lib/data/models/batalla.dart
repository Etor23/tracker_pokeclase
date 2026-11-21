import '../json.dart';

enum ResultadoBatalla {
  victoria('Victoria'),
  derrota('Derrota'),
  huida('Huida');

  const ResultadoBatalla(this.valor);

  /// Valor del backend (también el filtro `?resultado=`).
  final String valor;

  static ResultadoBatalla? desde(String? valor) =>
      values.where((r) => r.valor == valor).firstOrNull;
}

/// Una página de `GET /api/Batallas/usuario/{id}`, de la más reciente a la
/// más antigua.
class PaginaBatallas {
  const PaginaBatallas({required this.total, required this.filas});

  factory PaginaBatallas.fromJson(Json json) => PaginaBatallas(
    total: json.integer('total'),
    filas: json.objectList('items').map(Batalla.fromJson).toList(),
  );

  final int total;
  final List<Batalla> filas;
}

class Batalla {
  const Batalla({
    required this.id,
    required this.fecha,
    required this.resultado,
    required this.idEspecieRival,
    required this.pokemon,
  });

  factory Batalla.fromJson(Json json) {
    final p = json.object('pokemon');
    return Batalla(
      id: json.integer('id'),
      fecha: json.utcDateOrNull('fecha'),
      resultado: ResultadoBatalla.desde(json.stringOrNull('resultado')),
      idEspecieRival: json.intOrNull('idPokemonRival'),
      pokemon: PokemonEnBatalla(
        id: p.integer('id'),
        idEspecie: p.integer('idPokemon'),
        nombre: p.string('nombre'),
        urlFrontal: p.stringOrNull('urlFrontal'),
      ),
    );
  }

  final int id;
  final DateTime? fecha;

  /// `null` si el backend manda un resultado desconocido.
  final ResultadoBatalla? resultado;

  /// El rival solo viene como especie; el nombre sale del catálogo.
  final int? idEspecieRival;

  /// El Pokémon del jugador que peleó.
  final PokemonEnBatalla pokemon;
}

class PokemonEnBatalla {
  const PokemonEnBatalla({
    required this.id,
    required this.idEspecie,
    required this.nombre,
    required this.urlFrontal,
  });

  final int id;
  final int idEspecie;
  final String nombre;
  final String? urlFrontal;
}
