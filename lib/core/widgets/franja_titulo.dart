import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Encabezado de sección: franja de tinta con etiqueta bitmap en papel.
class FranjaTitulo extends StatelessWidget {
  const FranjaTitulo(this.texto, {super.key, this.detalle});

  final String texto;

  /// Texto opcional a la derecha (por ejemplo, un conteo).
  final String? detalle;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Container(
      height: 40,
      color: Paleta.tinta,
      padding: const EdgeInsets.symmetric(horizontal: Espacio.m),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto.toUpperCase(),
              style: Tipos.bitmap(16, color: Paleta.papel),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (detalle case final d?)
            Text(d, style: Tipos.bitmap(16, color: Paleta.papel)),
        ],
      ),
    ),
  );
}
