import 'package:material_ui/material_ui.dart';

import '../api/api_exception.dart';
import '../theme/tokens.dart';
import 'nota_vacia.dart';

/// Pie de una lista por páginas: "Cargar más" y cuántos se muestran.
class PiePaginado extends StatelessWidget {
  const PiePaginado({
    super.key,
    required this.mostrados,
    required this.total,
    required this.cargando,
    required this.error,
    required this.alCargarMas,
  });

  final int mostrados;
  final int total;
  final bool cargando;
  final Object? error;
  final VoidCallback alCargarMas;

  @override
  Widget build(BuildContext context) {
    final conteo = Text('Mostrando $mostrados de $total', style: Tipos.pequeno);
    if (error case final e?) {
      return NotaVacia(
        mensajeParaUsuario(e),
        accion: OutlinedButton(
          onPressed: alCargarMas,
          child: const Text('REINTENTAR'),
        ),
      );
    }
    if (mostrados >= total) return conteo;
    return Row(
      children: [
        OutlinedButton(
          onPressed: cargando ? null : alCargarMas,
          child: Text(cargando ? 'CARGANDO…' : 'CARGAR MÁS'),
        ),
        const SizedBox(width: Espacio.m),
        conteo,
      ],
    );
  }
}
