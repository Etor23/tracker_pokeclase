import '../json.dart';

/// SIN VERIFICAR contra el servidor: la forma sale de docs/endpoints.md
/// (sección Intercambios) porque la cuenta de prueba no tiene intercambios.
/// De `creator` y `recipient` solo se leen `id` y `userName`: nunca un email.

enum EstadoIntercambio {
  pending('pending', 'Pendiente', 'Pendientes'),
  accepted('accepted', 'Aceptado', 'Aceptados'),
  confirmed('confirmed', 'Confirmado', 'Confirmados'),
  cancelled('cancelled', 'Cancelado', 'Cancelados'),
  rejected('rejected', 'Rechazado', 'Rechazados');

  const EstadoIntercambio(this.valor, this.etiqueta, this.plural);

  /// Valor del backend (también el filtro `?status=`).
  final String valor;
  final String etiqueta;
  final String plural;

  static EstadoIntercambio? desde(String? v) =>
      values.where((e) => e.valor == v?.toLowerCase()).firstOrNull;
}

/// Un intercambio de `GET /api/me/trades`.
class Intercambio {
  const Intercambio({
    required this.id,
    required this.estado,
    required this.enviado,
    required this.creador,
    required this.destinatario,
    required this.ofrecido,
    required this.aCambio,
    required this.creado,
    required this.aceptado,
    required this.confirmado,
  });

  factory Intercambio.fromJson(Json json) => Intercambio(
    id: json.integer('id'),
    estado: EstadoIntercambio.desde(json.stringOrNull('status')),
    enviado: json.stringOrNull('role') == 'sent',
    creador: Participante.fromJson(json.object('creator')),
    destinatario: Participante.fromJson(json.object('recipient')),
    ofrecido: PokemonIntercambio.fromJsonOrNull(
      json.objectOrNull('offeredPokemon'),
    ),
    aCambio: PokemonIntercambio.fromJsonOrNull(
      json.objectOrNull('recipientPokemon'),
    ),
    creado: json.utcDateOrNull('createdAt'),
    aceptado: json.utcDateOrNull('acceptedAt'),
    confirmado: json.utcDateOrNull('confirmedAt'),
  );

  final int id;

  /// `null` si llega un estado desconocido.
  final EstadoIntercambio? estado;

  /// `role == sent`: lo creé yo. Si no, me lo enviaron.
  final bool enviado;
  final Participante creador;
  final Participante destinatario;

  /// El Pokémon que ofrece el creador.
  final PokemonIntercambio? ofrecido;

  /// El que da el destinatario al aceptar (null mientras esté pendiente).
  final PokemonIntercambio? aCambio;
  final DateTime? creado;
  final DateTime? aceptado;
  final DateTime? confirmado;

  /// El otro jugador desde mi punto de vista.
  Participante get otro => enviado ? destinatario : creador;
}

class Participante {
  const Participante({required this.id, required this.userName});

  factory Participante.fromJson(Json json) => Participante(
    id: json.stringOrNull('id'),
    userName: json.stringOrNull('userName') ?? json.stringOrNull('nombre'),
  );

  final String? id;
  final String? userName;
}

class PokemonIntercambio {
  const PokemonIntercambio({
    required this.id,
    required this.idEspecie,
    required this.nombre,
    required this.urlFrontal,
  });

  /// Acepta `idPokemon` o `idEspecie` y lee el sprite de `pokemonEstado` si
  /// viene anidado como en la colección.
  static PokemonIntercambio? fromJsonOrNull(Json? json) {
    if (json == null) return null;
    final estado = json.object('pokemonEstado');
    return PokemonIntercambio(
      id: json.intOrNull('id'),
      idEspecie: json.intOrNull('idPokemon') ?? json.intOrNull('idEspecie'),
      nombre: json.stringOrNull('nombre'),
      urlFrontal:
          json.stringOrNull('urlFrontal') ?? estado.stringOrNull('urlFrontal'),
    );
  }

  final int? id;
  final int? idEspecie;
  final String? nombre;
  final String? urlFrontal;
}
