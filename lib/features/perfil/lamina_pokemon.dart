import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/marcas_pokemon.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/pokemon_jugador.dart';

/// Lámina de un Pokémon: el único lugar donde entran los colores de tipo y de
/// salud. Lleva al detalle del Pokémon.
class LaminaPokemon extends StatelessWidget {
  const LaminaPokemon({
    super.key,
    required this.userId,
    required this.pokemon,
    this.reservado = false,
  });

  final String userId;
  final PokemonJugador pokemon;

  /// Reservado en un intercambio pendiente (solo se sabe en el perfil propio).
  final bool reservado;

  @override
  Widget build(BuildContext context) {
    final p = pokemon;
    final e = p.estado;
    final nombre = capitalizar(p.nombre);
    final origen = [
      ?p.origenVisible,
      if (p.fechaObtencion case final f?) fechaCorta(f),
    ].join(' · ');

    return Semantics(
      button: true,
      label:
          '$nombre${reservado ? ', reservado para un intercambio' : ''}, ver detalle',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.go(Rutas.pokemon(userId, p.id)),
        child: Container(
          decoration: BoxDecoration(
            color: Paleta.papel,
            border: Border.all(color: Paleta.tinta, width: Espacio.regla),
          ),
          padding: const EdgeInsets.all(Espacio.m),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final escala = constraints.maxWidth >= 360 ? 2 : 1;
              return Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      PixelSprite(
                        url: p.sprite,
                        idEspecie: p.idEspecie,
                        nombre: nombre,
                        escala: escala,
                        atenuado: p.crianzaMuerta,
                      ),
                      const SizedBox(width: Espacio.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(nombre, style: Tipos.titulo),
                            const SizedBox(height: Espacio.xs),
                            Text(
                              '#${numeroEspecie(p.idEspecie)}',
                              style: Tipos.bitmap(16, color: Paleta.tintaSuave),
                            ),
                            const SizedBox(height: Espacio.s + 4),
                            Wrap(
                              spacing: Espacio.xs,
                              runSpacing: Espacio.xs,
                              children: [for (final t in e.tipos) ChipTipo(t)],
                            ),
                            const SizedBox(height: Espacio.s + 4),
                            MarcaSalud(p.salud, estado: e.estadoNombre),
                            if (reservado) ...[
                              const SizedBox(height: Espacio.xs),
                              Text(
                                'Reservado para un intercambio',
                                style: Tipos.detalle(
                                  compacto: esCompacto(context),
                                ),
                              ),
                            ],
                            if (p.crianzaMuerta) ...[
                              const SizedBox(height: Espacio.xs),
                              const Text(
                                'Crianza: murió',
                                style: Tipos.pequeno,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Espacio.m),
                  BarraDato(
                    'PS',
                    valor: e.vidaActual,
                    maximo: e.vidaTotal,
                    texto: '${e.vidaActual} / ${e.vidaTotal}',
                    color: p.salud.color,
                  ),
                  BarraDato('Ataque', valor: e.ataqueBase, maximo: 255),
                  BarraDato('Defensa', valor: e.defensaBase, maximo: 255),
                  BarraDato('Velocidad', valor: e.velocidadBase, maximo: 255),
                  if (origen.isNotEmpty) ...[
                    const SizedBox(height: Espacio.s),
                    Text(
                      origen,
                      style: Tipos.detalle(compacto: esCompacto(context)),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
