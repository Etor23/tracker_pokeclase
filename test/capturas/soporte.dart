import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
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

/// Las capturas solo corren con la variable de entorno CAPTURAS.
final capturasActivas = Platform.environment.containsKey('CAPTURAS');

/// Id real de la cuenta de prueba `ash` (las fixtures son suyas).
const idAsh = 'a8b8da82-97ba-4459-b2ac-6ecb68fd4ac9';

String fixture(String nombre) =>
    File('test/fixtures/$nombre.json').readAsStringSync();

/// Backend falso que responde cada GET con el JSON de [datos]:
/// `resumen`, `pokemon`, `pokedex` y `ranking`.
MockClientHandler backendDe(Map<String, String> datos) => (req) async {
  final p = req.url.path;
  final cuerpo = p.endsWith('/resumen')
      ? datos['resumen']
      : p == '/api/tracker/usuarios'
      ? datos['ranking']
      : p.contains('/PokemonUsers/')
      ? datos['pokemon']
      : p.contains('/Pokedex/')
      ? datos['pokedex']
      : null;
  return cuerpo == null
      ? http.Response('', 404)
      : http.Response.bytes(utf8.encode(cuerpo), 200);
};

/// Abre la app con sesión iniciada, toca [irA] en la navegación, espera
/// datos, imágenes y animaciones, y compara contra el golden [archivo].
Future<void> capturar(
  WidgetTester tester, {
  required Size tamano,
  required Map<String, String> datos,
  required String sesionId,
  required String nombre,
  required String irA,
  required String archivo,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final token = fakeJwt({
    'sub': sesionId,
    'unique_name': nombre,
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
          httpClient: MockClient(backendDe(datos)),
          tokenProvider: () => session.token,
          onUnauthorized: session.expire,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(irA).first);
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

/// Carga las fuentes reales (en las pruebas Flutter usa Ahem por defecto).
Future<void> cargarFuentes() async {
  Future<void> familia(String nombre, List<String> archivos) async {
    final loader = FontLoader(nombre);
    for (final a in archivos) {
      final bytes = File(a).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await familia('Archivo', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/Archivo-$w.ttf',
  ]);
  await familia('Silkscreen', [
    'assets/fonts/Silkscreen-Regular.ttf',
    'assets/fonts/Silkscreen-Bold.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
  await familia('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

/// Sirve los sprites desde `test/fixtures/sprites/<id>.png` en lugar de la
/// red (Image.network usa dart:io HttpClient en las pruebas).
class SpritesLocales extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _Cliente();
}

class _Cliente implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Peticion(url);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Peticion implements HttpClientRequest {
  _Peticion(this.url);

  final Uri url;

  @override
  Future<HttpClientResponse> close() async {
    final archivo = File('test/fixtures/sprites/${url.pathSegments.last}');
    return _Respuesta(archivo.existsSync() ? archivo.readAsBytesSync() : null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Respuesta extends Stream<List<int>> implements HttpClientResponse {
  _Respuesta(this._bytes);

  final List<int>? _bytes;

  @override
  int get statusCode => _bytes == null ? 404 : 200;

  @override
  int get contentLength => _bytes?.length ?? 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.fromIterable([?_bytes]).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
