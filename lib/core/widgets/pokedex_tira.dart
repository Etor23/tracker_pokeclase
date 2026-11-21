import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// La Pokédex completa como tira de celdas: una por especie (1..[total]),
/// rojas las registradas. Es el dato, no una barra decorativa.
///
/// Al aparecer, un cursor la recorre una vez y voltea cada celda al pasar (el
/// único momento de movimiento del perfil). Respeta "reducir movimiento".
class PokedexTira extends StatefulWidget {
  const PokedexTira({super.key, required this.total, required this.registrada});

  final int total;
  final bool Function(int idEspecie) registrada;

  @override
  State<PokedexTira> createState() => _PokedexTiraState();
}

class _PokedexTiraState extends State<PokedexTira>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barrido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _barrido.value = 1;
    } else if (_barrido.isDismissed) {
      _barrido.forward();
    }
  }

  @override
  void dispose() {
    _barrido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registradas = [
      for (var i = 1; i <= widget.total; i++)
        if (widget.registrada(i)) i,
    ];
    return Semantics(
      label:
          'Pokédex: ${registradas.length} de ${widget.total} especies de la generación registradas',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final malla = _Malla.para(widget.total, constraints.maxWidth);
          return SizedBox(
            height: malla.alto,
            width: constraints.maxWidth,
            child: AnimatedBuilder(
              animation: _barrido,
              builder: (context, _) => CustomPaint(
                painter: _TiraPainter(
                  malla: malla,
                  total: widget.total,
                  registradas: registradas.toSet(),
                  avance: _barrido.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Celdas enteras: cuantas filas hagan falta para que cada celda mida al
/// menos 8 px (que se lea como celda, no como línea punteada), con 2 px de
/// separación.
class _Malla {
  const _Malla(this.columnas, this.filas, this.celda, this.ancho);

  factory _Malla.para(int total, double ancho) {
    const minimo = 8, hueco = _TiraPainter.hueco;
    final filas = math.max(
      1,
      (total * (minimo + hueco) / (ancho + hueco)).ceil(),
    );
    final columnas = (total / filas).ceil();
    final celda = math.max(2, ((ancho + hueco) / columnas).floor() - hueco);
    return _Malla(columnas, filas, celda.toDouble(), ancho);
  }

  final int columnas;
  final int filas;
  final double celda;
  final double ancho;

  /// x entero de cada columna: el sobrante se reparte en los huecos (unos
  /// miden 1 px más) para que la última celda cierre en el borde derecho.
  double x(int columna) => columnas <= 1
      ? 0
      : (columna * (ancho.floorToDouble() - celda) / (columnas - 1))
            .roundToDouble();

  double y(int fila) => fila * (celda + _TiraPainter.hueco);

  double get alto => filas * (celda + _TiraPainter.hueco) - _TiraPainter.hueco;
}

class _TiraPainter extends CustomPainter {
  _TiraPainter({
    required this.malla,
    required this.total,
    required this.registradas,
    required this.avance,
  });

  static const hueco = 2;

  final _Malla malla;
  final int total;
  final Set<int> registradas;
  final double avance;

  @override
  void paint(Canvas canvas, Size size) {
    final vacia = Paint()..color = Paleta.tintaSuave.withValues(alpha: 0.45);
    final llena = Paint()..color = Paleta.rojo;
    final pendiente = Paint()..color = Paleta.linea;
    final cursor = Paint()..color = Paleta.tinta;
    final hasta = (avance * total).floor();

    for (var i = 0; i < total; i++) {
      final rect = Rect.fromLTWH(
        malla.x(i % malla.columnas),
        malla.y(i ~/ malla.columnas),
        malla.celda,
        malla.celda,
      );
      if (avance < 1 && i == hasta) {
        canvas.drawRect(rect, cursor);
      } else if (avance < 1 && i > hasta) {
        _trama(canvas, rect, pendiente);
      } else if (registradas.contains(i + 1)) {
        canvas.drawRect(rect, llena);
      } else {
        _trama(canvas, rect, vacia);
      }
    }
  }

  /// Celda no registrada: damero de cuadros de 2 px (la trama del mundo).
  void _trama(Canvas canvas, Rect celda, Paint pincel) {
    for (var dy = 0.0; dy < celda.height; dy += 2) {
      final desfase = (dy ~/ 2).isEven ? 0.0 : 2.0;
      for (var dx = desfase; dx < celda.width; dx += 4) {
        canvas.drawRect(
          Rect.fromLTWH(
            celda.left + dx,
            celda.top + dy,
            math.min(2, celda.width - dx),
            math.min(2, celda.height - dy),
          ),
          pincel,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TiraPainter old) =>
      old.avance != avance ||
      old.total != total ||
      old.malla.celda != malla.celda ||
      old.malla.ancho != malla.ancho ||
      old.registradas.length != registradas.length;
}
