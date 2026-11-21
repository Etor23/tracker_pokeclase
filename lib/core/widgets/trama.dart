import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';

/// Trama de puntos del mundo bitmap: cuadros de 2 px en retícula de 6 px,
/// desfasados fila por fila. Es la textura de lo vacío o lo pendiente.
class TramaPainter extends CustomPainter {
  const TramaPainter({this.color = Paleta.linea});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += 6) {
      for (var x = (y ~/ 6).isEven ? 0.0 : 3.0; x < size.width; x += 6) {
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(TramaPainter oldDelegate) => oldDelegate.color != color;
}
