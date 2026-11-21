import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/theme/pokemon_colores.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/marcas_pokemon.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/mascota.dart';
import 'perfil_controller.dart';

/// Pestaña Tamagotchi (solo en Mi perfil): mis mascotas y sus necesidades.
class TamagotchiTab extends StatelessWidget {
  const TamagotchiTab({super.key});

  static const anchoTarjeta = 380.0;

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()
      ..asegurarMascotas()
      ..asegurarCatalogo();
    final compacto = MediaQuery.sizeOf(context).width < 900;
    return switch (perfil.mascotas) {
      null || Cargando() => const BloqueCargando(alto: 240),
      Fallo(:final error) => NotaVacia(
        mensajeParaUsuario(error),
        accion: OutlinedButton(
          onPressed: perfil.reintentarMascotas,
          child: const Text('REINTENTAR'),
        ),
      ),
      Listo(valor: final lista) when lista.isEmpty => const NotaVacia(
        'No tienes mascotas. Se adoptan desde el juego; puedes tener hasta 4 vivas a la vez.',
      ),
      Listo(valor: final lista) => Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            '${lista.where((m) => m.vivo).length} de ${Mascota.maximoVivas} vivas · '
            'Hambre, energía e higiene bajan 100 puntos cada 24 horas.',
            style: Tipos.detalle(compacto: compacto),
          ),
          const SizedBox(height: Espacio.m),
          LayoutBuilder(
            builder: (context, constraints) {
              const hueco = Espacio.m;
              final columnas = math.max(
                1,
                ((constraints.maxWidth + hueco) / (anchoTarjeta + hueco))
                    .floor(),
              );
              final ancho =
                  (constraints.maxWidth - hueco * (columnas - 1)) / columnas;
              return Wrap(
                spacing: hueco,
                runSpacing: hueco,
                children: [
                  for (final m in lista)
                    SizedBox(
                      width: ancho,
                      child: _TarjetaMascota(m, nombre: _nombre(perfil, m)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    };
  }

  /// El nombre sale de mi colección (por id) o del catálogo (por especie).
  static String _nombre(PerfilController perfil, Mascota m) {
    final propio = perfil.pokemon.valorOrNull
        ?.where((p) => p.id == m.idPokemonUser)
        .firstOrNull;
    if (propio != null) return capitalizar(propio.nombre);
    final especie = m.idEspecie;
    if (especie == null) return 'Mascota ${m.id}';
    return perfil.catalogo?.valorOrNull?.nombre(especie) ??
        '#${numeroEspecie(especie)}';
  }
}

class _TarjetaMascota extends StatelessWidget {
  const _TarjetaMascota(this.m, {required this.nombre});

  final Mascota m;
  final String nombre;

  /// Por debajo de este valor la necesidad se marca en rojo.
  static const _bajo = 25;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<PerfilController>().userId;
    final salud = !m.vivo || m.vidaActual == 0
        ? Salud.debilitado
        : (m.estado != null && m.estado != 'Sano' && m.estado != 'Dormido')
        ? Salud.afectado
        : Salud.sano;
    final estado = m.vivo ? (m.estado ?? 'Viva') : 'Murió';

    BarraDato necesidad(String etiqueta, int valor) => BarraDato(
      etiqueta,
      valor: valor,
      maximo: 100,
      color: m.vivo && valor <= _bajo ? Paleta.rojo : Paleta.tinta,
    );

    final tarjeta = Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: m.vivo ? Paleta.tinta : Paleta.linea,
          width: Espacio.regla,
        ),
      ),
      padding: const EdgeInsets.all(Espacio.m),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              if (m.idEspecie case final especie?)
                PixelSprite(
                  url: urlSpriteEspecie(especie),
                  idEspecie: especie,
                  nombre: nombre,
                  atenuado: !m.vivo,
                ),
              const SizedBox(width: Espacio.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(nombre, style: Tipos.titulo),
                    const SizedBox(height: Espacio.s),
                    MarcaSalud(salud, estado: estado, texto: estado),
                    if (m.fechaAdopcion case final f?) ...[
                      const SizedBox(height: Espacio.xs),
                      Text(
                        'Adoptada el ${fechaCorta(f)}',
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
            valor: m.vidaActual,
            maximo: m.vidaTotal,
            texto: '${m.vidaActual} / ${m.vidaTotal}',
            color: salud.color,
          ),
          necesidad('Hambre', m.hambre),
          necesidad('Energía', m.energia),
          necesidad('Higiene', m.higiene),
        ],
      ),
    );

    final idPokemon = m.idPokemonUser;
    return Semantics(
      label:
          '$nombre, $estado, vida ${m.vidaActual} de ${m.vidaTotal}, hambre ${m.hambre}, energía ${m.energia}, higiene ${m.higiene}',
      excludeSemantics: true,
      button: idPokemon != null,
      child: idPokemon == null
          ? tarjeta
          : InkWell(
              onTap: () => context.go(Rutas.pokemon(userId, idPokemon)),
              child: tarjeta,
            ),
    );
  }
}
