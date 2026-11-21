import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Una cifra con su etiqueta bitmap y un detalle que le da sentido.
class Cifra {
  const Cifra(this.etiqueta, this.valor, this.detalle);

  final String etiqueta;
  final String valor;
  final String detalle;
}

/// Fila de cifras bajo una regla de tinta: 4 columnas, o 2 en [compacta].
/// Es un Table para que las celdas de una fila midan lo mismo y los divisores
/// corran completos.
class FilaCifras extends StatelessWidget {
  const FilaCifras(this.cifras, {super.key, required this.compacta});

  final List<Cifra> cifras;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final columnas = compacta ? 2 : 4;
    final valor = compacta ? 32.0 : 48.0;
    final filas = [
      for (var i = 0; i < cifras.length; i += columnas)
        [
          for (var j = i; j < i + columnas; j++)
            j < cifras.length ? cifras[j] : null,
        ],
    ];
    return Table(
      border: const TableBorder(
        top: BorderSide(color: Paleta.tinta, width: Espacio.regla),
        verticalInside: BorderSide(color: Paleta.linea),
        horizontalInside: BorderSide(color: Paleta.linea),
      ),
      children: [
        for (final fila in filas)
          TableRow(
            children: [
              for (final (i, c) in fila.indexed)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    i == 0 ? 0 : Espacio.m,
                    Espacio.m,
                    Espacio.m,
                    Espacio.m,
                  ),
                  child: c == null
                      ? const SizedBox.shrink()
                      : _Celda(c, tam: valor, compacta: compacta),
                ),
            ],
          ),
      ],
    );
  }
}

class _Celda extends StatelessWidget {
  const _Celda(this.c, {required this.tam, required this.compacta});

  final Cifra c;
  final double tam;
  final bool compacta;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${c.etiqueta}: ${c.valor}. ${c.detalle}',
    excludeSemantics: true,
    child: Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          c.etiqueta.toUpperCase(),
          style: Tipos.bitmap(16, color: Paleta.tintaSuave),
        ),
        const SizedBox(height: Espacio.s + 4),
        Text(c.valor, style: Tipos.bitmap(tam)),
        const SizedBox(height: Espacio.s),
        Text(c.detalle, style: Tipos.detalle(compacto: compacta)),
      ],
    ),
  );
}
