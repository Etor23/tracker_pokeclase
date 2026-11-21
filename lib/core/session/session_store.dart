import 'session_store_memory.dart'
    if (dart.library.js_interop) 'session_store_web.dart'
    as plataforma;

/// Dónde se guarda la sesión entre recargas.
abstract interface class SessionStore {
  String? read();
  void write(String value);
  void clear();
}

/// En web usa `sessionStorage` (sobrevive a F5, se borra al cerrar la
/// pestaña). En pruebas y en otras plataformas, memoria.
SessionStore createSessionStore() => plataforma.createPlatformSessionStore();

class MemorySessionStore implements SessionStore {
  MemorySessionStore([this._value]);

  String? _value;

  @override
  String? read() => _value;

  @override
  void write(String value) => _value = value;

  @override
  void clear() => _value = null;
}
