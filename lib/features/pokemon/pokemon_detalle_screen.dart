import 'package:material_ui/material_ui.dart';

import '../../core/widgets/tracker_shell.dart';
import '../shared/en_construccion.dart';

class PokemonDetalleScreen extends StatelessWidget {
  const PokemonDetalleScreen({
    super.key,
    required this.userId,
    required this.pokemonUserId,
  });

  final String userId;
  final int pokemonUserId;

  @override
  Widget build(BuildContext context) =>
      const EnConstruccion(titulo: 'Detalle de Pokémon', seccion: Seccion.otro);
}
