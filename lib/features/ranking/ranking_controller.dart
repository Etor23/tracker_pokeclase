import 'package:flutter/foundation.dart';

import '../../core/carga.dart';
import '../../data/models/ranking.dart';
import '../../data/tracker_repository.dart';

/// Estado del ranking: orden, búsqueda y las filas cargadas página a página.
class RankingController extends ChangeNotifier {
  RankingController(
    this._repo, {
    required this.orden,
    required this.busqueda,
    required this.miId,
  });

  static const tamano = 20;

  final TrackerRepository _repo;

  /// Id del usuario actual: de su resumen sale el total de la Pokédex.
  final String? miId;

  OrdenRanking orden;
  String busqueda;

  /// Estado de la primera página (la lista completa se recarga).
  Carga<void> estado = const Cargando();
  List<FilaRanking> filas = const [];
  int total = 0;

  bool cargandoMas = false;
  Object? errorMas;

  /// Total de especies de la Pokédex (lo da el backend, no se escribe fijo).
  int? totalPokedex;

  int _pagina = 0;

  /// Sube con cada recarga para descartar respuestas viejas (por ejemplo, de
  /// una búsqueda que ya se reemplazó mientras se escribía).
  int _generacion = 0;
  bool _disposed = false;

  bool get hayMas => filas.length < total;
  bool get buscando => busqueda.isNotEmpty;

  Future<void> cargar() async {
    final gen = ++_generacion;
    estado = const Cargando();
    errorMas = null;
    _avisar();
    if (totalPokedex == null && miId != null) _cargarTotalPokedex();
    try {
      final pagina = await _repo.ranking(
        orden: orden,
        busqueda: busqueda,
        tamano: tamano,
      );
      if (gen != _generacion) return;
      filas = pagina.filas;
      total = pagina.total;
      _pagina = 1;
      estado = const Listo(null);
    } catch (e) {
      if (gen != _generacion) return;
      estado = Fallo(e);
    }
    _avisar();
  }

  Future<void> cargarMas() async {
    if (cargandoMas || !hayMas) return;
    final gen = _generacion;
    cargandoMas = true;
    errorMas = null;
    _avisar();
    try {
      final pagina = await _repo.ranking(
        orden: orden,
        busqueda: busqueda,
        pagina: _pagina + 1,
        tamano: tamano,
      );
      if (gen != _generacion) return;
      filas = [...filas, ...pagina.filas];
      total = pagina.total;
      _pagina++;
    } catch (e) {
      if (gen != _generacion) return;
      errorMas = e;
    } finally {
      if (gen == _generacion) cargandoMas = false;
      _avisar();
    }
  }

  /// Aplica el orden y la búsqueda que vienen de la URL.
  void aplicar({required OrdenRanking orden, required String busqueda}) {
    if (orden == this.orden && busqueda == this.busqueda) return;
    this.orden = orden;
    this.busqueda = busqueda;
    cargar();
  }

  Future<void> _cargarTotalPokedex() async {
    try {
      final r = await _repo.resumen(miId!);
      totalPokedex = r.pokedex.total;
      _avisar();
    } catch (_) {
      // Sin el total, el ranking muestra solo el número de especies.
    }
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
