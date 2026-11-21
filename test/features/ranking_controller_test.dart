import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracker/core/api/api_client.dart';
import 'package:tracker/core/carga.dart';
import 'package:tracker/data/models/ranking.dart';
import 'package:tracker/data/tracker_repository.dart';
import 'package:tracker/features/ranking/ranking_controller.dart';

Map<String, Object?> _fila(int pos, String nombre) => {
  'posicion': pos,
  'id': 'id-$nombre',
  'userName': nombre,
  'victorias': 0,
  'derrotas': 0,
  'winRate': null,
  'totalPokemon': 1,
  'especiesRegistradas': 1,
};

void main() {
  late List<Uri> pedidas;

  TrackerRepository repo(Future<http.Response> Function(Uri) responder) {
    pedidas = [];
    return TrackerRepository(
      ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((req) {
          pedidas.add(req.url);
          return responder(req.url);
        }),
        tokenProvider: () => 'tok',
        onUnauthorized: () {},
      ),
    );
  }

  http.Response pagina(int total, int pagina, List<String> nombres) =>
      http.Response(
        jsonEncode({
          'total': total,
          'pagina': pagina,
          'tamano': 20,
          'items': [
            for (final (i, n) in nombres.indexed)
              _fila((pagina - 1) * 20 + i + 1, n),
          ],
        }),
        200,
      );

  test('manda orden, página, tamaño y búsqueda al backend', () async {
    final c = RankingController(
      repo((_) async => pagina(1, 1, ['ash'])),
      orden: OrdenRanking.winrate,
      busqueda: 'as',
      miId: null,
    );
    await c.cargar();
    expect(pedidas.single.queryParameters, {
      'orden': 'winrate',
      'pagina': '1',
      'tamano': '20',
      'search': 'as',
    });
    expect(c.estado, isA<Listo<void>>());
    expect(c.filas.single.userName, 'ash');
    expect(c.hayMas, isFalse);
  });

  test('sin búsqueda no manda search', () async {
    final c = RankingController(
      repo((_) async => pagina(0, 1, [])),
      orden: OrdenRanking.pokedex,
      busqueda: '',
      miId: null,
    );
    await c.cargar();
    expect(pedidas.single.queryParameters.containsKey('search'), isFalse);
  });

  test('cargar más agrega la página siguiente', () async {
    final c = RankingController(
      repo(
        (url) async => url.queryParameters['pagina'] == '1'
            ? pagina(25, 1, List.generate(20, (i) => 'j$i'))
            : pagina(25, 2, List.generate(5, (i) => 'k$i')),
      ),
      orden: OrdenRanking.pokedex,
      busqueda: '',
      miId: null,
    );
    await c.cargar();
    expect(c.hayMas, isTrue);
    await c.cargarMas();
    expect(c.filas, hasLength(25));
    expect(c.filas.last.posicion, 25);
    expect(c.hayMas, isFalse);
  });

  test('una respuesta vieja no pisa la búsqueda nueva', () async {
    final lenta = Completer<http.Response>();
    final c = RankingController(
      repo(
        (url) => url.queryParameters['search'] == 'a'
            ? lenta.future
            : Future.value(pagina(1, 1, ['ash'])),
      ),
      orden: OrdenRanking.pokedex,
      busqueda: 'a',
      miId: null,
    );
    final primera = c.cargar();
    c.aplicar(orden: OrdenRanking.pokedex, busqueda: 'ash');
    await pumpEventQueue();
    lenta.complete(pagina(7, 1, ['viejo']));
    await primera;
    expect(c.busqueda, 'ash');
    expect(c.filas.single.userName, 'ash');
  });

  test('el total de la Pokédex sale del resumen propio', () async {
    final c = RankingController(
      repo(
        (url) async => url.path.endsWith('/resumen')
            ? http.Response(
                jsonEncode({
                  'pokedex': {'registrados': 1, 'total': 151},
                }),
                200,
              )
            : pagina(0, 1, []),
      ),
      orden: OrdenRanking.pokedex,
      busqueda: '',
      miId: 'yo',
    );
    await c.cargar();
    await pumpEventQueue();
    expect(c.totalPokedex, 151);
  });

  test('un error queda como Fallo y se puede reintentar', () async {
    var falla = true;
    final c = RankingController(
      repo((_) async => falla ? http.Response('', 500) : pagina(1, 1, ['ash'])),
      orden: OrdenRanking.pokedex,
      busqueda: '',
      miId: null,
    );
    await c.cargar();
    expect(c.estado, isA<Fallo<void>>());
    falla = false;
    await c.cargar();
    expect(c.estado, isA<Listo<void>>());
  });

  test('un orden desconocido en la URL usa el de por defecto', () {
    expect(OrdenRanking.desde('xyz'), OrdenRanking.pokedex);
    expect(OrdenRanking.desde(null), OrdenRanking.pokedex);
    expect(OrdenRanking.desde('victorias'), OrdenRanking.victorias);
  });
}
