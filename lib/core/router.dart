import 'package:go_router/go_router.dart';

import '../data/models/ranking.dart';
import '../features/login/login_screen.dart';
import '../features/perfil/perfil_screen.dart';
import '../features/pokemon/pokemon_detalle_screen.dart';
import '../features/ranking/ranking_screen.dart';
import '../features/shared/no_encontrado_screen.dart';
import 'session/session_controller.dart';

/// Rutas de la app. Usar estos helpers en vez de armar strings a mano.
abstract final class Rutas {
  static const login = '/login';
  static const ranking = '/';
  static const yo = '/yo';

  static String usuario(String userId) =>
      '/usuario/${Uri.encodeComponent(userId)}';

  static String pokemon(String userId, int pokemonUserId) =>
      '${usuario(userId)}/pokemon/$pokemonUserId';
}

GoRouter createRouter(SessionController session) => GoRouter(
  // Abrir la app sin ruta entra a Mi perfil; un link compartido manda.
  initialLocation: Rutas.yo,
  refreshListenable: session,
  redirect: (context, state) => redirigirSegunSesion(
    autenticado: session.isAuthenticated,
    location: state.uri,
  ),
  errorBuilder: (context, state) => const NoEncontradoScreen(),
  routes: [
    GoRoute(
      path: Rutas.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Rutas.ranking,
      builder: (context, state) => RankingScreen(
        orden: OrdenRanking.desde(state.uri.queryParameters['orden']),
        busqueda: state.uri.queryParameters['q']?.trim() ?? '',
      ),
    ),
    GoRoute(
      path: '/usuario/:id',
      builder: (context, state) =>
          PerfilScreen(userId: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'pokemon/:pokemonUserId',
          builder: (context, state) => PokemonDetalleScreen(
            userId: state.pathParameters['id']!,
            pokemonUserId:
                int.tryParse(state.pathParameters['pokemonUserId']!) ?? -1,
          ),
        ),
      ],
    ),
    GoRoute(
      path: Rutas.yo,
      builder: (context, state) => const PerfilScreen.propio(),
    ),
  ],
);

/// Sin sesión → `/login?from=<ruta pedida>`. Con sesión en `/login` → vuelve
/// a `from` (solo rutas internas) o a Mi perfil, porque el progreso personal
/// es lo primero (PRODUCT.md).
String? redirigirSegunSesion({
  required bool autenticado,
  required Uri location,
}) {
  final enLogin = location.path == Rutas.login;
  if (!autenticado) {
    if (enLogin) return null;
    return Uri(
      path: Rutas.login,
      queryParameters: {'from': location.toString()},
    ).toString();
  }
  if (enLogin) return rutaInternaSegura(location.queryParameters['from']);
  return null;
}

/// Evita redirecciones abiertas: solo se aceptan rutas que empiezan con una
/// sola `/` y que no regresan al login.
String rutaInternaSegura(String? from) {
  if (from == null ||
      !from.startsWith('/') ||
      from.startsWith('//') ||
      from.startsWith(Rutas.login)) {
    return Rutas.yo;
  }
  return from;
}
