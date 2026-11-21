import '../json.dart';

/// `GET /api/tracker/usuarios/{id}/resumen`.
class ResumenJugador {
  const ResumenJugador({
    required this.id,
    required this.userName,
    required this.pokemon,
    required this.pokedex,
    required this.batallas,
    required this.objetosTotal,
    required this.objetosDistintos,
    required this.intercambiosConfirmados,
  });

  factory ResumenJugador.fromJson(Json json) {
    final pokemon = json.object('pokemon');
    final pokedex = json.object('pokedex');
    final batallas = json.object('batallas');
    final objetos = json.object('objetos');
    return ResumenJugador(
      id: json.string('id'),
      userName: json.string('userName'),
      pokemon: ConteoPokemon(
        total: pokemon.integer('total'),
        sanos: pokemon.integer('sanos'),
        afectados: pokemon.integer('afectados'),
        debilitados: pokemon.integer('debilitados'),
        enCrianza: pokemon.integer('enCrianza'),
        crianzaMuertos: pokemon.integer('crianzaMuertos'),
      ),
      pokedex: ConteoPokedex(
        registrados: pokedex.integer('registrados'),
        total: pokedex.integer('total'),
      ),
      batallas: ConteoBatallas(
        victorias: batallas.integer('victorias'),
        derrotas: batallas.integer('derrotas'),
        huidas: batallas.integer('huidas'),
        winRate: batallas.doubleOrNull('winRate'),
      ),
      objetosTotal: objetos.integer('total'),
      objetosDistintos: objetos.integer('distintos'),
      intercambiosConfirmados: json.integer('intercambiosConfirmados'),
    );
  }

  final String id;
  final String userName;
  final ConteoPokemon pokemon;
  final ConteoPokedex pokedex;
  final ConteoBatallas batallas;
  final int objetosTotal;
  final int objetosDistintos;
  final int intercambiosConfirmados;
}

class ConteoPokemon {
  const ConteoPokemon({
    required this.total,
    required this.sanos,
    required this.afectados,
    required this.debilitados,
    required this.enCrianza,
    required this.crianzaMuertos,
  });

  final int total;
  final int sanos;
  final int afectados;
  final int debilitados;
  final int enCrianza;
  final int crianzaMuertos;
}

class ConteoPokedex {
  const ConteoPokedex({required this.registrados, required this.total});

  final int registrados;

  /// Lo da el backend (151 para la Gen 1); nunca escribirlo fijo.
  final int total;
}

class ConteoBatallas {
  const ConteoBatallas({
    required this.victorias,
    required this.derrotas,
    required this.huidas,
    required this.winRate,
  });

  final int victorias;
  final int derrotas;
  final int huidas;

  /// Fracción 0–1; `null` si no hay victorias ni derrotas (mostrar "—").
  final double? winRate;

  int get total => victorias + derrotas + huidas;
}
