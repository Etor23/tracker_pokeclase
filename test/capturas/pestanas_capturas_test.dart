// Capturas de las pestañas del perfil. Ver perfil_capturas_test.dart.
@Tags(['capturas'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'datos_demo.dart';
import 'soporte.dart';

void main() {
  setUpAll(cargarFuentes);

  // Datos reales de `ash` (2026-11-21), más el catálogo público.
  final ash = {
    'resumen': fixture('ash_resumen'),
    'pokemon': fixture('ash_pokemon'),
    'pokedex': fixture('ash_pokedex'),
    'mochila': fixture('ash_mochila'),
    'mePokemon': fixture('ash_me_pokemon'),
    'catalogo': fixture('generation_1'),
    'batallas': '{"total":0,"pagina":1,"tamano":20,"items":[]}',
    // Respuestas reales de ash: listas vacías.
    'mascotas': '[]',
    'intercambios': '[]',
  };

  final casos = [
    ('equipo_demo', 'Equipo', datosDemo, userIdPrueba, 'demo'),
    ('batallas_demo', 'Batallas', datosDemo, userIdPrueba, 'demo'),
    ('batallas_ash', 'Batallas', ash, idAsh, 'ash'),
    ('mochila_ash', 'Mochila', ash, idAsh, 'ash'),
    ('pokedex_demo', 'Pokédex', datosDemo, userIdPrueba, 'demo'),
    ('pokedex_ash', 'Pokédex', ash, idAsh, 'ash'),
    ('tamagotchi_demo', 'Tamagotchi', datosDemo, userIdPrueba, 'demo'),
    ('intercambios_demo', 'Intercambios', datosDemo, userIdPrueba, 'demo'),
    ('intercambios_ash', 'Intercambios', ash, idAsh, 'ash'),
  ];

  for (final (nombre, tamano) in [
    ('escritorio', const Size(1440, 900)),
    ('celular', const Size(390, 844)),
  ]) {
    for (final (archivo, pestana, datos, id, usuario) in casos) {
      testWidgets('$archivo ($nombre)', skip: !capturasActivas, (tester) async {
        await capturar(
          tester,
          tamano: tamano,
          datos: datos,
          sesionId: id,
          nombre: usuario,
          irA: 'Mi perfil',
          pestana: pestana,
          archivo: 'goldens/${archivo}_$nombre.png',
        );
      });
    }
  }
}
