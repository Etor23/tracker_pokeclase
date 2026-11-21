import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router.dart';

class NoEncontradoScreen extends StatelessWidget {
  const NoEncontradoScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          const Text('Esta página no existe.'),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(Rutas.ranking),
            child: const Text('Ir al ranking'),
          ),
        ],
      ),
    ),
  );
}
