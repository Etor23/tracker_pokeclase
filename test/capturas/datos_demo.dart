import 'dart:convert';

import '../helpers.dart';
import 'soporte.dart';

/// Perfil SINTÉTICO, solo para juzgar el diseño con más datos. No es de
/// ningún jugador real.
final datosDemo = <String, String>{
  'resumen': jsonEncode({
    'id': userIdPrueba,
    'userName': 'demo',
    'pokemon': {
      'total': 5,
      'sanos': 3,
      'afectados': 1,
      'debilitados': 1,
      'enCrianza': 1,
      'crianzaMuertos': 0,
    },
    'pokedex': {'registrados': 23, 'total': 151},
    'batallas': {'victorias': 10, 'derrotas': 6, 'huidas': 3, 'winRate': 0.625},
    'objetos': {'total': 31, 'distintos': 5},
    'intercambiosConfirmados': 2,
  }),
  'pokemon': jsonEncode([
    _poke(1, 25, 'pikachu', 'electric', null, 35, 35, 'Sano', 55, 40, 90),
    _poke(2, 4, 'Charmander', 'fire', null, 12, 39, 'Quemado', 52, 43, 65),
    _poke(3, 7, 'squirtle', 'water', null, 0, 44, 'Sano', 48, 65, 43),
    _poke(4, 1, 'bulbasaur', 'grass', 'poison', 45, 45, 'Sano', 49, 49, 45),
    _poke(5, 92, 'gastly', 'ghost', 'poison', 30, 30, 'Sano', 35, 30, 80),
  ]),
  'batallas': jsonEncode({
    'total': 19,
    'pagina': 1,
    'tamano': 20,
    'items': [
      _batalla(19, '2026-11-20T23:41:00', 'Victoria', 1, 25, 'pikachu', 19),
      _batalla(18, '2026-11-20T23:30:00', 'Derrota', 2, 4, 'Charmander', 7),
      _batalla(17, '2026-11-20T18:05:00', 'Huida', 1, 25, 'pikachu', 74),
      _batalla(16, '2026-11-19T21:12:00', 'Victoria', 5, 92, 'gastly', 16),
      _batalla(15, '2026-11-19T20:58:00', 'Victoria', 4, 1, 'bulbasaur', 10),
    ],
  }),
  'mochila': fixture('ash_mochila'),
  // Mascotas e intercambios con la forma de docs/endpoints.md (sin verificar).
  'mascotas': jsonEncode([
    {
      'id': 1,
      'idPokemonUser': 4,
      'idPokemon': 1,
      'hambre': 50,
      'energia': 70,
      'higiene': 18,
      'vidaActual': 45,
      'vidaTotal': 45,
      'estado': 'Sano',
      'vivo': true,
      'fechaAdopcion': '2026-11-15T10:00:00',
    },
    {
      'id': 2,
      'idPokemonUser': 9,
      'idPokemon': 39,
      'hambre': 0,
      'energia': 0,
      'higiene': 0,
      'vidaActual': 0,
      'vidaTotal': 115,
      'estado': 'Sano',
      'vivo': false,
      'fechaAdopcion': '2026-11-10T10:00:00',
    },
  ]),
  'intercambios': jsonEncode([
    {
      'id': 3,
      'status': 'pending',
      'role': 'received',
      'creator': {
        'id': 'id-rival',
        'userName': 'rival_demo',
        'email': 'no@mostrar.com',
      },
      'recipient': {'id': userIdPrueba, 'userName': 'demo'},
      'offeredPokemon': {'id': 30, 'idPokemon': 25, 'nombre': 'pikachu'},
      'recipientPokemon': null,
      'createdAt': '2026-11-20T18:00:00',
    },
    {
      'id': 2,
      'status': 'confirmed',
      'role': 'sent',
      'creator': {'id': userIdPrueba, 'userName': 'demo'},
      'recipient': {'id': 'id-rival', 'userName': 'rival_demo'},
      'offeredPokemon': {'id': 6, 'idPokemon': 19, 'nombre': 'rattata'},
      'recipientPokemon': {'id': 31, 'idPokemon': 133, 'nombre': 'eevee'},
      'createdAt': '2026-11-17T18:00:00',
      'acceptedAt': '2026-11-17T19:00:00',
      'confirmedAt': '2026-11-17T19:10:00',
    },
    {
      'id': 1,
      'status': 'cancelled',
      'role': 'sent',
      'creator': {'id': userIdPrueba, 'userName': 'demo'},
      'recipient': {'id': 'id-otro', 'userName': 'otro_demo'},
      'offeredPokemon': {'id': 7, 'idPokemon': 7, 'nombre': 'squirtle'},
      'recipientPokemon': null,
      'createdAt': '2026-11-12T18:00:00',
    },
  ]),
  'catalogo': fixture('generation_1'),
  'pokedex': jsonEncode({
    'registrados': 23,
    'total': 151,
    'especies': [
      for (final id in [1, 4, 7, 10, 13, 16, 19, 21, 23, 25, 27, 29, 35, 39])
        {'idPokemon': id, 'fecha': '2026-11-1${id % 9}T10:00:00'},
      for (final id in [41, 43, 54, 60, 63, 66, 74, 92, 133])
        {'idPokemon': id, 'fecha': '2026-11-15T10:00:00'},
    ],
  }),
};

Map<String, Object?> _poke(
  int id,
  int especie,
  String nombre,
  String t1,
  String? t2,
  int vida,
  int vidaTotal,
  String estado,
  int atq,
  int def,
  int vel,
) => {
  'id': id,
  'idPokemon': especie,
  'nombre': nombre,
  'fechaObtencion': '2026-11-1${id}T12:00:00',
  'origen': id == 1 ? 'Inicial' : 'Captura',
  'pokemonEstado': {
    'vidaActual': vida,
    'vidaTotal': vidaTotal,
    'estadoNombre': estado,
    'ataqueBase': atq,
    'defensaBase': def,
    'velocidadBase': vel,
    'tipoPrimario': t1,
    'tipoSecundario': t2,
    'urlFrontal':
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$especie.png',
    'urlTrasera':
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/$especie.png',
  },
  'crianza': id == 4
      ? {
          'hambre': 50,
          'energia': 70,
          'higiene': 40,
          'vivo': true,
          'fechaAdopcion': '2026-11-15T10:00:00',
        }
      : null,
};

Map<String, Object?> _batalla(
  int id,
  String fecha,
  String resultado,
  int idPokemon,
  int especie,
  String nombre,
  int rival,
) => {
  'id': id,
  'fecha': fecha,
  'resultado': resultado,
  'idPokemonRival': rival,
  'pokemon': {
    'id': idPokemon,
    'idPokemon': especie,
    'nombre': nombre,
    'urlFrontal':
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$especie.png',
  },
};
