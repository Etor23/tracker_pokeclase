import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/session/session_controller.dart';
import '../shared/en_construccion.dart';

/// Perfil de un jugador (`/usuario/:id`) o el propio (`/yo`, con las pestañas
/// extra de Tamagotchi e Intercambios).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, required String this.userId})
    : esPropio = false;

  const PerfilScreen.propio({super.key}) : userId = null, esPropio = true;

  /// `null` en `/yo`: se toma el id de la sesión.
  final String? userId;
  final bool esPropio;

  @override
  Widget build(BuildContext context) {
    final id = userId ?? context.watch<SessionController>().session?.userId;
    return EnConstruccion(
      titulo: esPropio ? 'Mi perfil' : 'Perfil',
      detalle: 'userId: $id',
    );
  }
}
