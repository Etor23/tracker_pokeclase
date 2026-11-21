import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/carga.dart';
import '../../core/formato.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/pixel_sprite.dart';
import '../../data/models/objeto_mochila.dart';
import 'perfil_controller.dart';

/// Pestaña Mochila: objetos con su cantidad, de más a menos.
class MochilaTab extends StatelessWidget {
  const MochilaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilController>()..asegurarMochila();
    final compacto = MediaQuery.sizeOf(context).width < 700;
    return switch (perfil.mochila) {
      null || Cargando() => const BloqueCargando(alto: 240),
      Fallo(:final error) => NotaVacia(
        mensajeParaUsuario(error),
        accion: OutlinedButton(
          onPressed: perfil.reintentarMochila,
          child: const Text('REINTENTAR'),
        ),
      ),
      Listo(valor: final lista) when lista.isEmpty => const NotaVacia(
        'La mochila está vacía. Los objetos aparecen aquí al conseguirlos en el juego.',
      ),
      Listo(valor: final lista) => Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(
            '${lista.fold<int>(0, (s, o) => s + o.cantidad)} objetos · '
            '${lista.length} distintos',
            style: Tipos.detalle(compacto: compacto),
          ),
          const SizedBox(height: Espacio.m),
          const FranjaTitulo('Mochila'),
          for (final o in [
            ...lista,
          ]..sort((a, b) => b.cantidad.compareTo(a.cantidad)))
            _FilaObjeto(o, compacto: compacto),
        ],
      ),
    };
  }
}

class _FilaObjeto extends StatelessWidget {
  const _FilaObjeto(this.objeto, {required this.compacto});

  final ObjetoMochila objeto;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final o = objeto;
    final nombre = nombreDeObjeto(o.nombre);
    final tipo = [
      if (o.esPokebola) 'Pokébola',
      if (o.esPokebola && o.multiplicadorCaptura != null)
        'captura ×${_numero(o.multiplicadorCaptura!)}',
    ].join(' · ');
    return Semantics(
      label:
          '$nombre, ${o.cantidad} en la mochila${tipo.isEmpty ? '' : ', $tipo'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Espacio.m),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Paleta.linea)),
        ),
        child: Row(
          crossAxisAlignment: .start,
          children: [
            if (o.urlImagen case final url?)
              PixelSprite(
                url: url,
                nombre: nombre,
                lado: PixelSprite.ladoObjeto,
                escala: 2,
              )
            else
              const SizedBox(width: PixelSprite.ladoObjeto * 2),
            const SizedBox(width: Espacio.m),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(nombre, style: Tipos.titulo.copyWith(fontSize: 18)),
                  if (tipo.isNotEmpty) ...[
                    const SizedBox(height: Espacio.xs),
                    Text(tipo, style: Tipos.detalle(compacto: compacto)),
                  ],
                  if (o.descripcion case final d? when d.trim().isNotEmpty) ...[
                    const SizedBox(height: Espacio.xs),
                    // El backend guarda las descripciones en inglés.
                    Text(
                      d.trim(),
                      style: Tipos.pequeno,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Espacio.m),
            Text('×${o.cantidad}', style: Tipos.bitmap(compacto ? 24 : 32)),
          ],
        ),
      ),
    );
  }

  static String _numero(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}
