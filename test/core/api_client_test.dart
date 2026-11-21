import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tracker/core/api/api_client.dart';
import 'package:tracker/core/api/api_exception.dart';

void main() {
  late List<http.Request> peticiones;
  late int noAutorizados;
  String? token;

  ApiClient cliente(MockClientHandler responder) {
    peticiones = [];
    noAutorizados = 0;
    return ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((req) {
        peticiones.add(req);
        return responder(req);
      }),
      tokenProvider: () => token,
      onUnauthorized: () => noAutorizados++,
    );
  }

  http.Response json(Object body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json'},
  );

  setUp(() => token = 'tok');

  test('agrega el token y omite query nulos', () async {
    final api = cliente((_) async => json({'ok': true}));
    final res = await api.get(
      '/api/tracker/usuarios',
      query: {'orden': 'winrate', 'search': null, 'pagina': 2},
    );

    expect(res, {'ok': true});
    final req = peticiones.single;
    expect(req.method, 'GET');
    expect(req.headers['Authorization'], 'Bearer tok');
    expect(
      req.url.toString(),
      'https://api.test/api/tracker/usuarios?orden=winrate&pagina=2',
    );
  });

  test('las rutas públicas no mandan token', () async {
    final api = cliente((_) async => json([]));
    await api.get('/api/Estados', authenticated: false);
    expect(peticiones.single.headers.containsKey('Authorization'), isFalse);
  });

  test('lee UTF-8 aunque no venga charset', () async {
    final api = cliente(
      (_) async =>
          http.Response.bytes(utf8.encode('{"nombre":"Pokémon"}'), 200),
    );
    expect(await api.get('/x'), {'nombre': 'Pokémon'});
  });

  test('cuerpo vacío en 2xx devuelve null', () async {
    final api = cliente((_) async => http.Response('', 204));
    expect(await api.get('/x'), isNull);
  });

  test('sin token no hace la petición y avisa 401', () async {
    token = null;
    final api = cliente((_) async => json({}));
    await expectLater(api.get('/x'), throwsA(isA<UnauthorizedException>()));
    expect(peticiones, isEmpty);
    expect(noAutorizados, 1);
  });

  test('401 en ruta con token avisa a la sesión', () async {
    final api = cliente((_) async => http.Response('', 401));
    await expectLater(api.get('/x'), throwsA(isA<UnauthorizedException>()));
    expect(noAutorizados, 1);
  });

  test('401 en login es credencial incorrecta, no sesión expirada', () async {
    final api = cliente(
      (_) async => json({'message': 'Usuario o contraseña incorrectos'}, 401),
    );
    await expectLater(
      api.login('ash', 'mala'),
      throwsA(
        isA<UnauthorizedException>().having(
          (e) => e.detalle,
          'detalle',
          'Usuario o contraseña incorrectos',
        ),
      ),
    );
    expect(noAutorizados, 0);
    final req = peticiones.single;
    expect(req.method, 'POST');
    expect(req.url.path, '/api/Auth/login');
    expect(jsonDecode(req.body), {'userName': 'ash', 'password': 'mala'});
  });

  group('errores en cualquier formato', () {
    Future<ApiException> error(http.Response res) async {
      final api = cliente((_) async => res);
      try {
        await api.get('/x');
      } on ApiException catch (e) {
        return e;
      }
      fail('Debió lanzar');
    }

    test('texto plano', () async {
      final e = await error(
        http.Response.bytes(utf8.encode('Objeto no válido'), 400),
      );
      expect(
        e,
        isA<HttpStatusException>().having((e) => e.statusCode, 'status', 400),
      );
      expect(e.detalle, 'Objeto no válido');
    });

    test('ProblemDetails de validación', () async {
      final e = await error(
        json({
          'title': 'One or more validation errors occurred.',
          'errors': {},
        }, 400),
      );
      expect(e.detalle, 'One or more validation errors occurred.');
    });

    test('vacío', () async {
      final e = await error(http.Response('', 500));
      expect(e.detalle, 'HTTP 500');
    });

    test('404', () async {
      expect(await error(http.Response('', 404)), isA<NotFoundException>());
    });

    test('2xx que no es JSON', () async {
      expect(
        await error(http.Response('<html>', 200)),
        isA<InvalidResponseException>(),
      );
    });

    test('fallo de red (o CORS en web)', () async {
      final api = cliente(
        (_) async => throw http.ClientException('XMLHttpRequest error'),
      );
      await expectLater(api.get('/x'), throwsA(isA<NetworkException>()));
    });
  });
}
