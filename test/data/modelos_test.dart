import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/formato.dart';
import 'package:tracker/core/theme/pokemon_colores.dart';
import 'package:tracker/data/json.dart';
import 'package:tracker/data/models/pokedex_jugador.dart';
import 'package:tracker/data/models/pokemon_jugador.dart';
import 'package:tracker/data/models/resumen_jugador.dart';

/// Respuestas reales del servidor (cuenta de prueba `ash`, 2026-11-21).
Object? _fixture(String nombre) =>
    jsonDecode(File('test/fixtures/$nombre.json').readAsStringSync());

void main() {
  test('resumen real', () {
    final r = ResumenJugador.fromJson(asJson(_fixture('ash_resumen')));
    expect(r.userName, 'ash');
    expect(r.pokemon.total, 1);
    expect(r.pokedex.registrados, 1);
    expect(r.pokedex.total, 151);
    expect(r.batallas.winRate, isNull);
    expect(r.batallas.total, 0);
    expect(r.objetosTotal, 14);
    expect(r.objetosDistintos, 3);
  });

  test('pokémon real: fecha sin Z como UTC y sprite del backend', () {
    final lista = asJsonList(_fixture('ash_pokemon'))
        .map(PokemonJugador.fromJson)
        .toList();
    final marill = lista.single;
    expect(marill.idEspecie, 183);
    expect(
      marill.fechaObtencion,
      DateTime.utc(2026, 11, 13, 5, 38, 43, 306, 668),
    );
    expect(marill.origenVisible, 'Captura');
    expect(marill.estado.tipos, ['water', 'fairy']);
    expect(marill.salud, Salud.sano);
    expect(marill.sprite, endsWith('/183.png'));
    expect(marill.crianza, isNull);
  });

  test('pokédex real: especie fuera de la Gen 1', () {
    final p = PokedexJugador.fromJson(asJson(_fixture('ash_pokedex')));
    expect(p.registrados, 1);
    expect(p.registrada(183), isTrue);
    expect(p.registrada(1), isFalse);
    expect(p.fueraDeLaGeneracion, [183]);
  });

  group('salud y origen', () {
    PokemonJugador poke({
      int vida = 10,
      String estado = 'Sano',
      String origen = 'Captura',
      bool? vivo,
    }) => PokemonJugador.fromJson(
      asJson({
        'id': 1,
        'idPokemon': 25,
        'nombre': 'pikachu',
        'origen': origen,
        'pokemonEstado': {
          'vidaActual': vida,
          'vidaTotal': 35,
          'estadoNombre': estado,
        },
        'crianza': vivo == null ? null : {'vivo': vivo},
      }),
    );

    test('vida 0 es debilitado aunque el estado diga Sano', () {
      expect(poke(vida: 0).salud, Salud.debilitado);
    });

    test('un estado distinto de Sano es afectado', () {
      expect(poke(estado: 'Paralizado').salud, Salud.afectado);
    });

    test('origen Desconocido no se muestra', () {
      expect(poke(origen: 'Desconocido').origenVisible, isNull);
    });

    test('crianza muerta', () {
      expect(poke(vivo: false).crianzaMuerta, isTrue);
      expect(poke(vivo: true).crianzaMuerta, isFalse);
      expect(poke().crianzaMuerta, isFalse);
    });

    test('sin urlFrontal usa el sprite de PokeAPI por especie', () {
      expect(poke().sprite, endsWith('/sprites/pokemon/25.png'));
    });
  });

  group('formato', () {
    test('porcentaje nunca muestra 0 % cuando es null', () {
      expect(porcentaje(null), '—');
      expect(porcentaje(0.625), '62.5 %');
      expect(porcentaje(0.5, pegado: true), '50%');
      expect(porcentaje(0), '0 %');
    });

    test('nombres', () {
      expect(capitalizar('marill'), 'Marill');
      expect(nombreDeObjeto('poke-ball'), 'Poke Ball');
      expect(numeroEspecie(7), '007');
    });

    test('tipos en español y desconocidos tal cual', () {
      expect(TiposPokemon.nombre('water'), 'Agua');
      expect(TiposPokemon.nombre('Fire'), 'Fuego');
      expect(TiposPokemon.nombre('shadow'), 'shadow');
    });
  });
}
