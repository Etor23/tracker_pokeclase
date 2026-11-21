import 'package:flutter/foundation.dart';

import '../../core/carga.dart';
import '../../data/models/batalla.dart';
import '../../data/models/catalogo_especies.dart';
import '../../data/models/intercambio.dart';
import '../../data/models/mascota.dart';
import '../../data/models/objeto_mochila.dart';
import '../../data/models/pokedex_jugador.dart';
import '../../data/models/pokemon_jugador.dart';
import '../../data/models/resumen_jugador.dart';
import '../../data/tracker_repository.dart';

/// Datos del perfil de un jugador. Cada bloque carga y falla por separado,
/// para que un error en uno no tape los demás.
///
/// El resumen, el equipo y la Pokédex se piden al abrir el perfil (los usa la
/// pestaña Resumen). Lo demás se pide la primera vez que se abre su pestaña,
/// con los métodos `asegurar…`, que se pueden llamar desde `build`: no avisan
/// de forma síncrona.
class PerfilController extends ChangeNotifier {
  PerfilController(this._repo, this.userId, {required this.propio});

  final TrackerRepository _repo;
  final String userId;
  final bool propio;

  Carga<ResumenJugador> resumen = const Cargando();
  Carga<List<PokemonJugador>> pokemon = const Cargando();
  Carga<PokedexJugador> pokedex = const Cargando();

  Carga<List<ObjetoMochila>>? mochila;
  Carga<CatalogoEspecies>? catalogo;

  /// Ids de mis Pokémon reservados en un intercambio (solo en el propio).
  Carga<Set<int>>? reservados;

  /// Solo en el perfil propio: el backend solo da las del usuario actual.
  Carga<List<Mascota>>? mascotas;
  Carga<List<Intercambio>>? intercambios;
  EstadoIntercambio? filtroIntercambios;
  int _genIntercambios = 0;

  late final ListaBatallas batallas = ListaBatallas(_repo, userId);

  bool _disposed = false;

  /// Carga (o recarga, con el botón de actualizar) el perfil. Lo diferido se
  /// vuelve a pedir cuando su pestaña lo necesite.
  Future<void> cargar() async {
    resumen = const Cargando();
    pokemon = const Cargando();
    pokedex = const Cargando();
    mochila = null;
    reservados = null;
    mascotas = null;
    intercambios = null;
    batallas.reiniciar();
    _avisar();
    await Future.wait([
      _leer(_repo.resumen(userId), (c) => resumen = c),
      _leer(_repo.pokemon(userId), (c) => pokemon = c),
      _leer(_repo.pokedex(userId), (c) => pokedex = c),
    ]);
  }

  void asegurarMochila() {
    if (mochila != null) return;
    mochila = const Cargando();
    _leer(_repo.mochila(userId), (c) => mochila = c);
  }

  void asegurarCatalogo() {
    if (catalogo is Cargando || catalogo is Listo) return;
    catalogo = const Cargando();
    _leer(_repo.catalogo(), (c) => catalogo = c);
  }

  void asegurarReservados() {
    if (!propio || reservados != null) return;
    reservados = const Cargando();
    _leer(_repo.misReservados(), (c) => reservados = c);
  }

  void asegurarMascotas() {
    if (!propio || mascotas != null) return;
    mascotas = const Cargando();
    _leer(_repo.mascotas(), (c) => mascotas = c);
  }

  void reintentarMascotas() {
    mascotas = null;
    asegurarMascotas();
    _avisar();
  }

  void asegurarIntercambios() {
    if (!propio || intercambios != null) return;
    _cargarIntercambios();
  }

  void filtrarIntercambios(EstadoIntercambio? estado) {
    filtroIntercambios = estado;
    _cargarIntercambios();
    _avisar();
  }

  void reintentarIntercambios() {
    _cargarIntercambios();
    _avisar();
  }

  void _cargarIntercambios() {
    final gen = ++_genIntercambios;
    intercambios = const Cargando();
    _leer(_repo.intercambios(estado: filtroIntercambios), (c) {
      // Un filtro nuevo invalida la respuesta del anterior.
      if (gen == _genIntercambios) intercambios = c;
    });
  }

  void reintentarMochila() {
    mochila = null;
    asegurarMochila();
    _avisar();
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
    batallas.dispose();
    super.dispose();
  }
}

/// Batallas del jugador, de 20 en 20, con filtro por resultado.
class ListaBatallas extends ChangeNotifier {
  ListaBatallas(this._repo, this.userId);

  static const tamano = 20;

  final TrackerRepository _repo;
  final String userId;

  ResultadoBatalla? filtro;
  Carga<void>? estado;
  List<Batalla> filas = const [];
  int total = 0;
  bool cargandoMas = false;
  Object? errorMas;

  int _pagina = 0;
  int _generacion = 0;
  bool _disposed = false;

  bool get hayMas => filas.length < total;

  /// Pide la primera página si todavía no se pidió (seguro desde `build`).
  void asegurar() {
    if (estado == null) _cargar();
  }

  void filtrar(ResultadoBatalla? resultado) {
    if (resultado == filtro && estado != null) return;
    filtro = resultado;
    _cargar();
    _avisar();
  }

  void reintentar() {
    _cargar();
    _avisar();
  }

  void reiniciar() {
    _generacion++;
    estado = null;
    filas = const [];
    total = 0;
    cargandoMas = false;
    errorMas = null;
  }

  Future<void> _cargar() async {
    final gen = ++_generacion;
    estado = const Cargando();
    errorMas = null;
    try {
      final p = await _repo.batallas(userId, resultado: filtro, tamano: tamano);
      if (gen != _generacion) return;
      filas = p.filas;
      total = p.total;
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
      final p = await _repo.batallas(
        userId,
        pagina: _pagina + 1,
        resultado: filtro,
        tamano: tamano,
      );
      if (gen != _generacion) return;
      filas = [...filas, ...p.filas];
      total = p.total;
      _pagina++;
    } catch (e) {
      if (gen != _generacion) return;
      errorMas = e;
    } finally {
      if (gen == _generacion) cargandoMas = false;
      _avisar();
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
