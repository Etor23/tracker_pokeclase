// Tamagotchi e Intercambios: la forma sale de docs/endpoints.md porque la
// cuenta de prueba no tiene datos. Estas pruebas fijan la tolerancia.
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/data/json.dart';
import 'package:tracker/data/models/intercambio.dart';
import 'package:tracker/data/models/mascota.dart';

void main() {
  group('Mascota', () {
    test('campos de la guía', () {
      final m = Mascota.fromJson(
        asJson({
          'id': 1,
          'idPokemonUser': 4,
          'idPokemon': 1,
          'hambre': 50,
          'energia': 70,
          'higiene': 18,
          'vidaActual': 45,
          'vidaTotal': 45,
          'estado': 'Dormido',
          'vivo': true,
          'fechaAdopcion': '2026-11-15T10:00:00',
        }),
      );
      expect(m.idPokemonUser, 4);
      expect(m.estado, 'Dormido');
      expect(m.fechaAdopcion, DateTime.utc(2026, 11, 15, 10));
    });

    test('estado como número usa la tabla de /api/Estados', () {
      expect(Mascota.fromJson(asJson({'estado': 2})).estado, 'Dormido');
      expect(Mascota.fromJson(asJson({'estado': 99})).estado, isNull);
    });

    test('un objeto vacío no truena', () {
      final m = Mascota.fromJson(const {});
      expect(m.vivo, isTrue);
      expect(m.idEspecie, isNull);
    });
  });

  group('Intercambio', () {
    test('desde mi lado: enviado → el otro es el destinatario', () {
      final i = Intercambio.fromJson(
        asJson({
          'id': 2,
          'status': 'confirmed',
          'role': 'sent',
          'creator': {'id': 'yo', 'userName': 'ash'},
          'recipient': {'id': 'r', 'userName': 'rival', 'email': 'x@y.com'},
          'offeredPokemon': {'id': 6, 'idPokemon': 19, 'nombre': 'rattata'},
          'recipientPokemon': {
            'id': 31,
            'idPokemon': 133,
            'pokemonEstado': {'urlFrontal': 'https://x/133.png'},
          },
          'createdAt': '2026-11-17T18:00:00',
        }),
      );
      expect(i.estado, EstadoIntercambio.confirmed);
      expect(i.enviado, isTrue);
      expect(i.otro.userName, 'rival');
      expect(i.aCambio!.urlFrontal, 'https://x/133.png');
      expect(i.creado!.isUtc, isTrue);
    });

    test('nunca guarda el email de un participante', () {
      final p = Participante.fromJson(
        asJson({'id': 'r', 'userName': 'rival', 'email': 'x@y.com'}),
      );
      expect(p.userName, 'rival');
      // Participante solo tiene id y userName.
      expect('${p.id}${p.userName}', isNot(contains('@')));
    });

    test('pendiente sin Pokémon a cambio y estado desconocido', () {
      final i = Intercambio.fromJson(
        asJson({
          'status': 'Raro',
          'role': 'received',
          'recipientPokemon': null,
        }),
      );
      expect(i.estado, isNull);
      expect(i.enviado, isFalse);
      expect(i.aCambio, isNull);
    });

    test('el estado no distingue mayúsculas', () {
      expect(EstadoIntercambio.desde('Pending'), EstadoIntercambio.pending);
    });
  });
}
