import 'package:material_ui/material_ui.dart';

import '../theme/tokens.dart';
import 'trama.dart';

/// Explica un dato vacío, pendiente o fallido. Borde de pixeles sueltos (la
/// trama del mundo) y un cuadro rojo como marcador.
class NotaVacia extends StatelessWidget {
  const NotaVacia(this.mensaje, {super.key, this.accion});

  final String mensaje;

  /// Botón opcional, por ejemplo "Reintentar".
  final Widget? accion;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _BordePixel(),
    child: Padding(
      padding: const EdgeInsets.all(Espacio.m),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7, right: Espacio.s + 4),
            color: Paleta.rojo,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(mensaje, style: Tipos.cuerpoSuave),
                if (accion case final a?) ...[
                  const SizedBox(height: Espacio.s + 4),
                  a,
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Borde de cuadros de 2 px separados 2 px: una línea punteada de pixeles.
class _BordePixel extends CustomPainter {
  const _BordePixel();

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()..color = Paleta.tintaSuave;
    const lado = 2.0;
    const paso = 4.0;
    for (var x = 0.0; x <= size.width - lado; x += paso) {
      canvas
        ..drawRect(Rect.fromLTWH(x, 0, lado, lado), pincel)
        ..drawRect(Rect.fromLTWH(x, size.height - lado, lado, lado), pincel);
    }
    for (var y = paso; y <= size.height - lado - paso; y += paso) {
      canvas
        ..drawRect(Rect.fromLTWH(0, y, lado, lado), pincel)
        ..drawRect(Rect.fromLTWH(size.width - lado, y, lado, lado), pincel);
    }
  }

  @override
  bool shouldRepaint(_BordePixel oldDelegate) => false;
}

/// Bloque de espera con trama de puntos, del tamaño del contenido que llega.
class BloqueCargando extends StatelessWidget {
  const BloqueCargando({super.key, this.alto = 48, this.ancho});

  final double alto;
  final double? ancho;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando',
    child: SizedBox(
      height: alto,
      width: ancho,
      child: const CustomPaint(painter: TramaPainter()),
    ),
  );
}
