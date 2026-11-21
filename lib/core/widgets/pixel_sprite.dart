import 'package:material_ui/material_ui.dart';

import '../formato.dart';
import '../theme/tokens.dart';
import 'trama.dart';

/// Sprite de PokeAPI escalado solo en múltiplos enteros y sin suavizar: el
/// movimiento característico del mundo bitmap. Los de Pokémon miden 96 × 96
/// y los de objetos 30 × 30 ([lado]).
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.url,
    this.idEspecie,
    required this.nombre,
    this.escala = 1,
    this.lado = ladoPokemon,
    this.atenuado = false,
    this.silueta = false,
  }) : assert(escala >= 1);

  static const ladoPokemon = 96.0;
  static const ladoObjeto = 30.0;

  /// Tamaño original del sprite, en pixeles.
  final double lado;

  final String url;

  /// Para el texto de respaldo si la imagen no carga ("#025").
  final int? idEspecie;
  final String nombre;
  final int escala;

  /// Gris y translúcido (crianza muerta).
  final bool atenuado;

  /// Silueta plana gris, sin detalle (especie no registrada en la Pokédex).
  final bool silueta;

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
        child: idEspecie == null
            ? const Icon(
                Icons.image_not_supported_outlined,
                color: Paleta.tenue,
              )
            : Text(
                '#${numeroEspecie(idEspecie!)}',
                style: Tipos.bitmap(16, color: Paleta.tenue),
              ),
      ),
    );
    if (silueta) {
      imagen = ColorFiltered(
        colorFilter: const ColorFilter.mode(Paleta.linea, BlendMode.srcIn),
        child: imagen,
      );
    } else if (atenuado) {
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
