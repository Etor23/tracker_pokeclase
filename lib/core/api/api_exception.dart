/// Errores tipados del backend.
///
/// [detalle] es información técnica para depurar; a la persona usuaria se le
/// muestra un mensaje genérico con `mensajeParaUsuario`.
sealed class ApiException implements Exception {
  const ApiException(this.detalle);

  final String detalle;

  @override
  String toString() => '$runtimeType: $detalle';
}

/// Sin conexión, tiempo agotado o bloqueo de CORS (en web no se distinguen).
final class NetworkException extends ApiException {
  const NetworkException(super.detalle);
}

/// 401: falta el token, es inválido o expiró.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.detalle);
}

/// 404: el recurso no existe.
final class NotFoundException extends ApiException {
  const NotFoundException(super.detalle);
}

/// Cualquier otro código fuera de 2xx.
final class HttpStatusException extends ApiException {
  const HttpStatusException(this.statusCode, String detalle) : super(detalle);

  final int statusCode;

  @override
  String toString() => 'HttpStatusException($statusCode): $detalle';
}

/// La respuesta llegó pero no tiene la forma esperada.
final class InvalidResponseException extends ApiException {
  const InvalidResponseException(super.detalle);
}

/// Mensaje genérico para mostrar en pantalla (nunca el texto crudo del backend).
String mensajeParaUsuario(Object error) => switch (error) {
  NetworkException() => 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
  UnauthorizedException() => 'Tu sesión expiró. Vuelve a iniciar sesión.',
  NotFoundException() => 'No encontramos lo que buscabas.',
  _ => 'Algo salió mal. Inténtalo de nuevo.',
};
