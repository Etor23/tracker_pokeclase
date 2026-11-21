import 'package:flutter/foundation.dart';

import '../../core/carga.dart';
import '../../data/models/pokedex_jugador.dart';
import '../../data/models/pokemon_jugador.dart';
import '../../data/models/resumen_jugador.dart';
import '../../data/tracker_repository.dart';

/// Datos del perfil de un jugador. Cada bloque carga y falla por separado,
/// para que un error en uno no tape los demás.
class PerfilController extends ChangeNotifier {
  PerfilController(this._repo, this.userId);

  final TrackerRepository _repo;
  final String userId;

  Carga<ResumenJugador> resumen = const Cargando();
  Carga<List<PokemonJugador>> pokemon = const Cargando();
  Carga<PokedexJugador> pokedex = const Cargando();

  bool _disposed = false;

  /// Carga (o recarga, con el botón de actualizar) el resumen y lo que muestra
  /// la pestaña Resumen.
  Future<void> cargar() async {
    resumen = const Cargando();
    pokemon = const Cargando();
    pokedex = const Cargando();
    _avisar();
    await Future.wait([
      _leer(_repo.resumen(userId), (c) => resumen = c),
      _leer(_repo.pokemon(userId), (c) => pokemon = c),
      _leer(_repo.pokedex(userId), (c) => pokedex = c),
    ]);
  }

  Future<void> _leer<T>(
    Future<T> futuro,
    void Function(Carga<T>) guardar,
  ) async {
    try {
      guardar(Listo(await futuro));
    } catch (e) {
      guardar(Fallo(e));
    }
    _avisar();
  }

  void _avisar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
