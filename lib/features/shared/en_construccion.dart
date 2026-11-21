import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/router.dart';
import '../../core/session/session_controller.dart';

/// Marcador temporal para las pantallas de la Fase 2.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({super.key, required this.titulo, this.detalle});

  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().session;
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          TextButton(
            onPressed: () => context.go(Rutas.ranking),
            child: const Text('Ranking'),
          ),
          TextButton(
            onPressed: () => context.go(Rutas.yo),
            child: const Text('Mi perfil'),
          ),
          TextButton(
            onPressed: context.read<SessionController>().logout,
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Text('Pantalla pendiente: $titulo'),
            if (detalle case final d?) Text(d),
            if (session != null)
              Text('Sesión: ${session.userName} (${session.userId})'),
          ],
        ),
      ),
    );
  }
}
