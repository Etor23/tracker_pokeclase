/// Estado de una lectura del backend para una pantalla.
sealed class Carga<T> {
  const Carga();
}

final class Cargando<T> extends Carga<T> {
  const Cargando();
}

final class Listo<T> extends Carga<T> {
  const Listo(this.valor);

  final T valor;
}

final class Fallo<T> extends Carga<T> {
  const Fallo(this.error);

  final Object error;
}

extension CargaValor<T> on Carga<T> {
  T? get valorOrNull => switch (this) {
    Listo(:final valor) => valor,
    _ => null,
  };
}
