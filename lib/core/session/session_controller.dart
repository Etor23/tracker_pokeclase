import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/json.dart';
import 'session.dart';
import 'session_store.dart';

enum MotivoFinSesion { cerrada, expirada }

/// Estado de la sesión. El router lo escucha para redirigir a `/login`.
///
/// La expiración se revisa al leer [session] (al navegar y antes de cada
/// petición), así que no hace falta un temporizador.
class SessionController extends ChangeNotifier {
  SessionController({required this._store, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final SessionStore _store;
  final DateTime Function() _clock;
  Session? _session;
  MotivoFinSesion? _ultimoMotivo;

  /// La sesión vigente, o `null` si no hay o ya expiró.
  Session? get session {
    final s = _session;
    if (s == null || s.isExpiredAt(_clock().toUtc())) return null;
    return s;
  }

  bool get isAuthenticated => session != null;

  String? get token => session?.token;

  /// Por qué terminó la última sesión (para avisar en el login).
  MotivoFinSesion? get ultimoMotivo => _ultimoMotivo;

  /// Recupera la sesión guardada al abrir la página.
  void restore() {
    final raw = _store.read();
    if (raw == null) return;
    Session? restaurada;
    try {
      restaurada = Session.fromJson(asJson(jsonDecode(raw)));
    } on FormatException {
      restaurada = null;
    }
    if (restaurada == null || restaurada.isExpiredAt(_clock().toUtc())) {
      _store.clear();
      return;
    }
    _session = restaurada;
    notifyListeners();
  }

  void start(Session session) {
    _session = session;
    _ultimoMotivo = null;
    _store.write(jsonEncode(session.toJson()));
    notifyListeners();
  }

  void logout() => _end(MotivoFinSesion.cerrada);

  /// Se llama ante un 401 o cuando el token ya expiró.
  void expire() => _end(MotivoFinSesion.expirada);

  void _end(MotivoFinSesion motivo) {
    if (_session == null) return;
    _session = null;
    _ultimoMotivo = motivo;
    _store.clear();
    notifyListeners();
  }
}
