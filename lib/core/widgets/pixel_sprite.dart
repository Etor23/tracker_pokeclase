import 'package:material_ui/material_ui.dart';

import '../formato.dart';
import '../theme/tokens.dart';
import 'trama.dart';

/// Sprite de PokeAPI (96 × 96) escalado solo en múltiplos enteros y sin
/// suavizar: el movimiento característico del mundo bitmap.
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.url,
    required this.idEspecie,
    required this.nombre,
    this.escala = 1,
    this.atenuado = false,
  }) : assert(escala >= 1);

  static const lado = 96.0;

  final String url;
  final int idEspecie;
  final String nombre;
  final int escala;

  /// Silueta gris (Pokédex no registrada o crianza muerta).
  final bool atenuado;

  @override
  Widget build(BuildContext context) {
    final tam = lado * escala;
    Widget imagen = Image.network(
      url,
      width: tam,
      height: tam,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      semanticLabel: nombre,
      errorBuilder: (context, error, stack) => Center(
        child: Text(
          '#${numeroEspecie(idEspecie)}',
          style: Tipos.bitmap(16, color: Paleta.tenue),
        ),
      ),
    );
    if (atenuado) {
      imagen = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          0.45,
          0,
        ]),
        child: imagen,
      );
    }
    // Fondo con la trama del mundo: el hueco donde va el sprite.
    return Container(
      width: tam,
      height: tam,
      color: Paleta.hueco,
      child: CustomPaint(painter: const TramaPainter(), child: imagen),
    );
  }
}
