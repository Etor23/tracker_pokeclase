// Capturas de pantalla del perfil (regresión visual). No corren con
// `flutter test` normal porque el renderizado de fuentes cambia entre sistemas
// operativos. Para generarlas o compararlas:
//
//   CAPTURAS=1 flutter test test/capturas --update-goldens   (generar)
//   CAPTURAS=1 flutter test test/capturas                    (comparar)
@Tags(['capturas'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'datos_demo.dart';
import 'soporte.dart';

void main() {
  setUpAll(cargarFuentes);

  final reales = {
    'resumen': fixture('ash_resumen'),
    'pokemon': fixture('ash_pokemon'),
    'pokedex': fixture('ash_pokedex'),
  };

  for (final (nombre, tamano) in [
    ('escritorio', const Size(1440, 900)),
    ('celular', const Size(390, 844)),
  ]) {
    testWidgets('perfil de ash ($nombre)', skip: !capturasActivas, (
      tester,
    ) async {
      await capturar(
        tester,
        tamano: tamano,
        datos: reales,
        sesionId: idAsh,
        nombre: 'ash',
        irA: 'Mi perfil',
        archivo: 'goldens/perfil_ash_$nombre.png',
      );
    });

    testWidgets('perfil sintético ($nombre)', skip: !capturasActivas, (
      tester,
    ) async {
      await capturar(
        tester,
        tamano: tamano,
        datos: datosDemo,
        sesionId: userIdPrueba,
        nombre: 'demo',
        irA: 'Mi perfil',
        archivo: 'goldens/perfil_demo_$nombre.png',
      );
    });
  }
}
