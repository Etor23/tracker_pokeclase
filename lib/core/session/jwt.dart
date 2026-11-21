import 'dart:convert';

/// Lee el payload de un JWT sin verificar la firma (eso lo hace el backend).
/// Devuelve `null` si el token no tiene la forma esperada.
Map<String, Object?>? decodeJwtPayload(String token) {
  final partes = token.split('.');
  if (partes.length != 3) return null;
  try {
    final json = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(partes[1]))),
    );
    return json is Map<String, Object?> ? json : null;
  } on FormatException {
    return null;
  }
}

const _claimNameIdentifier =
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
const _claimName = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';

/// Id del usuario (GUID): `sub`, `nameid` o el claim largo de .NET.
String? userIdFromClaims(Map<String, Object?> claims) =>
    _primerTexto(claims, const ['sub', 'nameid', _claimNameIdentifier]);

String? userNameFromClaims(Map<String, Object?> claims) =>
    _primerTexto(claims, const ['unique_name', 'name', _claimName]);

/// `exp` en segundos desde epoch, en UTC.
DateTime? expirationFromClaims(Map<String, Object?> claims) =>
    switch (claims['exp']) {
      final num exp => DateTime.fromMillisecondsSinceEpoch(
        (exp * 1000).round(),
        isUtc: true,
      ),
      _ => null,
    };

String? _primerTexto(Map<String, Object?> claims, List<String> keys) {
  for (final key in keys) {
    final value = claims[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
