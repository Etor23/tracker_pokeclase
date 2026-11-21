import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/marcas_pokemon.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../core/widgets/tracker_shell.dart';
import '../../data/models/pokemon_jugador.dart';
import '../../data/tracker_repository.dart';

/// Detalle de un Pokémon de un jugador (`/usuario/:id/pokemon/:pokemonUserId`).
/// Sale de la colección del jugador: no hay endpoint por Pokémon.
class PokemonDetalleScreen extends StatefulWidget {
  const PokemonDetalleScreen({
    super.key,
    required this.userId,
    required this.pokemonUserId,
  });

  final String userId;
  final int pokemonUserId;

  @override
  State<PokemonDetalleScreen> createState() => _PokemonDetalleScreenState();
}

class _PokemonDetalleScreenState extends State<PokemonDetalleScreen> {
  late Future<PokemonJugador?> _pokemon = _cargar();

  Future<PokemonJugador?> _cargar() async {
    final lista = await context.read<TrackerRepository>().pokemon(
      widget.userId,
    );
    return lista.where((p) => p.id == widget.pokemonUserId).firstOrNull;
  }

  @override
  void didUpdateWidget(PokemonDetalleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.pokemonUserId != widget.pokemonUserId) {
      _pokemon = _cargar();
    }
  }

  void _recargar() => setState(() => _pokemon = _cargar());

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final margen = Espacio.margen(ancho);
    final propio =
        context.watch<SessionController>().session?.userId == widget.userId;
    final volver = propio ? Rutas.yo : Rutas.usuario(widget.userId);

    return TrackerShell(
      seccion: propio ? Seccion.yo : Seccion.otro,
      child: ListView(
        padding: EdgeInsets.fromLTRB(margen, Espacio.m, margen, Espacio.xxl),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go(volver),
              icon: const Icon(Icons.arrow_back),
              label: Text(propio ? 'Mi perfil' : 'Perfil del jugador'),
            ),
          ),
          const SizedBox(height: Espacio.m),
          FutureBuilder(
            future: _pokemon,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const BloqueCargando(alto: 420);
              }
              if (snap.hasError) {
                return NotaVacia(
                  mensajeParaUsuario(snap.error!),
                  accion: OutlinedButton(
                    onPressed: _recargar,
                    child: const Text('REINTENTAR'),
                  ),
                );
              }
              final p = snap.data;
              if (p == null) {
                return const NotaVacia(
                  'Este Pokémon no existe o ya no es de este jugador (pudo cambiarlo en un intercambio).',
                );
              }
              return _Detalle(p, ancho: ancho - 2 * margen);
            },
          ),
        ],
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle(this.p, {required this.ancho});

  final PokemonJugador p;
  final double ancho;

  @override
  Widget build(BuildContext context) {
    final e = p.estado;
    final nombre = capitalizar(p.nombre);
    final compacto = ancho < 760;

    final escala = compacto ? 1 : 2;
    final sprites = Wrap(
      spacing: Espacio.m,
      runSpacing: Espacio.m,
      children: [
        _Vista(
          'Frente',
          PixelSprite(
            url: p.sprite,
            idEspecie: p.idEspecie,
            nombre: '$nombre de frente',
            escala: escala,
            atenuado: p.crianzaMuerta,
          ),
        ),
        if (e.urlTrasera case final trasera?)
          _Vista(
            'Espalda',
            PixelSprite(
              url: trasera,
              idEspecie: p.idEspecie,
              nombre: '$nombre de espalda',
              escala: escala,
              atenuado: p.crianzaMuerta,
            ),
          ),
      ],
    );

    final encabezado = Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          header: true,
          child: Text(nombre, style: Tipos.bitmap(compacto ? 32 : 48)),
        ),
        const SizedBox(height: Espacio.s),
        Text(
          '#${numeroEspecie(p.idEspecie)}',
          style: Tipos.bitmap(16, color: Paleta.tintaSuave),
        ),
        const SizedBox(height: Espacio.m),
        Wrap(
          spacing: Espacio.xs,
          runSpacing: Espacio.xs,
          children: [for (final t in e.tipos) ChipTipo(t)],
        ),
        const SizedBox(height: Espacio.m),
        MarcaSalud(p.salud, estado: e.estadoNombre),
      ],
    );

    final datos = Column(
      crossAxisAlignment: .stretch,
      children: [
        const FranjaTitulo('Estadísticas'),
        const SizedBox(height: Espacio.s),
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
        const SizedBox(height: Espacio.xs),
        Text(
          'Las barras de ataque, defensa y velocidad van sobre 255, el máximo de una estadística base.',
          style: Tipos.pequeno,
        ),
        const SizedBox(height: Espacio.l),
        const FranjaTitulo('Ficha'),
        _Ficha([
          if (p.origenVisible case final o?) ('Origen', o),
          if (p.fechaObtencion case final f?)
            ('Obtenido', '${fechaCorta(f)} · ${horaCorta(f)}'),
          ('Estado', e.estadoNombre ?? p.salud.etiqueta),
        ]),
        if (p.crianza case final c?) ...[
          const SizedBox(height: Espacio.l),
          FranjaTitulo('Crianza', detalle: c.vivo ? 'VIVA' : 'MURIÓ'),
          const SizedBox(height: Espacio.s),
          BarraDato('Hambre', valor: c.hambre, maximo: 100),
          BarraDato('Energía', valor: c.energia, maximo: 100),
          BarraDato('Higiene', valor: c.higiene, maximo: 100),
          _Ficha([
            if (c.fechaAdopcion case final f?) ('Adoptado', fechaCorta(f)),
            if (c.fechaMuerte case final f?) ('Murió', fechaCorta(f)),
          ]),
        ],
      ],
    );

    // Toda la página es una lámina: los colores de tipo y salud quedan
    // dentro de su borde.
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Paleta.tinta, width: Espacio.regla),
      ),
      padding: EdgeInsets.all(compacto ? Espacio.m : Espacio.l),
      child: compacto
          ? Column(
              crossAxisAlignment: .stretch,
              children: [
                encabezado,
                const SizedBox(height: Espacio.m),
                sprites,
                const SizedBox(height: Espacio.l),
                datos,
              ],
            )
          : Row(
              crossAxisAlignment: .start,
              children: [
                SizedBox(width: 192, child: sprites),
                const SizedBox(width: Espacio.xl),
                // Align deja que el ancho máximo se cumpla dentro de Expanded.
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          encabezado,
                          const SizedBox(height: Espacio.l),
                          datos,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Vista extends StatelessWidget {
  const _Vista(this.etiqueta, this.sprite);

  final String etiqueta;
  final Widget sprite;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      sprite,
      const SizedBox(height: Espacio.xs),
      Text(
        etiqueta.toUpperCase(),
        style: Tipos.bitmap(16, color: Paleta.tenue),
      ),
    ],
  );
}

/// Pares etiqueta–valor bajo reglas finas.
class _Ficha extends StatelessWidget {
  const _Ficha(this.filas);

  final List<(String, String)> filas;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (etiqueta, valor) in filas)
        Container(
          padding: const EdgeInsets.symmetric(vertical: Espacio.s + 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Paleta.linea)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  etiqueta,
                  style: Tipos.detalle(compacto: esCompacto(context)),
                ),
              ),
              Expanded(child: Text(valor, style: Tipos.dato)),
            ],
          ),
        ),
    ],
  );
}
