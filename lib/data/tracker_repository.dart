import '../core/api/api_client.dart';
import 'json.dart';
import 'models/batalla.dart';
import 'models/catalogo_especies.dart';
import 'models/objeto_mochila.dart';
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

  /// Batallas de la más reciente a la más antigua. [resultado] filtra.
  Future<PaginaBatallas> batallas(
    String userId, {
    int pagina = 1,
    int tamano = 20,
    ResultadoBatalla? resultado,
  }) async => PaginaBatallas.fromJson(
    asJson(
      await _api.get(
        '/api/Batallas/usuario/${_id(userId)}',
        query: {
          'pagina': pagina,
          'tamano': tamano,
          'resultado': resultado?.valor,
        },
      ),
    ),
  );

  /// Mochila de cualquier jugador. Para la propia también se usa esta ruta:
  /// `GET /api/Inventario` y `/api/me/inventory` acreditan pokébolas.
  Future<List<ObjetoMochila>> mochila(String userId) async =>
      asJsonList(await _api.get('/api/Inventario/usuario/${_id(userId)}'))
          .map(ObjetoMochila.fromJson)
          .toList();

  /// Ids de mis Pokémon reservados en un intercambio (`GET /api/me/pokemon`).
  Future<Set<int>> misReservados() async => {
    for (final p in asJsonList(await _api.get('/api/me/pokemon')))
      if (p.boolean('reserved')) p.integer('id'),
  };

  Future<CatalogoEspecies>? _catalogo;

  /// Catálogo público de la Gen 1; se pide una vez por sesión de la app.
  Future<CatalogoEspecies> catalogo() => _catalogo ??= _api
      .get('/api/generation/1', authenticated: false)
      .then((json) => CatalogoEspecies.fromJson(asJson(json)))
      .catchError((Object e) {
        _catalogo = null; // reintentar la próxima vez
        throw e;
      });
}
