import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/nota_vacia.dart';
import '../../core/widgets/tracker_shell.dart';

/// Marcador temporal para las pantallas que llegan en la Fase 2.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({
    super.key,
    required this.titulo,
    required this.seccion,
    this.detalle,
  });

  final String titulo;
  final Seccion seccion;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final margen = Espacio.margen(MediaQuery.sizeOf(context).width);
    return TrackerShell(
      seccion: seccion,
      child: ListView(
        padding: EdgeInsets.fromLTRB(margen, Espacio.l, margen, Espacio.xxl),
        children: [
          Semantics(header: true, child: Text(titulo, style: Tipos.bitmap(32))),
          const SizedBox(height: Espacio.l),
          NotaVacia(
            detalle == null
                ? 'Pantalla pendiente: $titulo.'
                : 'Pantalla pendiente: $titulo. $detalle',
          ),
        ],
      ),
    );
  }
}
