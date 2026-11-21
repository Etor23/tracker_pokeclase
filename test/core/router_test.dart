import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/router.dart';

void main() {
  String? redirigir(String ruta, {required bool autenticado}) =>
      redirigirSegunSesion(autenticado: autenticado, location: Uri.parse(ruta));

  test('sin sesión manda a login recordando la ruta', () {
    final destino = redirigir('/usuario/abc/pokemon/3', autenticado: false)!;
    final uri = Uri.parse(destino);
    expect(uri.path, '/login');
    expect(uri.queryParameters['from'], '/usuario/abc/pokemon/3');
    expect(redirigir('/login', autenticado: false), isNull);
  });

  test('con sesión en login vuelve a la ruta pedida', () {
    expect(redirigir('/login?from=%2Fyo', autenticado: true), '/yo');
    expect(redirigir('/login', autenticado: true), '/');
    expect(redirigir('/yo', autenticado: true), isNull);
  });

  test('no acepta redirecciones externas', () {
    expect(rutaInternaSegura('https://malo.com'), '/');
    expect(rutaInternaSegura('//malo.com'), '/');
    expect(rutaInternaSegura('/login?from=/x'), '/');
    expect(rutaInternaSegura('/usuario/abc'), '/usuario/abc');
  });

  test('las rutas codifican el userId', () {
    expect(Rutas.usuario('a b'), '/usuario/a%20b');
    expect(Rutas.pokemon('abc', 7), '/usuario/abc/pokemon/7');
  });
}
