import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/fila_cifras.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pokedex_tira.dart';
import '../../data/models/pokedex_jugador.dart';
import '../../data/models/pokemon_jugador.dart';
import '../../data/models/resumen_jugador.dart';
import 'lamina_pokemon.dart';
import 'perfil_controller.dart';

/// Pestaña Resumen: la Pokédex como cifra a escala de póster, las cifras del
/// jugador y su equipo.
class ResumenTab extends StatelessWidget {
  const ResumenTab({super.key, required this.alVerEquipo});

  final VoidCallback alVerEquipo;

  static const anchoEquipo = 420.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final dosColumnas = constraints.maxWidth >= 1000;
      const principal = _Principal();
      final equipo = _Equipo(alVerEquipo: alVerEquipo);
      if (!dosColumnas) {
        return Column(
          crossAxisAlignment: .stretch,
          children: [
            principal,
            const SizedBox(height: Espacio.xl),
            equipo,
          ],
        );
      }
      return Row(
        crossAxisAlignment: .start,
        children: [
          const Expanded(child: principal),
          const SizedBox(width: Espacio.xl),
          SizedBox(width: anchoEquipo, child: equipo),
        ],
      );
    },
  );
}

Widget _reintentar(BuildContext context, Object error) => NotaVacia(
  mensajeParaUsuario(error),
  accion: OutlinedButton(
    onPressed: context.read<PerfilController>().cargar,
    child: const Text('REINTENTAR'),
  ),
);

class _Principal extends StatelessWidget {
  const _Principal();

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final poster = ancho >= 760
            ? 192.0
            : ancho >= 560
            ? 144.0
            : 96.0;
        return switch (perfil.resumen) {
          Cargando() => BloqueCargando(alto: poster + 120),
          Fallo(:final error) => _reintentar(context, error),
          Listo(valor: final r) => Column(
            crossAxisAlignment: .stretch,
            children: [
              _CifraPokedex(r.pokedex, poster: poster),
              const SizedBox(height: Espacio.m),
              _Tira(
                total: r.pokedex.total,
                pokedex: perfil.pokedex,
                pokemon: perfil.pokemon.valorOrNull ?? const [],
              ),
              const SizedBox(height: Espacio.xl),
              _FilaCifras(r, compacta: ancho < 640),
              if (_notaBatallas(r.batallas) case final nota?) ...[
                const SizedBox(height: Espacio.l),
                NotaVacia(nota),
              ],
            ],
          ),
        };
      },
    );
  }

  static String? _notaBatallas(ConteoBatallas b) {
    if (b.total == 0) {
      return 'Aún no hay batallas registradas. El win rate aparece con la primera victoria o derrota.';
    }
    if (b.winRate == null) {
      return 'Solo hay huidas: el win rate cuenta victorias y derrotas, no huidas.';
    }
    return null;
  }
}

class _CifraPokedex extends StatelessWidget {
  const _CifraPokedex(this.pokedex, {required this.poster});

  final ConteoPokedex pokedex;
  final double poster;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Pokédex: ${pokedex.registrados} de ${pokedex.total} especies registradas',
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: .start,
      children: [
        // Silkscreen deja 1/8 de em de margen izquierdo en cada glifo: se
        // compensa para que la cifra arranque en el borde de la columna.
        Transform.translate(
          offset: Offset(-poster / 8, 0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: numeroEspecie(pokedex.registrados),
                    style: Tipos.bitmap(poster),
                  ),
                  TextSpan(
                    text: '/${pokedex.total}',
                    style: Tipos.bitmap(poster / 2, color: Paleta.tenue),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Espacio.m),
        Text(
          'REGISTRADAS EN LA POKÉDEX',
          style: Tipos.bitmap(16, color: Paleta.tintaSuave),
        ),
      ],
    ),
  );
}

class _Tira extends StatelessWidget {
  const _Tira({
    required this.total,
    required this.pokedex,
    required this.pokemon,
  });

  final int total;
  final Carga<PokedexJugador> pokedex;
  final List<PokemonJugador> pokemon;

  @override
  Widget build(BuildContext context) => switch (pokedex) {
    Cargando() => const BloqueCargando(alto: 20),
    Fallo() => const Text(
      'No se pudo cargar el detalle de la Pokédex.',
      style: Tipos.pequeno,
    ),
    Listo(valor: final p) => Column(
      crossAxisAlignment: .start,
      children: [
        PokedexTira(total: total, registrada: p.registrada),
        if (p.fueraDeLaGeneracion case final fuera when fuera.isNotEmpty) ...[
          const SizedBox(height: Espacio.s),
          Text(
            _textoFuera(fuera),
            style: Tipos.detalle(
              compacto: MediaQuery.sizeOf(context).width < 900,
            ),
          ),
        ],
      ],
    ),
  };

  /// "Incluye 1 especie de otra generación: Marill #183."
  String _textoFuera(List<int> ids) {
    String nombre(int id) {
      final p = pokemon.where((p) => p.idEspecie == id).firstOrNull;
      return p == null
          ? '#${numeroEspecie(id)}'
          : '${capitalizar(p.nombre)} #${numeroEspecie(id)}';
    }

    final n = ids.length;
    final especies = n == 1 ? '1 especie' : '$n especies';
    return 'La cuenta incluye $especies de otra generación: ${ids.map(nombre).join(', ')}.';
  }
}

class _FilaCifras extends StatelessWidget {
  const _FilaCifras(this.r, {required this.compacta});

  final ResumenJugador r;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final b = r.batallas;
    final p = r.pokemon;
    // Espacio no separable entre número y palabra: "1 debilitado" no se parte.
    String cuenta(int n, String uno, String varios) =>
        '$n ${n == 1 ? uno : varios}';
    final salud = [
      if (p.sanos > 0) cuenta(p.sanos, 'sano', 'sanos'),
      if (p.afectados > 0) cuenta(p.afectados, 'afectado', 'afectados'),
      if (p.debilitados > 0) cuenta(p.debilitados, 'debilitado', 'debilitados'),
      if (p.enCrianza > 0) '${p.enCrianza} en crianza',
    ].join(' · ');
    final decididas = b.victorias + b.derrotas;

    return FilaCifras(compacta: compacta, [
      Cifra('Pokémon', '${p.total}', salud.isEmpty ? 'Sin Pokémon' : salud),
      Cifra(
        'Batallas',
        '${b.total}',
        '${b.victorias} V · ${b.derrotas} D · ${b.huidas} H',
      ),
      Cifra(
        'Win rate',
        porcentaje(b.winRate, pegado: true),
        decididas == 0
            ? 'Sin victorias ni derrotas'
            : '${b.victorias} de $decididas decididas',
      ),
      Cifra('Objetos', '${r.objetosTotal}', '${r.objetosDistintos} distintos'),
    ]);
  }
}

class _Equipo extends StatelessWidget {
  const _Equipo({required this.alVerEquipo});

  final VoidCallback alVerEquipo;

  static const _maximo = 3;

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>();
    final carga = perfil.pokemon;
    final n = carga.valorOrNull?.length;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        FranjaTitulo('Equipo', detalle: n?.toString()),
        const SizedBox(height: Espacio.m),
        ...switch (carga) {
          Cargando() => [const BloqueCargando(alto: 280)],
          Fallo(:final error) => [_reintentar(context, error)],
          Listo(valor: final lista) when lista.isEmpty => [
            const NotaVacia(
              'Todavía no tiene Pokémon. Aparecen aquí al capturar, recibir un intercambio o elegir el inicial en el juego.',
            ),
          ],
          Listo(valor: final lista) => [
            for (final p in lista.take(_maximo)) ...[
              LaminaPokemon(userId: perfil.userId, pokemon: p),
              const SizedBox(height: Espacio.m),
            ],
            if (lista.length > _maximo)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: alVerEquipo,
                  child: Text('VER LOS ${lista.length} POKÉMON'),
                ),
              ),
          ],
        },
      ],
    );
  }
}
