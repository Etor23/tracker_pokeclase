import '../json.dart';

/// Una mascota de `GET /api/tamagotchi` (solo las del usuario actual).
///
/// SIN VERIFICAR contra el servidor: la forma sale de docs/endpoints.md
/// (sección Tamagotchi) porque la cuenta de prueba no tiene mascotas. Por eso
/// todo es tolerante: `estado` puede llegar como texto o como número.
class Mascota {
  const Mascota({
    required this.id,
    required this.idPokemonUser,
    required this.idEspecie,
    required this.hambre,
    required this.energia,
    required this.higiene,
    required this.vidaActual,
    required this.vidaTotal,
    required this.estado,
    required this.vivo,
    required this.fechaAdopcion,
  });

  factory Mascota.fromJson(Json json) => Mascota(
    id: json.integer('id'),
    idPokemonUser: json.intOrNull('idPokemonUser'),
    idEspecie: json.intOrNull('idPokemon'),
    hambre: json.integer('hambre'),
    energia: json.integer('energia'),
    higiene: json.integer('higiene'),
    vidaActual: json.integer('vidaActual'),
    vidaTotal: json.integer('vidaTotal'),
    estado: switch (json['estado']) {
      final String s => s,
      final num n => _estados[n.toInt()],
      _ => null,
    },
    vivo: json.boolean('vivo', true),
    fechaAdopcion: json.utcDateOrNull('fechaAdopcion'),
  );

  /// `GET /api/Estados`, verificado el 2026-11-21.
  static const _estados = {
    1: 'Sano',
    2: 'Dormido',
    3: 'Quemado',
    4: 'Envenenado',
    5: 'Paralizado',
    6: 'Confundido',
    7: 'Congelado',
  };

  /// Máximo de mascotas vivas a la vez (regla del juego).
  static const maximoVivas = 4;

  final int id;

  /// Id del Pokémon en la colección del jugador (para el detalle).
  final int? idPokemonUser;
  final int? idEspecie;

  /// 0–100; bajan 100 puntos cada 24 horas.
  final int hambre;
  final int energia;
  final int higiene;
  final int vidaActual;
  final int vidaTotal;
  final String? estado;
  final bool vivo;
  final DateTime? fechaAdopcion;
}
