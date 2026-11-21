import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/tracker_shell.dart';
import '../../data/tracker_repository.dart';
import 'perfil_controller.dart';
import 'batallas_tab.dart';
import 'equipo_tab.dart';
import 'intercambios_tab.dart';
import 'mochila_tab.dart';
import 'pokedex_tab.dart';
import 'resumen_tab.dart';
import 'tamagotchi_tab.dart';

/// Perfil de un jugador (`/usuario/:id`) o el propio (`/yo`, con las pestañas
/// extra de Tamagotchi e Intercambios).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, required String this.userId})
    : esPropio = false;

  const PerfilScreen.propio({super.key}) : userId = null, esPropio = true;

  /// `null` en `/yo`: se toma el id de la sesión.
  final String? userId;
  final bool esPropio;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().session;
    final id = userId ?? session?.userId;
    if (id == null) return const SizedBox.shrink(); // el router manda a login
    final propio = esPropio || id == session?.userId;
    return TrackerShell(
      seccion: esPropio ? Seccion.yo : Seccion.otro,
      child: ChangeNotifierProvider(
        key: ValueKey(id),
        create: (context) => PerfilController(
          context.read<TrackerRepository>(),
          id,
          propio: propio,
        )..cargar(),
        child: _Perfil(
          propio: propio,
          nombreProvisional: propio ? session?.userName : null,
        ),
      ),
    );
  }
}

class _Perfil extends StatelessWidget {
  const _Perfil({required this.propio, required this.nombreProvisional});

  final bool propio;
  final String? nombreProvisional;

  List<String> get _pestanas => [
    'Resumen',
    'Equipo',
    'Batallas',
    'Mochila',
    'Pokédex',
    if (propio) ...['Tamagotchi', 'Intercambios'],
  ];

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>();
    final ancho = MediaQuery.sizeOf(context).width;
    final margen = Espacio.margen(ancho);
    final pestanas = _pestanas;

    if (perfil.resumen case Fallo(error: NotFoundException())) {
      return Padding(
        padding: EdgeInsets.all(margen),
        child: const NotaVacia('Este jugador no existe.'),
      );
    }

    return DefaultTabController(
      length: pestanas.length,
      child: Builder(
        builder: (context) {
          final tabs = DefaultTabController.of(context);
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(margen, Espacio.l, margen, 0),
                sliver: SliverToBoxAdapter(
                  child: _Encabezado(nombreProvisional: nombreProvisional),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: margen),
                sliver: SliverToBoxAdapter(
                  child: TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.only(right: Espacio.l),
                    tabs: [for (final p in pestanas) Tab(text: p, height: 48)],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  margen,
                  Espacio.l,
                  margen,
                  Espacio.xxl,
                ),
                // Cada pestaña es un sliver: la Pokédex arma su retícula de
                // forma diferida.
                sliver: ListenableBuilder(
                  listenable: tabs,
                  builder: (context, _) => switch (tabs.index) {
                    0 => SliverToBoxAdapter(
                      child: ResumenTab(alVerEquipo: () => tabs.animateTo(1)),
                    ),
                    1 => const SliverToBoxAdapter(child: EquipoTab()),
                    2 => const SliverToBoxAdapter(child: BatallasTab()),
                    3 => const SliverToBoxAdapter(child: MochilaTab()),
                    4 => const PokedexTab(),
                    5 => const SliverToBoxAdapter(child: TamagotchiTab()),
                    6 => const SliverToBoxAdapter(child: IntercambiosTab()),
                    _ => SliverToBoxAdapter(
                      child: NotaVacia(
                        'La pestaña ${pestanas[tabs.index]} está en construcción.',
                      ),
                    ),
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.nombreProvisional});

  final String? nombreProvisional;

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>();
    final nombre = perfil.resumen.valorOrNull?.userName ?? nombreProvisional;
    final compacto = MediaQuery.sizeOf(context).width < 700;
    final primera = perfil.pokemon.valorOrNull
        ?.map((p) => p.fechaObtencion)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);

    return Row(
      crossAxisAlignment: .end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (nombre != null)
                Semantics(
                  header: true,
                  child: Text(
                    nombre,
                    style: Tipos.bitmap(compacto ? 32 : 48),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                BloqueCargando(alto: compacto ? 32 : 48, ancho: 240),
              const SizedBox(height: Espacio.s),
              Text(
                primera == null
                    ? 'Jugador del grupo'
                    : 'Primer Pokémon el ${fechaCorta(primera)}',
                style: Tipos.pequeno,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar datos',
          onPressed: perfil.cargar,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
