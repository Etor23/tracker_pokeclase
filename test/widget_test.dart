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

import 'helpers.dart';

void main() {
  final enUnDia = DateTime.now().toUtc().add(const Duration(days: 1));

  /// Responde el login con un token válido y los GET del perfil con las
  /// respuestas reales guardadas en test/fixtures.
  Future<http.Response> backendReal(http.Request req) async {
    if (req.method == 'POST') {
      return http.Response(
        jsonEncode({
          'token': tokenPrueba(expira: enUnDia),
          'expiration': enUnDia.toIso8601String(),
        }),
        200,
      );
    }
    final p = req.url.path;
    final fixture = p.endsWith('/resumen')
        ? 'ash_resumen'
        : p.contains('/PokemonUsers/')
        ? 'ash_pokemon'
        : p.contains('/Pokedex/')
        ? 'ash_pokedex'
        : null;
    if (fixture == null) return http.Response('', 404);
    return http.Response.bytes(
      File('test/fixtures/$fixture.json').readAsBytesSync(),
      200,
    );
  }

  Widget app(SessionController session, {MockClientHandler? backend}) =>
      TrackerApp(
        session: session,
        api: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient(
            backend ?? (_) async => http.Response('', 404),
          ),
          tokenProvider: () => session.token,
          onUnauthorized: session.expire,
        ),
      );

  testWidgets('sin sesión muestra el login', (tester) async {
    await tester.pumpWidget(
      app(SessionController(store: MemorySessionStore())),
    );
    await tester.pumpAndSettle();
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('con sesión guardada entra directo a Mi perfil', (tester) async {
    final store = MemorySessionStore(
      jsonEncode(Session.fromToken(tokenPrueba(expira: enUnDia))!.toJson()),
    );
    await tester.pumpWidget(
      app(SessionController(store: store)..restore(), backend: backendReal),
    );
    await tester.pumpAndSettle();
    expect(find.text('REGISTRADAS EN LA POKÉDEX'), findsOneWidget);
    expect(find.text('Marill'), findsOneWidget);
  });

  testWidgets(
    'login correcto entra a Mi perfil; cerrar sesión regresa al login',
    (tester) async {
      final session = SessionController(store: MemorySessionStore());
      await tester.pumpWidget(app(session, backend: backendReal));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'ash');
      await tester.enterText(find.byType(TextFormField).at(1), 'Pikachu123!');
      await tester.tap(find.text('ENTRAR'));
      await tester.pumpAndSettle();

      expect(session.session?.userId, userIdPrueba);
      expect(find.text('REGISTRADAS EN LA POKÉDEX'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('ENTRAR'), findsOneWidget);
    },
  );

  testWidgets('credenciales incorrectas muestran el error', (tester) async {
    await tester.pumpWidget(
      app(
        SessionController(store: MemorySessionStore()),
        backend: (_) async => http.Response(
          jsonEncode({'message': 'Usuario o contraseña incorrectos'}),
          401,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'ash');
    await tester.enterText(find.byType(TextFormField).at(1), 'mala');
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });
}
