// Capturas del detalle de un Pokémon. Ver perfil_capturas_test.dart.
@Tags(['capturas'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'datos_demo.dart';
import 'soporte.dart';

void main() {
  setUpAll(cargarFuentes);

  final ash = {
    'resumen': fixture('ash_resumen'),
    'pokemon': fixture('ash_pokemon'),
    'pokedex': fixture('ash_pokedex'),
  };

  for (final (nombre, tamano) in [
    ('escritorio', const Size(1440, 900)),
    ('celular', const Size(390, 844)),
  ]) {
    // Marill real de ash (id 1).
    testWidgets('detalle de Marill ($nombre)', skip: !capturasActivas, (
      tester,
    ) async {
      await capturar(
        tester,
        tamano: tamano,
        datos: ash,
        sesionId: idAsh,
        nombre: 'ash',
        ruta: '/usuario/$idAsh/pokemon/1',
        archivo: 'goldens/detalle_marill_$nombre.png',
      );
    });

    // Bulbasaur sintético con crianza (id 4).
    testWidgets('detalle con crianza ($nombre)', skip: !capturasActivas, (
      tester,
    ) async {
      await capturar(
        tester,
        tamano: tamano,
        datos: datosDemo,
        sesionId: userIdPrueba,
        nombre: 'demo',
        ruta: '/usuario/$userIdPrueba/pokemon/4',
        archivo: 'goldens/detalle_crianza_$nombre.png',
      );
    });
  }
}
