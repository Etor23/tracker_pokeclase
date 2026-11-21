import '../../core/formato.dart';
import '../../core/theme/pokemon_colores.dart';
import '../json.dart';

/// Un Pokémon de `GET /api/PokemonUsers/usuario/{id}`.
class PokemonJugador {
  const PokemonJugador({
    required this.id,
    required this.idEspecie,
    required this.nombre,
    required this.fechaObtencion,
    required this.origen,
    required this.estado,
    required this.crianza,
  });

  factory PokemonJugador.fromJson(Json json) => PokemonJugador(
    id: json.integer('id'),
    idEspecie: json.integer('idPokemon'),
    nombre: json.string('nombre'),
    fechaObtencion: json.utcDateOrNull('fechaObtencion'),
    origen: json.stringOrNull('origen'),
    estado: EstadoPokemon.fromJson(json.object('pokemonEstado')),
    crianza: switch (json.objectOrNull('crianza')) {
      final c? => Crianza.fromJson(c),
      null => null,
    },
  );

  /// Id de este Pokémon del jugador (para `/usuario/:id/pokemon/:id`).
  final int id;

  /// Número de especie (183 = Marill).
  final int idEspecie;
  final String nombre;
  final DateTime? fechaObtencion;

  /// `Inicial`, `Captura` o `Intercambio`. `Desconocido` (anterior a la
  /// migración) se vuelve `null` para no mostrarlo.
  final String? origen;
  final EstadoPokemon estado;
  final Crianza? crianza;

  String? get origenVisible => origen == 'Desconocido' ? null : origen;

  Salud get salud {
    if (estado.vidaActual == 0) return Salud.debilitado;
    if (estado.estadoNombre != null && estado.estadoNombre != 'Sano') {
      return Salud.afectado;
    }
    return Salud.sano;
  }

  bool get crianzaMuerta => crianza?.vivo == false;

  /// Sprite frontal; si el backend no lo manda, el de PokeAPI por especie.
  String get sprite => estado.urlFrontal ?? urlSpriteEspecie(idEspecie);
}

class EstadoPokemon {
  const EstadoPokemon({
    required this.vidaActual,
    required this.vidaTotal,
    required this.estadoNombre,
    required this.ataqueBase,
    required this.defensaBase,
    required this.velocidadBase,
    required this.tipoPrimario,
    required this.tipoSecundario,
    required this.urlFrontal,
  });

  factory EstadoPokemon.fromJson(Json json) => EstadoPokemon(
    vidaActual: json.integer('vidaActual'),
    vidaTotal: json.integer('vidaTotal'),
    estadoNombre: json.stringOrNull('estadoNombre'),
    ataqueBase: json.integer('ataqueBase'),
    defensaBase: json.integer('defensaBase'),
    velocidadBase: json.integer('velocidadBase'),
    tipoPrimario: json.stringOrNull('tipoPrimario'),
    tipoSecundario: json.stringOrNull('tipoSecundario'),
    urlFrontal: json.stringOrNull('urlFrontal'),
  );

  final int vidaActual;
  final int vidaTotal;
  final String? estadoNombre;
  final int ataqueBase;
  final int defensaBase;
  final int velocidadBase;
  final String? tipoPrimario;
  final String? tipoSecundario;
  final String? urlFrontal;

  List<String> get tipos => [?tipoPrimario, ?tipoSecundario];
}

class Crianza {
  const Crianza({
    required this.hambre,
    required this.energia,
    required this.higiene,
    required this.vivo,
  });

  factory Crianza.fromJson(Json json) => Crianza(
    hambre: json.integer('hambre'),
    energia: json.integer('energia'),
    higiene: json.integer('higiene'),
    vivo: json.boolean('vivo', true),
  );

  final int hambre;
  final int energia;
  final int higiene;
  final bool vivo;
}
