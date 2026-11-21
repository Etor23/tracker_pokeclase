import 'dart:convert';

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
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('con sesión guardada entra directo al ranking', (tester) async {
    final store = MemorySessionStore(
      jsonEncode(Session.fromToken(tokenPrueba(expira: enUnDia))!.toJson()),
    );
    await tester.pumpWidget(app(SessionController(store: store)..restore()));
    await tester.pumpAndSettle();
    expect(find.text('Pantalla pendiente: Ranking'), findsOneWidget);
  });

  testWidgets('login correcto entra; cerrar sesión regresa al login', (
    tester,
  ) async {
    final session = SessionController(store: MemorySessionStore());
    await tester.pumpWidget(
      app(
        session,
        backend: (req) async => http.Response(
          jsonEncode({
            'token': tokenPrueba(expira: enUnDia),
            'expiration': enUnDia.toIso8601String(),
          }),
          200,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'ash');
    await tester.enterText(find.byType(TextFormField).at(1), 'Pikachu123!');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(session.session?.userId, userIdPrueba);
    expect(find.text('Pantalla pendiente: Ranking'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

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
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });
}
