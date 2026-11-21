import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/router.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/fila_cifras.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pie_paginado.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/batalla.dart';
import '../../data/models/catalogo_especies.dart';
import 'perfil_controller.dart';

/// Pestaña Batallas: cifras del resumen, filtro por resultado y la lista de
/// la más reciente a la más antigua, de 20 en 20.
///
/// El encabezado usa `batallas` del resumen del jugador: el endpoint
/// `/api/Batallas/usuario/{id}/resumen` responde 500 (ver docs/CLAUDE.md).
class BatallasTab extends StatelessWidget {
  const BatallasTab({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()..asegurarCatalogo();
    final lista = perfil.batallas;
    final compacto = MediaQuery.sizeOf(context).width < 700;
    return ListenableBuilder(
      listenable: lista,
      builder: (context, _) {
        lista.asegurar();
        final catalogo = perfil.catalogo?.valorOrNull;
        return Column(
          crossAxisAlignment: .stretch,
          children: [
            if (perfil.resumen.valorOrNull?.batallas case final b?) ...[
              FilaCifras(compacta: compacto, [
                Cifra('Victorias', '${b.victorias}', 'Ganadas'),
                Cifra('Derrotas', '${b.derrotas}', 'Perdidas'),
                Cifra('Huidas', '${b.huidas}', 'No cuentan en el win rate'),
                Cifra(
                  'Win rate',
                  porcentaje(b.winRate, pegado: true),
                  b.victorias + b.derrotas == 0
                      ? 'Sin victorias ni derrotas'
                      : '${b.victorias} de ${b.victorias + b.derrotas} decididas',
                ),
              ]),
              const SizedBox(height: Espacio.l),
            ],
            Semantics(
              label: 'Filtrar por resultado',
              container: true,
              child: Wrap(
                spacing: Espacio.s,
                runSpacing: Espacio.s,
                children: [
                  for (final (r, texto) in [
                    (null, 'Todas'),
                    (ResultadoBatalla.victoria, 'Victorias'),
                    (ResultadoBatalla.derrota, 'Derrotas'),
                    (ResultadoBatalla.huida, 'Huidas'),
                  ])
                    ChoiceChip(
                      label: Text(
                        texto,
                        style: Tipos.chipOrden.copyWith(
                          color: lista.filtro == r
                              ? Paleta.blanco
                              : Paleta.tinta,
                        ),
                      ),
                      selected: lista.filtro == r,
                      onSelected: (_) => lista.filtrar(r),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Espacio.l),
            ...switch (lista.estado) {
              null || Cargando() => [const BloqueCargando(alto: 240)],
              Fallo(:final error) => [
                NotaVacia(
                  mensajeParaUsuario(error),
                  accion: OutlinedButton(
                    onPressed: lista.reintentar,
                    child: const Text('REINTENTAR'),
                  ),
                ),
              ],
              Listo() when lista.filas.isEmpty => [
                NotaVacia(switch (lista.filtro) {
                  null => 'Aún no hay batallas registradas. Aparecen aquí al pelear en el juego.',
                  ResultadoBatalla.victoria => 'Ninguna victoria todavía.',
                  ResultadoBatalla.derrota => 'Ninguna derrota todavía.',
                  ResultadoBatalla.huida => 'Ninguna huida todavía.',
                }),
              ],
              Listo() => [
                for (final b in lista.filas)
                  _FilaBatalla(
                    b,
                    userId: perfil.userId,
                    catalogo: catalogo,
                    compacto: compacto,
                  ),
                const SizedBox(height: Espacio.l),
                PiePaginado(
                  mostrados: lista.filas.length,
                  total: lista.total,
                  cargando: lista.cargandoMas,
                  error: lista.errorMas,
                  alCargarMas: lista.cargarMas,
                ),
              ],
            },
          ],
        );
      },
    );
  }
}

class _FilaBatalla extends StatelessWidget {
  const _FilaBatalla(
    this.batalla, {
    required this.userId,
    required this.catalogo,
    required this.compacto,
  });

  final Batalla batalla;
  final String userId;
  final CatalogoEspecies? catalogo;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final b = batalla;
    final mio = capitalizar(b.pokemon.nombre);
    final rival = switch (b.idEspecieRival) {
      final id? => catalogo?.nombre(id) ?? '#${numeroEspecie(id)}',
      null => 'Rival desconocido',
    };
    final fecha = b.fecha == null
        ? 'Sin fecha'
        : '${fechaCorta(b.fecha!)} · ${horaCorta(b.fecha!)}';

    final duelo = Row(
      children: [
        Expanded(
          child: _Combatiente(
            nombre: mio,
            url: b.pokemon.urlFrontal ?? urlSpriteEspecie(b.pokemon.idEspecie),
            idEspecie: b.pokemon.idEspecie,
            apilado: compacto,
            alTocar: () => context.go(Rutas.pokemon(userId, b.pokemon.id)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacio.s),
          child: Text('VS', style: Tipos.bitmap(16, color: Paleta.tenue)),
        ),
        Expanded(
          child: b.idEspecieRival == null
              ? Text(rival, style: Tipos.pequeno)
              : _Combatiente(
                  nombre: rival,
                  url: urlSpriteEspecie(b.idEspecieRival!),
                  idEspecie: b.idEspecieRival!,
                  apilado: compacto,
                ),
        ),
      ],
    );

    return Semantics(
      label:
          '${b.resultado?.valor ?? 'Resultado desconocido'}: $mio contra $rival, $fecha',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Espacio.m),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Paleta.linea)),
        ),
        child: compacto
            ? Column(
                crossAxisAlignment: .stretch,
                children: [
                  Row(
                    children: [
                      _Resultado(b.resultado),
                      const Spacer(),
                      Text(fecha, style: Tipos.pequeno),
                    ],
                  ),
                  const SizedBox(height: Espacio.s),
                  duelo,
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(fecha, style: Tipos.cuerpoSuave),
                  ),
                  SizedBox(
                    width: 140,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _Resultado(b.resultado),
                    ),
                  ),
                  // Ancho máximo para que el "VS" no quede en un hueco.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: duelo,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Victoria en tinta, derrota en rojo, huida con contorno. El texto siempre
/// va escrito: el color nunca es la única señal.
class _Resultado extends StatelessWidget {
  const _Resultado(this.resultado);

  final ResultadoBatalla? resultado;

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, tinta, borde) = switch (resultado) {
      ResultadoBatalla.victoria => (
        'VICTORIA',
        Paleta.tinta,
        Paleta.papel,
        Paleta.tinta,
      ),
      ResultadoBatalla.derrota => (
        'DERROTA',
        Paleta.rojo,
        Paleta.blanco,
        Paleta.rojo,
      ),
      ResultadoBatalla.huida => (
        'HUIDA',
        Paleta.papel,
        Paleta.tinta,
        Paleta.tinta,
      ),
      null => ('¿?', Paleta.papel, Paleta.tenue, Paleta.linea),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espacio.s, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde, width: Espacio.regla),
      ),
      child: Text(texto, style: Tipos.bitmap(16, color: tinta)),
    );
  }
}

class _Combatiente extends StatelessWidget {
  const _Combatiente({
    required this.nombre,
    required this.url,
    required this.idEspecie,
    required this.apilado,
    this.alTocar,
  });

  /// En celular el nombre va debajo del sprite para no partirse.
  final bool apilado;

  final String nombre;
  final String url;
  final int idEspecie;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final sprite = PixelSprite(url: url, idEspecie: idEspecie, nombre: nombre);
    final texto = Text(
      nombre,
      style: Tipos.cuerpo.copyWith(fontWeight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final contenido = apilado
        ? Column(
            crossAxisAlignment: .start,
            children: [
              sprite,
              const SizedBox(height: Espacio.xs),
              texto,
            ],
          )
        : Row(
            children: [
              sprite,
              const SizedBox(width: Espacio.s),
              Flexible(child: texto),
            ],
          );
    return alTocar == null
        ? contenido
        : InkWell(onTap: alTocar, child: contenido);
  }
}
