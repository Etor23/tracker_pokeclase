import '../json.dart';

/// Un elemento de `GET /api/Inventario/usuario/{id}`. Los datos del objeto
/// vienen anidados en `item`.
class ObjetoMochila {
  const ObjetoMochila({
    required this.cantidad,
    required this.nombre,
    required this.urlImagen,
    required this.descripcion,
    required this.tipoJuego,
    required this.multiplicadorCaptura,
  });

  factory ObjetoMochila.fromJson(Json json) {
    final item = json.object('item');
    return ObjetoMochila(
      cantidad: json.integer('cantidad'),
      nombre: item.string('nombre'),
      urlImagen: item.stringOrNull('urlImagen'),
      descripcion: item.stringOrNull('descripcion'),
      tipoJuego: item.stringOrNull('tipoJuego'),
      multiplicadorCaptura: item.doubleOrNull('multiplicadorCaptura'),
    );
  }

  final int cantidad;

  /// En inglés con guiones (`poke-ball`); mostrar con `nombreDeObjeto`.
  final String nombre;
  final String? urlImagen;

  /// En inglés, tal como lo guarda el backend.
  final String? descripcion;

  /// `ball` para pokébolas; null en el resto del catálogo.
  final String? tipoJuego;
  final double? multiplicadorCaptura;

  bool get esPokebola => tipoJuego == 'ball';
}
