import 'package:material_ui/material_ui.dart';

import '../theme/pokemon_colores.dart';
import '../theme/tokens.dart';

/// Piezas de la lámina de un Pokémon. Usan los colores en cuarentena (tipo y
/// salud): solo van dentro de una lámina o del detalle de un Pokémon.
///
/// En pantallas anchas los detalles van a 15 px para leerse en proyector.
bool esCompacto(BuildContext context) => MediaQuery.sizeOf(context).width < 900;

/// Etiqueta de un tipo (Agua, Hada…) sobre su color.
class ChipTipo extends StatelessWidget {
  const ChipTipo(this.tipo, {super.key});

  final String tipo;

  @override
  Widget build(BuildContext context) => Container(
    color: TiposPokemon.color(tipo),
    padding: const EdgeInsets.symmetric(horizontal: Espacio.s, vertical: 3),
    child: Text(TiposPokemon.nombre(tipo), style: Tipos.chip),
  );
}

/// Cuadro del color de salud más el estado escrito.
class MarcaSalud extends StatelessWidget {
  const MarcaSalud(this.salud, {super.key, required this.estado});

  final Salud salud;
  final String? estado;

  @override
  Widget build(BuildContext context) {
    // "Afectado" sin más no dice qué tiene: se muestra el estado real.
    final texto = salud == Salud.afectado && estado != null
        ? estado!
        : salud.etiqueta;
    return Row(
      mainAxisSize: .min,
      children: [
        Container(width: 8, height: 8, color: salud.color),
        const SizedBox(width: Espacio.s),
        Text(
          texto,
          style: Tipos.detalle(compacto: esCompacto(context))
              .copyWith(color: Paleta.tinta),
        ),
      ],
    );
  }
}

/// Barra a escala exacta del dato (sin redondeos decorativos).
class BarraDato extends StatelessWidget {
  const BarraDato(
    this.etiqueta, {
    super.key,
    required this.valor,
    required this.maximo,
    this.texto,
    this.color = Paleta.tinta,
  });

  final String etiqueta;
  final int valor;
  final int maximo;
  final String? texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final compacto = esCompacto(context);
    final fraccion = maximo <= 0 ? 0.0 : (valor / maximo).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(etiqueta, style: Tipos.detalle(compacto: compacto)),
          ),
          Expanded(
            child: Container(
              height: 8,
              color: Paleta.hueco,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraccion,
                child: Container(color: color),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              texto ?? '$valor',
              textAlign: TextAlign.right,
              style: Tipos.dato.copyWith(fontSize: compacto ? 14 : 15),
            ),
          ),
        ],
      ),
    );
  }
}
