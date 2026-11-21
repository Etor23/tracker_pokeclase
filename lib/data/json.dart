/// Lectores tolerantes para los `fromJson` de los modelos.
///
/// Un campo faltante, nulo o de otro tipo nunca lanza: se usa el valor por
/// defecto o `null`. Así un cambio del backend no truena la app.
library;

typedef Json = Map<String, Object?>;

/// Convierte cualquier valor en mapa; lo que no sea mapa da un mapa vacío.
Json asJson(Object? value) =>
    value is Map ? value.map((k, v) => MapEntry('$k', v)) : const {};

/// Convierte en lista de mapas, descartando lo que no sea mapa.
List<Json> asJsonList(Object? value) => value is List
    ? [
        for (final item in value)
          if (item is Map) asJson(item),
      ]
    : const [];

extension JsonRead on Json {
  String? stringOrNull(String key) => switch (this[key]) {
    final String s => s,
    final num n => '$n',
    _ => null,
  };

  String string(String key, [String fallback = '']) =>
      stringOrNull(key) ?? fallback;

  int? intOrNull(String key) => switch (this[key]) {
    final int i => i,
    final num n => n.round(),
    final String s => int.tryParse(s) ?? double.tryParse(s)?.round(),
    _ => null,
  };

  int integer(String key, [int fallback = 0]) => intOrNull(key) ?? fallback;

  double? doubleOrNull(String key) => switch (this[key]) {
    final num n => n.toDouble(),
    final String s => double.tryParse(s),
    _ => null,
  };

  bool? boolOrNull(String key) => switch (this[key]) {
    final bool b => b,
    'true' => true,
    'false' => false,
    _ => null,
  };

  bool boolean(String key, [bool fallback = false]) =>
      boolOrNull(key) ?? fallback;

  DateTime? utcDateOrNull(String key) => parseUtc(this[key]);

  Json object(String key) => asJson(this[key]);

  Json? objectOrNull(String key) => this[key] is Map ? asJson(this[key]) : null;

  List<Json> objectList(String key) => asJsonList(this[key]);
}

final _zonaHoraria = RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false);

/// El backend genera fechas en UTC pero a veces sin `Z`. Siempre se
/// interpretan como UTC; convertir con `.toLocal()` solo al mostrarlas.
DateTime? parseUtc(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  final text = value.trim();
  final normalizado = _zonaHoraria.hasMatch(text) ? text : '${text}Z';
  return DateTime.tryParse(normalizado)?.toUtc();
}
