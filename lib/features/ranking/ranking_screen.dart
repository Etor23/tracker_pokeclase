import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pie_paginado.dart';
import '../../core/widgets/tracker_shell.dart';
import '../../data/models/ranking.dart';
import '../../data/tracker_repository.dart';
import 'ranking_controller.dart';

/// Ranking con buscador. El orden y la búsqueda viven en la URL
/// (`/?orden=winrate&q=ash`), así que se pueden compartir.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key, required this.orden, required this.busqueda});

  final OrdenRanking orden;
  final String busqueda;

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late final RankingController _ranking = RankingController(
    context.read<TrackerRepository>(),
    orden: widget.orden,
    busqueda: widget.busqueda,
    miId: context.read<SessionController>().session?.userId,
  )..cargar();

  late final TextEditingController _campo = TextEditingController(
    text: widget.busqueda,
  );
  Timer? _espera;

  @override
  void didUpdateWidget(RankingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // La URL cambió (búsqueda desde la barra superior, atrás del navegador).
    if (widget.busqueda != _campo.text.trim()) _campo.text = widget.busqueda;
    _ranking.aplicar(orden: widget.orden, busqueda: widget.busqueda);
  }

  @override
  void dispose() {
    _espera?.cancel();
    _campo.dispose();
    _ranking.dispose();
    super.dispose();
  }

  void _irA({OrdenRanking? orden, String? busqueda}) {
    final o = orden ?? widget.orden;
    final q = (busqueda ?? widget.busqueda).trim();
    context.replace(
      Uri(
        path: Rutas.ranking,
        queryParameters: {
          if (o != OrdenRanking.porDefecto) 'orden': o.valor,
          if (q.isNotEmpty) 'q': q,
        },
      ).toString(),
    );
  }

  void _alEscribir(String texto) {
    _espera?.cancel();
    _espera = Timer(
      const Duration(milliseconds: 300),
      () => _irA(busqueda: texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final margen = Espacio.margen(ancho);
    final tabla = ancho >= TrackerShell.anchoEscritorio;
    return TrackerShell(
      seccion: Seccion.ranking,
      child: ChangeNotifierProvider.value(
        value: _ranking,
        child: ListView(
          padding: EdgeInsets.fromLTRB(margen, Espacio.l, margen, Espacio.xxl),
          children: [
            _Encabezado(compacto: !tabla),
            const SizedBox(height: Espacio.l),
            _Controles(
              campo: _campo,
              alEscribir: _alEscribir,
              alBuscar: (t) {
                _espera?.cancel();
                _irA(busqueda: t);
              },
              alOrdenar: (o) => _irA(orden: o),
            ),
            const SizedBox(height: Espacio.l),
            _Resultados(
              tabla: tabla,
              alOrdenar: (o) => _irA(orden: o),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.compacto});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RankingController>();
    final conteo = switch (r.estado) {
      Listo() when r.buscando =>
        '${r.total} ${r.total == 1 ? 'jugador coincide' : 'jugadores coinciden'}',
      Listo() => '${r.total} ${r.total == 1 ? 'jugador' : 'jugadores'}',
      _ => '',
    };
    return Row(
      crossAxisAlignment: .end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Semantics(
                header: true,
                child: Text('RANKING', style: Tipos.bitmap(compacto ? 32 : 48)),
              ),
              const SizedBox(height: Espacio.s),
              Text(conteo, style: Tipos.pequeno),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar datos',
          onPressed: r.cargar,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _Controles extends StatelessWidget {
  const _Controles({
    required this.campo,
    required this.alEscribir,
    required this.alBuscar,
    required this.alOrdenar,
  });

  final TextEditingController campo;
  final ValueChanged<String> alEscribir;
  final ValueChanged<String> alBuscar;
  final ValueChanged<OrdenRanking> alOrdenar;

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RankingController>();
    return Wrap(
      spacing: Espacio.l,
      runSpacing: Espacio.m,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: TextField(
            controller: campo,
            onChanged: alEscribir,
            onSubmitted: alBuscar,
            textInputAction: .search,
            decoration: InputDecoration(
              hintText: 'Buscar jugador',
              prefixIcon: const Icon(Icons.search, color: Paleta.tinta),
              suffixIcon: ListenableBuilder(
                listenable: campo,
                builder: (context, _) => campo.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Borrar búsqueda',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          campo.clear();
                          alBuscar('');
                        },
                      ),
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Ordenar por',
          container: true,
          child: Wrap(
            spacing: Espacio.s,
            runSpacing: Espacio.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'ORDENAR',
                style: Tipos.bitmap(16, color: Paleta.tintaSuave),
              ),
              for (final o in OrdenRanking.values)
                ChoiceChip(
                  label: Text(
                    o.etiqueta,
                    style: Tipos.chipOrden.copyWith(
                      color: r.orden == o ? Paleta.blanco : Paleta.tinta,
                    ),
                  ),
                  selected: r.orden == o,
                  onSelected: (_) => alOrdenar(o),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Resultados extends StatelessWidget {
  const _Resultados({required this.tabla, required this.alOrdenar});

  final bool tabla;
  final ValueChanged<OrdenRanking> alOrdenar;

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RankingController>();
    final miId = context.watch<SessionController>().session?.userId;

    final notas = [
      if (r.buscando) 'Con búsqueda, el número de cada fila es su lugar entre los resultados, no en el ranking general.',
      if (r.orden == OrdenRanking.winrate) 'El win rate cuenta victorias y derrotas; quienes tienen menos de 5 batallas decididas van al final.',
    ];

    return switch (r.estado) {
      Cargando() => const BloqueCargando(alto: 320),
      Fallo(:final error) => NotaVacia(
        mensajeParaUsuario(error),
        accion: OutlinedButton(
          onPressed: r.cargar,
          child: const Text('REINTENTAR'),
        ),
      ),
      Listo() when r.filas.isEmpty => NotaVacia(
        r.buscando
            ? 'Ningún jugador coincide con «${r.busqueda}». Revisa cómo se escribe el nombre.'
            : 'Todavía no hay jugadores en el ranking.',
      ),
      Listo() => Column(
        crossAxisAlignment: .stretch,
        children: [
          for (final n in notas) ...[
            Text(n, style: Tipos.detalle(compacto: !tabla)),
            const SizedBox(height: Espacio.s),
          ],
          if (notas.isNotEmpty) const SizedBox(height: Espacio.s),
          if (tabla) _CabeceraTabla(orden: r.orden, alOrdenar: alOrdenar),
          for (final f in r.filas)
            tabla
                ? _FilaTabla(
                    fila: f,
                    esMia: f.id == miId,
                    totalPokedex: r.totalPokedex,
                    atenuarPosicion: r.buscando,
                  )
                : _FilaLista(
                    fila: f,
                    esMia: f.id == miId,
                    orden: r.orden,
                    totalPokedex: r.totalPokedex,
                    atenuarPosicion: r.buscando,
                  ),
          const SizedBox(height: Espacio.l),
          PiePaginado(
            mostrados: r.filas.length,
            total: r.total,
            cargando: r.cargandoMas,
            error: r.errorMas,
            alCargarMas: r.cargarMas,
          ),
        ],
      ),
    };
  }
}

/// Anchos de las columnas de la tabla (escritorio).
abstract final class _Col {
  static const posicion = 96.0;
  static const pokedex = 248.0;
  static const pokemon = 112.0;
  static const vd = 80.0;
  static const winrate = 120.0;
}

class _CabeceraTabla extends StatelessWidget {
  const _CabeceraTabla({required this.orden, required this.alOrdenar});

  final OrdenRanking orden;
  final ValueChanged<OrdenRanking> alOrdenar;

  @override
  Widget build(BuildContext context) {
    Widget celda(String texto, double? ancho, {OrdenRanking? ordena}) {
      final activa = ordena != null && ordena == orden;
      Widget hijo = Row(
        mainAxisSize: .min,
        children: [
          if (activa) ...[
            Container(width: 8, height: 8, color: Paleta.rojo),
            const SizedBox(width: Espacio.s),
          ],
          Flexible(
            child: Text(
              texto,
              style: Tipos.bitmap(16, color: Paleta.papel),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
      if (ordena != null) {
        hijo = Semantics(
          button: true,
          selected: activa,
          label: 'Ordenar por ${ordena.etiqueta}',
          excludeSemantics: true,
          child: InkWell(
            onTap: () => alOrdenar(ordena),
            child: SizedBox(
              height: 40,
              child: Align(alignment: Alignment.centerLeft, child: hijo),
            ),
          ),
        );
      }
      return ancho == null
          ? Expanded(child: hijo)
          : SizedBox(width: ancho, child: hijo);
    }

    return Container(
      height: 40,
      color: Paleta.tinta,
      padding: const EdgeInsets.symmetric(horizontal: Espacio.m),
      child: Row(
        children: [
          celda('#', _Col.posicion),
          celda('JUGADOR', null, ordena: OrdenRanking.nombre),
          celda('POKÉDEX', _Col.pokedex, ordena: OrdenRanking.pokedex),
          celda('POKÉMON', _Col.pokemon, ordena: OrdenRanking.pokemon),
          celda('V', _Col.vd, ordena: OrdenRanking.victorias),
          celda('D', _Col.vd),
          celda('WIN RATE', _Col.winrate, ordena: OrdenRanking.winrate),
        ],
      ),
    );
  }
}

class _FilaTabla extends StatelessWidget {
  const _FilaTabla({
    required this.fila,
    required this.esMia,
    required this.totalPokedex,
    required this.atenuarPosicion,
  });

  final FilaRanking fila;
  final bool esMia;
  final int? totalPokedex;
  final bool atenuarPosicion;

  @override
  Widget build(BuildContext context) {
    final f = fila;
    final dato = Tipos.dato.copyWith(fontSize: 18);
    return _Enlace(
      fila: f,
      esMia: esMia,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: Espacio.m),
        decoration: BoxDecoration(
          color: esMia ? Paleta.hueco : null,
          border: const Border(bottom: BorderSide(color: Paleta.linea)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: _Col.posicion,
              child: _Posicion(f.posicion, tam: 32, atenuada: atenuarPosicion),
            ),
            Expanded(child: _Nombre(f.userName, esMia: esMia, tam: 18)),
            SizedBox(
              width: _Col.pokedex,
              child: _Pokedex(f.especiesRegistradas, totalPokedex),
            ),
            SizedBox(
              width: _Col.pokemon,
              child: Text('${f.totalPokemon}', style: dato),
            ),
            SizedBox(
              width: _Col.vd,
              child: Text('${f.victorias}', style: dato),
            ),
            SizedBox(
              width: _Col.vd,
              child: Text('${f.derrotas}', style: dato),
            ),
            SizedBox(
              width: _Col.winrate,
              child: Text(porcentaje(f.winRate), style: dato),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaLista extends StatelessWidget {
  const _FilaLista({
    required this.fila,
    required this.esMia,
    required this.orden,
    required this.totalPokedex,
    required this.atenuarPosicion,
  });

  final FilaRanking fila;
  final bool esMia;
  final OrdenRanking orden;
  final int? totalPokedex;
  final bool atenuarPosicion;

  @override
  Widget build(BuildContext context) {
    final f = fila;
    // La cifra de la derecha es la del orden activo.
    final (valor, unidad) = switch (orden) {
      OrdenRanking.winrate => (porcentaje(f.winRate, pegado: true), 'win rate'),
      OrdenRanking.victorias => ('${f.victorias}', 'victorias'),
      OrdenRanking.pokemon => ('${f.totalPokemon}', 'Pokémon'),
      OrdenRanking.pokedex ||
      OrdenRanking.nombre => ('${f.especiesRegistradas}', 'especies'),
    };
    final especies = totalPokedex == null
        ? '${f.especiesRegistradas} especies'
        : '${f.especiesRegistradas}/$totalPokedex';
    final detalle =
        '$especies · ${f.totalPokemon} Pokémon · ${f.victorias} V ${f.derrotas} D';
    return _Enlace(
      fila: f,
      esMia: esMia,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Espacio.s,
          vertical: Espacio.s + 4,
        ),
        decoration: BoxDecoration(
          color: esMia ? Paleta.hueco : null,
          border: const Border(bottom: BorderSide(color: Paleta.linea)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: _Posicion(f.posicion, tam: 24, atenuada: atenuarPosicion),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  _Nombre(f.userName, esMia: esMia, tam: 16),
                  const SizedBox(height: Espacio.xs),
                  Text(detalle, style: Tipos.pequeno),
                ],
              ),
            ),
            const SizedBox(width: Espacio.s),
            Column(
              crossAxisAlignment: .end,
              children: [
                Text(valor, style: Tipos.bitmap(24)),
                const SizedBox(height: Espacio.xs),
                Text(unidad, style: Tipos.pequeno),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Toda la fila lleva al perfil del jugador.
class _Enlace extends StatelessWidget {
  const _Enlace({required this.fila, required this.esMia, required this.child});

  final FilaRanking fila;
  final bool esMia;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: [
      'Lugar ${fila.posicion}, ${fila.userName}${esMia ? ' (tú)' : ''}',
      '${fila.especiesRegistradas} especies',
      '${fila.totalPokemon} Pokémon',
      '${fila.victorias} victorias, ${fila.derrotas} derrotas',
      'win rate ${fila.winRate == null ? 'sin datos' : porcentaje(fila.winRate)}',
    ].join(', '),
    excludeSemantics: true,
    child: InkWell(
      onTap: () => context.go(esMia ? Rutas.yo : Rutas.usuario(fila.id)),
      child: child,
    ),
  );
}

class _Posicion extends StatelessWidget {
  const _Posicion(this.posicion, {required this.tam, required this.atenuada});

  final int posicion;
  final double tam;
  final bool atenuada;

  @override
  Widget build(BuildContext context) => Transform.translate(
    // Compensa el margen izquierdo de 1/8 de em de Silkscreen.
    offset: Offset(-tam / 8, 0),
    child: Text(
      posicion.toString().padLeft(2, '0'),
      style: Tipos.bitmap(tam, color: atenuada ? Paleta.tenue : Paleta.tinta),
    ),
  );
}

class _Nombre extends StatelessWidget {
  const _Nombre(this.nombre, {required this.esMia, required this.tam});

  final String nombre;
  final bool esMia;
  final double tam;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Text(
          nombre,
          style: Tipos.titulo.copyWith(fontSize: tam),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (esMia) ...[
        const SizedBox(width: Espacio.s),
        Container(
          color: Paleta.tinta,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text('TÚ', style: Tipos.bitmap(16, color: Paleta.papel)),
        ),
      ],
    ],
  );
}

/// Especies registradas con barra a escala exacta sobre el total de la
/// Pokédex (si se conoce).
class _Pokedex extends StatelessWidget {
  const _Pokedex(this.registradas, this.total);

  final int registradas;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final t = total;
    final texto = t == null ? '$registradas' : '$registradas/$t';
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(texto, style: Tipos.dato.copyWith(fontSize: 18)),
        ),
        if (t != null && t > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: Espacio.l),
              child: Container(
                height: 8,
                color: Paleta.linea,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (registradas / t).clamp(0.0, 1.0),
                  child: Container(color: Paleta.rojo),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
