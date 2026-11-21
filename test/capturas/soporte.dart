import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

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
