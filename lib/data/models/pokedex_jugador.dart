import '../json.dart';

/// `GET /api/Pokedex/usuario/{id}`. Solo trae las especies registradas.
class PokedexJugador {
  const PokedexJugador({
    required this.registrados,
    required this.total,
    required this.especies,
  });

  factory PokedexJugador.fromJson(Json json) => PokedexJugador(
    registrados: json.integer('registrados'),
    total: json.integer('total'),
    especies: {
      for (final e in json.objectList('especies'))
        ?e.intOrNull('idPokemon'): e.utcDateOrNull('fecha'),
    },
  );

  /// Cuenta del backend; incluye especies fuera de la Gen 1.
  final int registrados;
  final int total;

  /// id de especie → fecha de registro.
  final Map<int, DateTime?> especies;

  bool registrada(int id) => especies.containsKey(id);

  /// Especies con id mayor que [total] (por ejemplo, Marill #183).
  List<int> get fueraDeLaGeneracion =>
      (especies.keys.where((id) => id > total).toList()..sort());
}
