import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/session/jwt.dart';
import 'package:tracker/core/session/session.dart';
import 'package:tracker/core/session/session_controller.dart';
import 'package:tracker/core/session/session_store.dart';

import '../helpers.dart';

void main() {
  final ahora = DateTime.utc(2026, 11, 21, 12);

  group('JWT', () {
    test('lee el id de sub, nameid o el claim largo de .NET', () {
      for (final claim in [
        'sub',
        'nameid',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
      ]) {
        final claims = decodeJwtPayload(fakeJwt({claim: 'abc'}))!;
        expect(userIdFromClaims(claims), 'abc', reason: claim);
      }
    });

    test('token mal formado da null', () {
      expect(decodeJwtPayload('no.es-un.jwt'), isNull);
      expect(decodeJwtPayload('solo-una-parte'), isNull);
    });
  });

  group('Session.fromToken', () {
    test('usa la expiración más temprana entre login y exp', () {
      final token = tokenPrueba(expira: ahora.add(const Duration(hours: 24)));
      final s = Session.fromToken(
        token,
        expiration: ahora.add(const Duration(hours: 1)),
      )!;
      expect(s.userId, userIdPrueba);
      expect(s.userName, 'ash');
      expect(s.expiresAt, ahora.add(const Duration(hours: 1)));
    });

    test('sin id en el token da null', () {
      expect(
        Session.fromToken(fakeJwt({'exp': 9999999999}), expiration: ahora),
        isNull,
      );
    });
  });

  group('SessionController', () {
    SessionController controller(SessionStore store, {DateTime? now}) =>
        SessionController(store: store, clock: () => now ?? ahora);

    Session sesion({Duration dura = const Duration(hours: 24)}) =>
        Session.fromToken(tokenPrueba(expira: ahora.add(dura)))!;

    test('start guarda en el store y restore la recupera', () {
      final store = MemorySessionStore();
      controller(store).start(sesion());

      final nuevo = controller(store)..restore();
      expect(nuevo.isAuthenticated, isTrue);
      expect(nuevo.session!.userId, userIdPrueba);
    });

    test('restore descarta sesiones expiradas o corruptas', () {
      final store = MemorySessionStore(
        jsonEncode(sesion(dura: const Duration(minutes: -1)).toJson()),
      );
      expect((controller(store)..restore()).isAuthenticated, isFalse);
      expect(store.read(), isNull);

      final corrupto = MemorySessionStore('{no es json');
      expect((controller(corrupto)..restore()).isAuthenticated, isFalse);
      expect(corrupto.read(), isNull);
    });

    test('la sesión deja de ser válida al pasar la expiración', () {
      var reloj = ahora;
      final c = SessionController(
        store: MemorySessionStore(),
        clock: () => reloj,
      )..start(sesion(dura: const Duration(minutes: 5)));
      expect(c.token, isNotNull);
      reloj = ahora.add(const Duration(minutes: 5));
      expect(c.token, isNull);
    });

    test('expire limpia el store y avisa el motivo', () {
      final store = MemorySessionStore();
      final c = controller(store)..start(sesion());
      var avisos = 0;
      c.addListener(() => avisos++);

      c.expire();
      expect(c.isAuthenticated, isFalse);
      expect(c.ultimoMotivo, MotivoFinSesion.expirada);
      expect(store.read(), isNull);
      expect(avisos, 1);

      c.expire();
      expect(avisos, 1, reason: 'sin sesión no vuelve a notificar');
    });
  });
}
