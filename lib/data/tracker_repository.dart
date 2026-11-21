import '../core/api/api_client.dart';
import 'json.dart';
import 'models/pokedex_jugador.dart';
import 'models/pokemon_jugador.dart';
import 'models/ranking.dart';
import 'models/resumen_jugador.dart';

/// Lecturas del perfil de cualquier jugador. Todo es GET.
class TrackerRepository {
  TrackerRepository(this._api);

  final ApiClient _api;

  String _id(String userId) => Uri.encodeComponent(userId);

  Future<ResumenJugador> resumen(String userId) async =>
      ResumenJugador.fromJson(
        asJson(await _api.get('/api/tracker/usuarios/${_id(userId)}/resumen')),
      );

  Future<List<PokemonJugador>> pokemon(String userId) async =>
      asJsonList(await _api.get('/api/PokemonUsers/usuario/${_id(userId)}'))
          .map(PokemonJugador.fromJson)
          .toList();

  /// Ranking de jugadores. Incluye al usuario actual.
  Future<PaginaRanking> ranking({
    required OrdenRanking orden,
    int pagina = 1,
    int tamano = 20,
    String? busqueda,
  }) async => PaginaRanking.fromJson(
    asJson(
      await _api.get(
        '/api/tracker/usuarios',
        query: {
          'orden': orden.valor,
          'pagina': pagina,
          'tamano': tamano,
          'search': (busqueda == null || busqueda.isEmpty) ? null : busqueda,
        },
      ),
    ),
  );

  Future<PokedexJugador> pokedex(String userId) async =>
      PokedexJugador.fromJson(
        asJson(await _api.get('/api/Pokedex/usuario/${_id(userId)}')),
      );
}
