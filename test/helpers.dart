import 'dart:convert';

/// JWT falso (firma inválida; el tracker no la verifica).
String fakeJwt(Map<String, Object?> claims) {
  String parte(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${parte({'alg': 'HS256', 'typ': 'JWT'})}.${parte(claims)}.firma';
}

const userIdPrueba = '8f1c2d3e-0000-4000-8000-123456789abc';

/// Token que expira en [expira] (UTC).
String tokenPrueba({required DateTime expira, String name = 'ash'}) => fakeJwt({
  'sub': userIdPrueba,
  'unique_name': name,
  'exp': expira.millisecondsSinceEpoch ~/ 1000,
});
