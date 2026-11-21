import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/data/json.dart';

void main() {
  group('parseUtc', () {
    test('sin zona horaria se interpreta como UTC', () {
      final fecha = parseUtc('2026-11-21T17:40:29.123');
      expect(fecha, DateTime.utc(2026, 11, 21, 17, 40, 29, 123));
      expect(fecha!.isUtc, isTrue);
    });

    test('respeta Z y desfases explícitos', () {
      expect(
        parseUtc('2026-11-21T17:40:29Z'),
        DateTime.utc(2026, 11, 21, 17, 40, 29),
      );
      expect(
        parseUtc('2026-11-21T11:40:29-06:00'),
        DateTime.utc(2026, 11, 21, 17, 40, 29),
      );
    });

    test('valores inválidos dan null', () {
      expect(parseUtc(null), isNull);
      expect(parseUtc(''), isNull);
      expect(parseUtc('no es fecha'), isNull);
      expect(parseUtc(123), isNull);
    });
  });

  group('JsonRead', () {
    final json = asJson({
      'entero': 5,
      'decimal': 5.6,
      'texto': '7',
      'nulo': null,
      'bool': true,
      'lista': [
        {'a': 1},
        'basura',
        {'a': 2},
      ],
    });

    test('tolera tipos distintos y campos faltantes', () {
      expect(json.integer('entero'), 5);
      expect(json.integer('decimal'), 6);
      expect(json.integer('texto'), 7);
      expect(json.integer('nulo', -1), -1);
      expect(json.integer('falta'), 0);
      expect(json.doubleOrNull('texto'), 7.0);
      expect(json.string('entero'), '5');
      expect(json.stringOrNull('falta'), isNull);
      expect(json.boolean('bool'), isTrue);
      expect(json.object('falta'), isEmpty);
      expect(json.objectOrNull('nulo'), isNull);
    });

    test('las listas descartan lo que no es objeto', () {
      expect(json.objectList('lista').map((e) => e.integer('a')), [1, 2]);
      expect(json.objectList('entero'), isEmpty);
    });

    test('asJson con algo que no es mapa da mapa vacío', () {
      expect(asJson([1, 2]), isEmpty);
      expect(asJson(null), isEmpty);
    });
  });
}
