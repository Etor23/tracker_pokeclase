import 'package:web/web.dart' as web;

import 'session_store.dart';

SessionStore createPlatformSessionStore() => _WebSessionStore();

class _WebSessionStore implements SessionStore {
  static const _key = 'tracker.session';

  // sessionStorage puede lanzar si el navegador bloquea el almacenamiento;
  // en ese caso la sesión simplemente no sobrevive a F5.
  @override
  String? read() {
    try {
      return web.window.sessionStorage.getItem(_key);
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String value) {
    try {
      web.window.sessionStorage.setItem(_key, value);
    } catch (_) {}
  }

  @override
  void clear() {
    try {
      web.window.sessionStorage.removeItem(_key);
    } catch (_) {}
  }
}
