import 'package:material_ui/material_ui.dart';

import '../../core/widgets/tracker_shell.dart';
import '../shared/en_construccion.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const EnConstruccion(titulo: 'Ranking', seccion: Seccion.ranking);
}
