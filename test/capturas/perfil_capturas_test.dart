// Capturas de pantalla del perfil (regresión visual). No corren con
// `flutter test` normal porque el renderizado de fuentes cambia entre sistemas
// operativos. Para generarlas o compararlas:
//
//   CAPTURAS=1 flutter test test/capturas --update-goldens   (generar)
//   CAPTURAS=1 flutter test test/capturas                    (comparar)
@Tags(['capturas'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracker/app.dart';
import 'package:tracker/core/api/api_client.dart';
import 'package:tracker/core/session/session.dart';
import 'package:tracker/core/session/session_controller.dart';
import 'package:tracker/core/session/session_store.dart';

import '../helpers.dart';
import 'soporte.dart';

final _activas = Platform.environment.containsKey('CAPTURAS');

const _idAsh = 'a8b8da82-97ba-4459-b2ac-6ecb68fd4ac9';

String _fixture(String nombre) =>
    File('test/fixtures/$nombre.json').readAsStringSync();

/// Perfil SINTÉTICO, solo para juzgar el diseño con más datos. No es de
/// ningún jugador real.
final _demo = {
  'resumen': jsonEncode({
    'id': userIdPrueba,
    'userName': 'demo',
    'pokemon': {
      'total': 5,
      'sanos': 3,
      'afectados': 1,
      'debilitados': 1,
      'enCrianza': 1,
      'crianzaMuertos': 0,
    },
    'pokedex': {'registrados': 23, 'total': 151},
    'batallas': {'victorias': 10, 'derrotas': 6, 'huidas': 3, 'winRate': 0.625},
    'objetos': {'total': 31, 'distintos': 5},
    'intercambiosConfirmados': 2,
  }),
  'pokemon': jsonEncode([
    _poke(1, 25, 'pikachu', 'electric', null, 35, 35, 'Sano', 55, 40, 90),
    _poke(2, 4, 'Charmander', 'fire', null, 12, 39, 'Quemado', 52, 43, 65),
    _poke(3, 7, 'squirtle', 'water', null, 0, 44, 'Sano', 48, 65, 43),
    _poke(4, 1, 'bulbasaur', 'grass', 'poison', 45, 45, 'Sano', 49, 49, 45),
    _poke(5, 92, 'gastly', 'ghost', 'poison', 30, 30, 'Sano', 35, 30, 80),
  ]),
  'pokedex': jsonEncode({
    'registrados': 23,
    'total': 151,
    'especies': [
      for (final id in [1, 4, 7, 10, 13, 16, 19, 21, 23, 25, 27, 29, 35, 39])
        {'idPokemon': id, 'fecha': '2026-11-1${id % 9}T10:00:00'},
      for (final id in [41, 43, 54, 60, 63, 66, 74, 92, 133])
        {'idPokemon': id, 'fecha': '2026-11-15T10:00:00'},
    ],
  }),
};

Map<String, Object?> _poke(
  int id,
  int especie,
  String nombre,
  String t1,
  String? t2,
  int vida,
  int vidaTotal,
  String estado,
  int atq,
  int def,
  int vel,
) => {
  'id': id,
  'idPokemon': especie,
  'nombre': nombre,
  'fechaObtencion': '2026-11-1${id}T12:00:00',
  'origen': id == 1 ? 'Inicial' : 'Captura',
  'pokemonEstado': {
    'vidaActual': vida,
    'vidaTotal': vidaTotal,
    'estadoNombre': estado,
    'ataqueBase': atq,
    'defensaBase': def,
    'velocidadBase': vel,
    'tipoPrimario': t1,
    'tipoSecundario': t2,
    'urlFrontal':
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$especie.png',
  },
  'crianza': id == 4
      ? {'hambre': 50, 'energia': 70, 'higiene': 40, 'vivo': true}
      : null,
};

MockClientHandler _backend(Map<String, String> datos) => (req) async {
  final p = req.url.path;
  final cuerpo = p.endsWith('/resumen')
      ? datos['resumen']
      : p.contains('/PokemonUsers/')
      ? datos['pokemon']
      : p.contains('/Pokedex/')
      ? datos['pokedex']
      : null;
  return cuerpo == null
      ? http.Response('', 404)
      : http.Response.bytes(utf8.encode(cuerpo), 200);
};

Future<void> _capturar(
  WidgetTester tester, {
  required Size tamano,
  required Map<String, String> datos,
  required String sesionId,
  required String archivo,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final token = fakeJwt({
    'sub': sesionId,
    'unique_name': sesionId == _idAsh ? 'ash' : 'demo',
    'exp':
        DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch ~/
        1000,
  });
  final session = SessionController(store: MemorySessionStore())
    ..start(Session.fromToken(token)!);

  await HttpOverrides.runZoned(() async {
    await tester.pumpWidget(
      TrackerApp(
        session: session,
        api: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient(_backend(datos)),
          tokenProvider: () => session.token,
          onUnauthorized: session.expire,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Ir a /yo y esperar datos, imágenes y el barrido de la Pokédex.
    await tester.tap(find.text('Mi perfil').first);
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    for (final e in find.byType(Image).evaluate()) {
      await tester.runAsync(() => precacheImage((e.widget as Image).image, e));
    }
    await tester.pumpAndSettle();
  }, createHttpClient: SpritesLocales().createHttpClient);

  await expectLater(find.byType(TrackerApp), matchesGoldenFile(archivo));
}

void main() {
  setUpAll(cargarFuentes);

  final reales = {
    'resumen': _fixture('ash_resumen'),
    'pokemon': _fixture('ash_pokemon'),
    'pokedex': _fixture('ash_pokedex'),
  };

  for (final (nombre, tamano) in [
    ('escritorio', const Size(1440, 900)),
    ('celular', const Size(390, 844)),
  ]) {
    testWidgets('perfil de ash ($nombre)', skip: !_activas, (tester) async {
      await _capturar(
        tester,
        tamano: tamano,
        datos: reales,
        sesionId: _idAsh,
        archivo: 'goldens/perfil_ash_$nombre.png',
      );
    });

    testWidgets('perfil sintético ($nombre)', skip: !_activas, (tester) async {
      await _capturar(
        tester,
        tamano: tamano,
        datos: _demo,
        sesionId: userIdPrueba,
        archivo: 'goldens/perfil_demo_$nombre.png',
      );
    });
  }
}
