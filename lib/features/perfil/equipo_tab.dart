import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/theme/pokemon_colores.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/nota_vacia.dart';
import 'lamina_pokemon.dart';
import 'perfil_controller.dart';

/// Pestaña Equipo: todas las láminas en una retícula. En el perfil propio
/// marca los Pokémon reservados en un intercambio.
class EquipoTab extends StatelessWidget {
  const EquipoTab({super.key});

  static const anchoLamina = 380.0;

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()..asegurarReservados();
    final reservados = perfil.reservados?.valorOrNull ?? const <int>{};
    return switch (perfil.pokemon) {
      Cargando() => const BloqueCargando(alto: 320),
      Fallo(:final error) => NotaVacia(
        mensajeParaUsuario(error),
        accion: OutlinedButton(
          onPressed: perfil.cargar,
          child: const Text('REINTENTAR'),
        ),
      ),
      Listo(valor: final lista) when lista.isEmpty => const NotaVacia(
        'Todavía no tiene Pokémon. Aparecen aquí al capturar, recibir un intercambio o elegir el inicial en el juego.',
      ),
      Listo(valor: final lista) => Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            _conteo(lista.map((p) => p.salud)),
            style: Tipos.detalle(
              compacto: MediaQuery.sizeOf(context).width < 900,
            ),
          ),
          const SizedBox(height: Espacio.m),
          LayoutBuilder(
            builder: (context, constraints) {
              const hueco = Espacio.m;
              final columnas = math.max(
                1,
                ((constraints.maxWidth + hueco) / (anchoLamina + hueco))
                    .floor(),
              );
              final ancho =
                  (constraints.maxWidth - hueco * (columnas - 1)) / columnas;
              return Wrap(
                spacing: hueco,
                runSpacing: hueco,
                children: [
                  for (final p in lista)
                    SizedBox(
                      width: ancho,
                      child: LaminaPokemon(
                        userId: perfil.userId,
                        pokemon: p,
                        reservado: reservados.contains(p.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    };
  }

  /// "5 Pokémon · 3 sanos · 1 afectado · 1 debilitado".
  static String _conteo(Iterable<Salud> salud) {
    final n = salud.length;
    String parte(Salud s, String uno, String varios) {
      final c = salud.where((x) => x == s).length;
      return c == 0 ? '' : '$c ${c == 1 ? uno : varios}';
    }

    return [
      '$n Pokémon',
      parte(Salud.sano, 'sano', 'sanos'),
      parte(Salud.afectado, 'afectado', 'afectados'),
      parte(Salud.debilitado, 'debilitado', 'debilitados'),
    ].where((t) => t.isNotEmpty).join(' · ');
  }
}
