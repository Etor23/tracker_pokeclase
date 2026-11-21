import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracker/core/api/api_client.dart';
import 'package:tracker/data/json.dart';
import 'package:tracker/data/models/batalla.dart';
import 'package:tracker/data/models/catalogo_especies.dart';
import 'package:tracker/data/models/objeto_mochila.dart';
import 'package:tracker/data/tracker_repository.dart';

Object? _fixture(String nombre) =>
    jsonDecode(File('test/fixtures/$nombre.json').readAsStringSync());

void main() {
  test('mochila real: datos anidados en item', () {
    final lista = asJsonList(_fixture('ash_mochila'))
        .map(ObjetoMochila.fromJson)
        .toList();
    expect(lista.map((o) => o.cantidad), [9, 2, 3]);
    final great = lista[1];
    expect(great.nombre, 'great-ball');
    expect(great.esPokebola, isTrue);
    expect(great.multiplicadorCaptura, 1.5);
    expect(great.urlImagen, endsWith('/items/great-ball.png'));
  });

  test('catálogo real de la Gen 1: id desde la url', () {
    final c = CatalogoEspecies.fromJson(asJson(_fixture('generation_1')));
    expect(c.nombre(1), 'Bulbasaur');
    expect(c.nombre(25), 'Pikachu');
    expect(c.nombre(151), 'Mew');
    expect(c.nombre(183), '#183', reason: 'fuera del catálogo');
  });

  test('batalla real (takeshi): huida, rival solo como especie', () {
    final p = PaginaBatallas.fromJson(
      asJson({
        'total': 1,
        'pagina': 1,
        'tamano': 5,
        'items': [
          {
            'id': 1,
            'fecha': '2026-11-19T03:59:53.5237782',
            'resultado': 'Huida',
            'idPokemonRival': 25,
            'pokemon': {
              'id': 6,
              'idPokemon': 25,
              'nombre': 'pikachu',
              'urlFrontal': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
            },
          },
        ],
      }),
    );
    final b = p.filas.single;
    expect(b.resultado, ResultadoBatalla.huida);
    expect(b.fecha!.isUtc, isTrue);
    expect(b.idEspecieRival, 25);
    expect(b.pokemon.id, 6);
  });

  test('un resultado desconocido no truena', () {
    expect(ResultadoBatalla.desde('Empate'), isNull);
  });

  group('repositorio', () {
    late List<Uri> pedidas;

    TrackerRepository repo(Object? Function(Uri) cuerpo) {
      pedidas = [];
      return TrackerRepository(
        ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((req) async {
            pedidas.add(req.url);
            return http.Response.bytes(
              utf8.encode(jsonEncode(cuerpo(req.url))),
              200,
            );
          }),
          tokenProvider: () => 'tok',
          onUnauthorized: () {},
        ),
      );
    }

    test('reservados sale de /api/me/pokemon (forma real)', () async {
      final r = repo(
        (_) => [
          ...asJsonList(_fixture('ash_me_pokemon')),
          {'id': 9, 'reserved': true},
        ],
      );
      expect(await r.misReservados(), {9});
      expect(pedidas.single.path, '/api/me/pokemon');
    });

    test(
      'la mochila propia usa la ruta por usuario, no /api/Inventario',
      () async {
        final r = repo((_) => []);
        await r.mochila('yo');
        expect(pedidas.single.path, '/api/Inventario/usuario/yo');
      },
    );

    test('el filtro de batallas viaja como resultado=', () async {
      final r = repo((_) => {'total': 0, 'items': []});
      await r.batallas('x', resultado: ResultadoBatalla.derrota, pagina: 2);
      expect(pedidas.single.queryParameters, {
        'pagina': '2',
        'tamano': '20',
        'resultado': 'Derrota',
      });
    });

    test('el catálogo se pide una sola vez y sin token', () async {
      final r = repo((_) => _fixture('generation_1'));
      await r.catalogo();
      await r.catalogo();
      expect(pedidas, hasLength(1));
    });
  });
}
