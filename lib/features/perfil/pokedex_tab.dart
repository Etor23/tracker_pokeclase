import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/catalogo_especies.dart';
import '../../data/models/pokedex_jugador.dart';
import 'perfil_controller.dart';

enum _Filtro { todas, registradas, faltan }

/// Pestaña Pokédex: una casilla por especie (1..total). Registrada → sprite a
/// color, nombre y fecha; sin registrar → silueta gris. Devuelve slivers: la
/// retícula se construye de forma diferida y solo pide los sprites visibles.
class PokedexTab extends StatefulWidget {
  const PokedexTab({super.key});

  static const anchoCasilla = 144.0;
  static const altoCasilla = 188.0;

  @override
  State<PokedexTab> createState() => _PokedexTabState();
}

class _PokedexTabState extends State<PokedexTab> {
  _Filtro _filtro = _Filtro.todas;

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()..asegurarCatalogo();
    final catalogo = perfil.catalogo?.valorOrNull;
    final total = perfil.resumen.valorOrNull?.pokedex.total;

    return switch (perfil.pokedex) {
      Cargando() => const SliverToBoxAdapter(child: BloqueCargando(alto: 400)),
      Fallo(:final error) => SliverToBoxAdapter(
        child: NotaVacia(
          mensajeParaUsuario(error),
          accion: OutlinedButton(
            onPressed: perfil.cargar,
            child: const Text('REINTENTAR'),
          ),
        ),
      ),
      Listo(valor: final p) => _contenido(p, total ?? p.total, catalogo),
    };
  }

  Widget _contenido(PokedexJugador p, int total, CatalogoEspecies? catalogo) {
    final registradas = [
      for (var i = 1; i <= total; i++)
        if (p.registrada(i)) i,
    ];
    final ids = switch (_filtro) {
      _Filtro.todas => [for (var i = 1; i <= total; i++) i],
      _Filtro.registradas => registradas,
      _Filtro.faltan => [
        for (var i = 1; i <= total; i++)
          if (!p.registrada(i)) i,
      ],
    };
    final fuera = p.fueraDeLaGeneracion;

    Widget casilla(int id) => _Casilla(
      id: id,
      fecha: p.especies[id],
      registrada: p.registrada(id),
      catalogo: catalogo,
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _Cabecera(
            // La cifra grande es la del backend (igual que en Resumen); los
            // filtros cuentan solo las casillas de esta generación.
            cuenta: p.registrados,
            otrasGeneraciones: fuera.length,
            registradas: registradas.length,
            total: total,
            filtro: _filtro,
            alFiltrar: (f) => setState(() => _filtro = f),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Espacio.l)),
        if (ids.isEmpty)
          SliverToBoxAdapter(
            child: NotaVacia(
              _filtro == _Filtro.registradas
                  ? 'Todavía no hay especies registradas de esta generación.'
                  : '¡Pokédex completa! No falta ninguna especie.',
            ),
          )
        else
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: PokedexTab.anchoCasilla,
              mainAxisExtent: PokedexTab.altoCasilla,
              crossAxisSpacing: Espacio.s,
              mainAxisSpacing: Espacio.s,
            ),
            itemCount: ids.length,
            itemBuilder: (context, i) => casilla(ids[i]),
          ),
        if (fuera.isNotEmpty && _filtro != _Filtro.faltan) ...[
          const SliverToBoxAdapter(child: SizedBox(height: Espacio.xl)),
          SliverToBoxAdapter(
            child: FranjaTitulo(
              'Otras generaciones',
              detalle: '${fuera.length}',
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Espacio.s)),
          SliverToBoxAdapter(
            child: Text(
              'Registradas en el juego, pero fuera de las $total especies de esta Pokédex.',
              style: Tipos.detalle(
                compacto: MediaQuery.sizeOf(context).width < 900,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Espacio.m)),
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: PokedexTab.anchoCasilla,
              mainAxisExtent: PokedexTab.altoCasilla,
              crossAxisSpacing: Espacio.s,
              mainAxisSpacing: Espacio.s,
            ),
            itemCount: fuera.length,
            itemBuilder: (context, i) => casilla(fuera[i]),
          ),
        ],
      ],
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.cuenta,
    required this.otrasGeneraciones,
    required this.registradas,
    required this.total,
    required this.filtro,
    required this.alFiltrar,
  });

  final int cuenta;
  final int otrasGeneraciones;
  final int registradas;
  final int total;
  final _Filtro filtro;
  final ValueChanged<_Filtro> alFiltrar;

  @override
  Widget build(BuildContext context) {
    final opciones = {
      _Filtro.todas: 'Todas ($total)',
      _Filtro.registradas: 'Registradas ($registradas)',
      _Filtro.faltan: 'Faltan (${total - registradas})',
    };
    return Wrap(
      spacing: Espacio.l,
      runSpacing: Espacio.m,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          label: '$cuenta de $total especies registradas',
          excludeSemantics: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: numeroEspecie(cuenta), style: Tipos.bitmap(32)),
                TextSpan(
                  text: '/$total',
                  style: Tipos.bitmap(16, color: Paleta.tenue),
                ),
              ],
            ),
          ),
        ),
        if (otrasGeneraciones > 0)
          Text(
            otrasGeneraciones == 1
                ? 'Incluye 1 especie de otra generación (al final).'
                : 'Incluye $otrasGeneraciones especies de otras generaciones (al final).',
            style: Tipos.detalle(
              compacto: MediaQuery.sizeOf(context).width < 900,
            ),
          ),
        Wrap(
          spacing: Espacio.s,
          runSpacing: Espacio.s,
          children: [
            for (final MapEntry(key: f, value: texto) in opciones.entries)
              ChoiceChip(
                label: Text(
                  texto,
                  style: Tipos.chipOrden.copyWith(
                    color: f == filtro ? Paleta.blanco : Paleta.tinta,
                  ),
                ),
                selected: f == filtro,
                onSelected: (_) => alFiltrar(f),
              ),
          ],
        ),
      ],
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({
    required this.id,
    required this.fecha,
    required this.registrada,
    required this.catalogo,
  });

  final int id;
  final DateTime? fecha;
  final bool registrada;
  final CatalogoEspecies? catalogo;

  @override
  Widget build(BuildContext context) {
    final nombre = catalogo?.nombre(id) ?? '#${numeroEspecie(id)}';
    return Semantics(
      label: registrada
          ? '$nombre, número $id, registrada${fecha == null ? '' : ' el ${fechaCorta(fecha!)}'}'
          : 'Número $id, sin registrar',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          border: registrada
              ? Border.all(color: Paleta.tinta, width: Espacio.regla)
              : Border.all(color: Paleta.linea),
        ),
        padding: const EdgeInsets.all(Espacio.s),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Text(
                  numeroEspecie(id),
                  style: Tipos.bitmap(
                    16,
                    color: registrada ? Paleta.tinta : Paleta.tenue,
                  ),
                ),
                const Spacer(),
                if (registrada)
                  Container(width: 8, height: 8, color: Paleta.rojo),
              ],
            ),
            const SizedBox(height: Espacio.xs),
            Center(
              child: PixelSprite(
                url: urlSpriteEspecie(id),
                idEspecie: id,
                nombre: registrada ? nombre : 'Silueta del número $id',
                silueta: !registrada,
              ),
            ),
            const SizedBox(height: Espacio.xs),
            Text(
              registrada ? nombre : '—',
              style: Tipos.cuerpo.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: registrada ? Paleta.tinta : Paleta.tenue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (registrada && fecha != null)
              Text(fechaCorta(fecha!), style: Tipos.pequeno),
          ],
        ),
      ),
    );
  }
}
