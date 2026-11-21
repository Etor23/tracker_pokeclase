import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/catalogo_especies.dart';
import '../../data/models/intercambio.dart';
import 'perfil_controller.dart';

/// Pestaña Intercambios (solo en Mi perfil): recibidos y enviados, con lo que
/// doy y lo que recibo en cada uno.
class IntercambiosTab extends StatelessWidget {
  const IntercambiosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()
      ..asegurarIntercambios()
      ..asegurarCatalogo();
    final compacto = MediaQuery.sizeOf(context).width < 700;
    final filtro = perfil.filtroIntercambios;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Semantics(
          label: 'Filtrar por estado',
          container: true,
          child: Wrap(
            spacing: Espacio.s,
            runSpacing: Espacio.s,
            children: [
              for (final (e, texto) in [
                (null, 'Todos'),
                for (final e in EstadoIntercambio.values) (e, e.plural),
              ])
                ChoiceChip(
                  label: Text(
                    texto,
                    style: Tipos.chipOrden.copyWith(
                      color: filtro == e ? Paleta.blanco : Paleta.tinta,
                    ),
                  ),
                  selected: filtro == e,
                  onSelected: (_) => perfil.filtrarIntercambios(e),
                ),
            ],
          ),
        ),
        const SizedBox(height: Espacio.l),
        ...switch (perfil.intercambios) {
          null || Cargando() => [const BloqueCargando(alto: 240)],
          Fallo(:final error) => [
            NotaVacia(
              mensajeParaUsuario(error),
              accion: OutlinedButton(
                onPressed: perfil.reintentarIntercambios,
                child: const Text('REINTENTAR'),
              ),
            ),
          ],
          Listo(valor: final lista) when lista.isEmpty => [
            NotaVacia(
              filtro == null
                  ? 'No tienes intercambios. Se crean desde el juego: ofreces un Pokémon y el otro jugador responde con uno suyo.'
                  : 'No tienes intercambios ${filtro.plural.toLowerCase()}.',
            ),
          ],
          Listo(valor: final lista) => [
            for (final (titulo, grupo) in [
              ('Recibidos', lista.where((i) => !i.enviado).toList()),
              ('Enviados', lista.where((i) => i.enviado).toList()),
            ]) ...[
              FranjaTitulo(titulo, detalle: '${grupo.length}'),
              if (grupo.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Espacio.m),
                  child: Text('Ninguno.', style: Tipos.cuerpoSuave),
                )
              else
                for (final i in grupo)
                  _FilaIntercambio(
                    i,
                    catalogo: perfil.catalogo?.valorOrNull,
                    compacto: compacto,
                  ),
              const SizedBox(height: Espacio.l),
            ],
          ],
        },
      ],
    );
  }
}

class _FilaIntercambio extends StatelessWidget {
  const _FilaIntercambio(
    this.i, {
    required this.catalogo,
    required this.compacto,
  });

  final Intercambio i;
  final CatalogoEspecies? catalogo;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final otro = i.otro;
    // Desde mi punto de vista: si lo envié, doy el ofrecido.
    final doy = i.enviado ? i.ofrecido : i.aCambio;
    final recibo = i.enviado ? i.aCambio : i.ofrecido;
    final fechas = [
      if (i.creado case final f?) 'Creado el ${fechaCorta(f)}',
      if (i.aceptado case final f?) 'aceptado el ${fechaCorta(f)}',
      if (i.confirmado case final f?) 'confirmado el ${fechaCorta(f)}',
    ].join(' · ');

    final pokemon = Wrap(
      spacing: Espacio.l,
      runSpacing: Espacio.m,
      children: [
        _Lado('Das', doy, catalogo: catalogo),
        _Lado('Recibes', recibo, catalogo: catalogo),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Espacio.m),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Paleta.linea)),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Wrap(
            spacing: Espacio.m,
            runSpacing: Espacio.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Estado(i.estado),
              if (otro.userName case final nombre?)
                otro.id == null
                    ? Text('con $nombre', style: Tipos.cuerpo)
                    : TextButton(
                        onPressed: () => context.go(Rutas.usuario(otro.id!)),
                        child: Text('con $nombre'),
                      ),
            ],
          ),
          const SizedBox(height: Espacio.m),
          pokemon,
          if (fechas.isNotEmpty) ...[
            const SizedBox(height: Espacio.s),
            Text(fechas, style: Tipos.detalle(compacto: compacto)),
          ],
        ],
      ),
    );
  }
}

class _Lado extends StatelessWidget {
  const _Lado(this.etiqueta, this.p, {required this.catalogo});

  final String etiqueta;
  final PokemonIntercambio? p;
  final CatalogoEspecies? catalogo;

  @override
  Widget build(BuildContext context) {
    final especie = p?.idEspecie;
    final nombre = switch (p) {
      null => null,
      PokemonIntercambio(nombre: final n?) => capitalizar(n),
      _ when especie != null => catalogo?.nombre(especie) ?? '#$especie',
      _ => 'Pokémon',
    };
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          if (p != null && (p!.urlFrontal != null || especie != null))
            PixelSprite(
              url: p!.urlFrontal ?? urlSpriteEspecie(especie!),
              idEspecie: especie,
              nombre: nombre ?? '',
            )
          else
            const SizedBox(
              width: PixelSprite.ladoPokemon,
              height: PixelSprite.ladoPokemon,
              child: BloqueCargando(alto: PixelSprite.ladoPokemon),
            ),
          const SizedBox(width: Espacio.s),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  etiqueta.toUpperCase(),
                  style: Tipos.bitmap(16, color: Paleta.tenue),
                ),
                const SizedBox(height: Espacio.xs),
                Text(
                  nombre ?? 'Esperando respuesta',
                  style: nombre == null
                      ? Tipos.pequeno
                      : Tipos.cuerpo.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmado en rojo (se cumplió), aceptado en tinta, pendiente con
/// contorno y cancelado/rechazado apagado. El texto siempre va escrito.
class _Estado extends StatelessWidget {
  const _Estado(this.estado);

  final EstadoIntercambio? estado;

  @override
  Widget build(BuildContext context) {
    final (fondo, texto, borde) = switch (estado) {
      EstadoIntercambio.confirmed => (Paleta.rojo, Paleta.blanco, Paleta.rojo),
      EstadoIntercambio.accepted => (Paleta.tinta, Paleta.papel, Paleta.tinta),
      EstadoIntercambio.pending => (Paleta.papel, Paleta.tinta, Paleta.tinta),
      _ => (Paleta.papel, Paleta.tenue, Paleta.linea),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espacio.s, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde, width: Espacio.regla),
      ),
      child: Text(
        (estado?.etiqueta ?? 'Desconocido').toUpperCase(),
        style: Tipos.bitmap(16, color: texto),
      ),
    );
  }
}
