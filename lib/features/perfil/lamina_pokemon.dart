import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/theme/pokemon_colores.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/pokemon_jugador.dart';

/// Lámina de un Pokémon: el único lugar donde entran los colores de tipo y de
/// salud. Lleva al detalle del Pokémon.
class LaminaPokemon extends StatelessWidget {
  const LaminaPokemon({super.key, required this.userId, required this.pokemon});

  final String userId;
  final PokemonJugador pokemon;

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
      label: '$nombre, ver detalle',
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
                              children: [for (final t in e.tipos) _ChipTipo(t)],
                            ),
                            const SizedBox(height: Espacio.s + 4),
                            _Salud(p.salud, estado: e.estadoNombre),
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
                  _BarraDato(
                    'PS',
                    valor: e.vidaActual,
                    maximo: e.vidaTotal,
                    texto: '${e.vidaActual} / ${e.vidaTotal}',
                    color: p.salud.color,
                  ),
                  _BarraDato('Ataque', valor: e.ataqueBase, maximo: 255),
                  _BarraDato('Defensa', valor: e.defensaBase, maximo: 255),
                  _BarraDato('Velocidad', valor: e.velocidadBase, maximo: 255),
                  if (origen.isNotEmpty) ...[
                    const SizedBox(height: Espacio.s),
                    Text(
                      origen,
                      style: Tipos.detalle(compacto: _compacto(context)),
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

class _ChipTipo extends StatelessWidget {
  const _ChipTipo(this.tipo);

  final String tipo;

  @override
  Widget build(BuildContext context) => Container(
    color: TiposPokemon.color(tipo),
    padding: const EdgeInsets.symmetric(horizontal: Espacio.s, vertical: 3),
    child: Text(TiposPokemon.nombre(tipo), style: Tipos.chip),
  );
}

class _Salud extends StatelessWidget {
  const _Salud(this.salud, {required this.estado});

  final Salud salud;
  final String? estado;

  @override
  Widget build(BuildContext context) {
    // "Afectado" sin más no dice qué tiene: se muestra el estado real.
    final texto = salud == Salud.afectado && estado != null
        ? estado!
        : salud.etiqueta;
    return Row(
      mainAxisSize: .min,
      children: [
        Container(width: 8, height: 8, color: salud.color),
        const SizedBox(width: Espacio.s),
        Text(
          texto,
          style: Tipos.detalle(compacto: _compacto(context))
              .copyWith(color: Paleta.tinta),
        ),
      ],
    );
  }
}

/// Barra a escala exacta del dato (sin redondeos decorativos).
class _BarraDato extends StatelessWidget {
  const _BarraDato(
    this.etiqueta, {
    required this.valor,
    required this.maximo,
    this.texto,
    this.color = Paleta.tinta,
  });

  final String etiqueta;
  final int valor;
  final int maximo;
  final String? texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final compacto = _compacto(context);
    final fraccion = maximo <= 0 ? 0.0 : (valor / maximo).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(etiqueta, style: Tipos.detalle(compacto: compacto)),
          ),
          Expanded(
            child: Container(
              height: 8,
              color: Paleta.hueco,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraccion,
                child: Container(color: color),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              texto ?? '$valor',
              textAlign: TextAlign.right,
              style: Tipos.dato.copyWith(fontSize: compacto ? 14 : 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// En pantallas anchas los detalles van a 15 px para leerse en proyector.
bool _compacto(BuildContext context) => MediaQuery.sizeOf(context).width < 900;
