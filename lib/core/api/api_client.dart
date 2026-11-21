import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Cliente HTTP único del tracker.
///
/// Solo expone [get] y [login]: el tracker es de solo lectura y el login es el
/// único POST permitido. No agregar métodos de escritura.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required http.Client httpClient,
    required this._tokenProvider,
    required this._onUnauthorized,
    this.timeout = const Duration(seconds: 20),
  }) : _baseUri = Uri.parse(baseUrl),
       _http = httpClient;

  final Uri _baseUri;
  final http.Client _http;
  final String? Function() _tokenProvider;
  final void Function() _onUnauthorized;
  final Duration timeout;

  /// GET a [path] (por ejemplo `/api/tracker/usuarios`). Los valores nulos de
  /// [query] se omiten. Devuelve el JSON decodificado, o `null` si el cuerpo
  /// viene vacío.
  ///
  /// Con [authenticated] en `false` no se envía el token (catálogos públicos).
  Future<Object?> get(
    String path, {
    Map<String, Object?> query = const {},
    bool authenticated = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (authenticated) {
      final token = _tokenProvider();
      if (token == null) {
        _onUnauthorized();
        throw const UnauthorizedException('No hay sesión activa');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return _send(
      () => _http.get(_uri(path, query), headers: headers),
      authenticated: authenticated,
    );
  }

  /// `POST /api/Auth/login`. Devuelve `{ token, expiration }`.
  /// Un 401 aquí significa credenciales incorrectas, no sesión expirada.
  Future<Object?> login(String userName, String password) => _send(
    () => _http.post(
      _uri('/api/Auth/login', const {}),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userName': userName, 'password': password}),
    ),
    authenticated: false,
  );

  Uri _uri(String path, Map<String, Object?> query) {
    final params = {
      for (final MapEntry(:key, :value) in query.entries)
        if (value != null) key: '$value',
    };
    return _baseUri.replace(
      path: '${_baseUri.path}$path'.replaceAll('//', '/'),
      queryParameters: params.isEmpty ? null : params,
    );
  }

  Future<Object?> _send(
    Future<http.Response> Function() request, {
    required bool authenticated,
  }) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw const NetworkException('Tiempo de espera agotado');
    } on http.ClientException catch (e) {
      // En Flutter web un bloqueo de CORS también llega aquí.
      throw NetworkException(e.message);
    }

    // El backend no siempre manda charset; leer siempre como UTF-8.
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (body.trim().isEmpty) return null;
      try {
        return jsonDecode(body);
      } on FormatException {
        throw InvalidResponseException(
          'Respuesta no es JSON: ${_recortar(body)}',
        );
      }
    }

    final detalle = _mensajeDeError(body, status);
    switch (status) {
      case 401:
        if (authenticated) _onUnauthorized();
        throw UnauthorizedException(detalle);
      case 404:
        throw NotFoundException(detalle);
      default:
        throw HttpStatusException(status, detalle);
    }
  }

  /// Los errores pueden ser texto plano, JSON (`message`, o ProblemDetails con
  /// `title`/`detail`) o venir vacíos.
  static String _mensajeDeError(String body, int status) {
    if (body.trim().isEmpty) return 'HTTP $status';
    try {
      final json = jsonDecode(body);
      if (json is String) return json;
      if (json is Map) {
        for (final key in ['message', 'detail', 'title']) {
          final value = json[key];
          if (value is String && value.isNotEmpty) return value;
        }
      }
    } on FormatException {
      // Texto plano.
    }
    return _recortar(body);
  }

  static String _recortar(String text) =>
      text.length <= 300 ? text : '${text.substring(0, 300)}…';
}
