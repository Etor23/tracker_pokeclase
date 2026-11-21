import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../router.dart';
import '../session/session_controller.dart';
import '../theme/tokens.dart';

enum Seccion { ranking, yo, otro }

/// Marco de todas las pantallas con sesión: barra superior con marca,
/// navegación, búsqueda y usuario. En celular la navegación baja a una barra
/// inferior estándar.
class TrackerShell extends StatelessWidget {
  const TrackerShell({super.key, required this.seccion, required this.child});

  static const anchoEscritorio = 900.0;

  final Seccion seccion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final escritorio = ancho >= anchoEscritorio;
    return Scaffold(
      body: Column(
        children: [
          _Barra(seccion: seccion, escritorio: escritorio),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: escritorio
          ? null
          : DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Paleta.tinta, width: Espacio.regla),
                ),
              ),
              child: NavigationBar(
                selectedIndex: switch (seccion) {
                  Seccion.ranking => 0,
                  Seccion.yo => 1,
                  Seccion.otro => 0,
                },
                indicatorColor: seccion == Seccion.otro
                    ? Colors.transparent
                    : Paleta.rojo,
                onDestinationSelected: (i) =>
                    context.go(i == 0 ? Rutas.ranking : Rutas.yo),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.leaderboard_outlined),
                    label: 'Ranking',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Mi perfil',
                  ),
                ],
              ),
            ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.seccion, required this.escritorio});

  final Seccion seccion;
  final bool escritorio;

  void _buscar(BuildContext context, String texto) {
    final q = texto.trim();
    context.go(
      Uri(
        path: Rutas.ranking,
        queryParameters: q.isEmpty ? null : {'q': q},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().session;
    final margen = Espacio.margen(MediaQuery.sizeOf(context).width);
    return Container(
      height: escritorio ? 64 : 56,
      padding: EdgeInsets.symmetric(horizontal: margen),
      decoration: const BoxDecoration(
        color: Paleta.papel,
        border: Border(
          bottom: BorderSide(color: Paleta.tinta, width: Espacio.regla),
        ),
      ),
      child: Row(
        children: [
          _Marca(grande: escritorio),
          if (escritorio) ...[
            const SizedBox(width: Espacio.xl),
            _EnlaceNav(
              'Ranking',
              activo: seccion == Seccion.ranking,
              onTap: () => context.go(Rutas.ranking),
            ),
            _EnlaceNav(
              'Mi perfil',
              activo: seccion == Seccion.yo,
              onTap: () => context.go(Rutas.yo),
            ),
            const Spacer(),
            SizedBox(
              width: 280,
              child: TextField(
                onSubmitted: (t) => _buscar(context, t),
                textInputAction: .search,
                decoration: const InputDecoration(
                  hintText: 'Buscar jugador',
                  prefixIcon: Icon(Icons.search, color: Paleta.tinta),
                ),
              ),
            ),
            const SizedBox(width: Espacio.l),
            if (session != null)
              Text(
                session.userName,
                style: Tipos.dato,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(width: Espacio.s),
            TextButton(
              onPressed: context.read<SessionController>().logout,
              child: const Text('Salir'),
            ),
          ] else ...[
            const Spacer(),
            IconButton(
              tooltip: 'Buscar jugador',
              icon: const Icon(Icons.search),
              onPressed: () => context.go(Rutas.ranking),
            ),
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: context.read<SessionController>().logout,
            ),
          ],
        ],
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({required this.grande});

  final bool grande;

  @override
  Widget build(BuildContext context) {
    final tam = grande ? 24.0 : 16.0;
    return Semantics(
      link: true,
      label: 'Tracker Pokémon, ir al ranking',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.go(Rutas.ranking),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'TRACKER ', style: Tipos.bitmap(tam)),
                TextSpan(
                  text: 'POKÉMON',
                  style: Tipos.bitmap(tam, color: Paleta.rojo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnlaceNav extends StatelessWidget {
  const _EnlaceNav(this.texto, {required this.activo, required this.onTap});

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: Espacio.s),
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: activo ? Paleta.rojo : Paleta.tinta,
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: activo ? Paleta.rojo : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          texto,
          semanticsLabel: activo ? '$texto, sección actual' : texto,
        ),
      ),
    ),
  );
}
