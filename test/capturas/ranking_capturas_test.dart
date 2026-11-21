// Capturas del ranking. Ver el comentario de perfil_capturas_test.dart.
@Tags(['capturas'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'soporte.dart';

void main() {
  setUpAll(cargarFuentes);

  // Ranking real (orden Pokédex, 2026-11-21) visto por `ash`.
  final datos = {
    'ranking': fixture('ranking_pokedex'),
    'resumen': fixture('ash_resumen'),
  };

  for (final (nombre, tamano) in [
    ('escritorio', const Size(1440, 900)),
    ('celular', const Size(390, 844)),
  ]) {
    testWidgets('ranking ($nombre)', skip: !capturasActivas, (tester) async {
      await capturar(
        tester,
        tamano: tamano,
        datos: datos,
        sesionId: idAsh,
        nombre: 'ash',
        irA: 'Ranking',
        archivo: 'goldens/ranking_$nombre.png',
      );
    });
  }
}
