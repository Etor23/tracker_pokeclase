import '../../core/formato.dart';
import '../json.dart';

/// Nombres de especie desde `GET /api/generation/1` (público). El id es el
/// último número de cada `url`.
class CatalogoEspecies {
  const CatalogoEspecies(this._nombres);

  factory CatalogoEspecies.fromJson(Json json) => CatalogoEspecies({
    for (final e in json.objectList('pokemon_species'))
      ?_id(e.stringOrNull('url')): capitalizar(e.string('name')),
  });

  static int? _id(String? url) {
    if (url == null) return null;
    final partes = Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty);
    return partes == null || partes.isEmpty ? null : int.tryParse(partes.last);
  }

  final Map<int, String> _nombres;

  /// "Pikachu", o "#025" si la especie no está en el catálogo.
  String nombre(int id) => _nombres[id] ?? '#${numeroEspecie(id)}';
}
