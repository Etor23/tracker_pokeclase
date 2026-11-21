import 'package:flutter/foundation.dart';

import '../../data/json.dart';
import 'jwt.dart';

/// Sesión del usuario actual. El id y el nombre salen del JWT.
@immutable
class Session {
  const Session({
    required this.token,
    required this.userId,
    required this.userName,
    required this.expiresAt,
  });

  final String token;
  final String userId;
  final String userName;

  /// En UTC.
  final DateTime expiresAt;

  bool isExpiredAt(DateTime nowUtc) => !nowUtc.isBefore(expiresAt);

  /// Arma la sesión a partir del token. [expiration] es la que manda el login;
  /// si también viene `exp` en el JWT se usa la más temprana. [userName] es el
  /// respaldo si el JWT no trae el nombre. Devuelve `null` si el token no
  /// sirve (sin id o sin expiración).
  static Session? fromToken(
    String token, {
    DateTime? expiration,
    String? userName,
  }) {
    final claims = decodeJwtPayload(token);
    if (claims == null) return null;
    final userId = userIdFromClaims(claims);
    if (userId == null) return null;

    final expiraciones = [?expiration, ?expirationFromClaims(claims)];
    if (expiraciones.isEmpty) return null;
    final expiresAt = expiraciones.reduce((a, b) => a.isBefore(b) ? a : b);

    return Session(
      token: token,
      userId: userId,
      userName: userNameFromClaims(claims) ?? userName ?? '',
      expiresAt: expiresAt.toUtc(),
    );
  }

  /// Lo que se guarda en sessionStorage; el resto se vuelve a leer del JWT.
  Json toJson() => {
    'token': token,
    'expiration': expiresAt.toIso8601String(),
    'userName': userName,
  };

  static Session? fromJson(Json json) {
    final token = json.stringOrNull('token');
    if (token == null) return null;
    return fromToken(
      token,
      expiration: json.utcDateOrNull('expiration'),
      userName: json.stringOrNull('userName'),
    );
  }
}
