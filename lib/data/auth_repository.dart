import '../core/api/api_client.dart';
import '../core/api/api_exception.dart';
import '../core/session/session.dart';
import '../core/session/session_controller.dart';
import 'json.dart';

class AuthRepository {
  AuthRepository(this._api, this._session);

  final ApiClient _api;
  final SessionController _session;

  /// Inicia sesión y la deja activa en [SessionController].
  /// Lanza [UnauthorizedException] si las credenciales son incorrectas.
  Future<void> login(String userName, String password) async {
    final json = asJson(await _api.login(userName, password));
    final token = json.stringOrNull('token');
    if (token == null) {
      throw const InvalidResponseException('El login no devolvió token');
    }
    final session = Session.fromToken(
      token,
      expiration: json.utcDateOrNull('expiration'),
      userName: userName,
    );
    if (session == null) {
      throw const InvalidResponseException('El token no trae id o expiración');
    }
    _session.start(session);
  }
}
