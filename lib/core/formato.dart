/// Formatos de presentación compartidos.
library;

const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// "13 nov 2026", en hora local. Las fechas del modelo vienen en UTC.
String fechaCorta(DateTime fecha) {
  final local = fecha.toLocal();
  return '${local.day} ${_meses[local.month - 1]} ${local.year}';
}

/// Los nombres llegan con mayúsculas inconsistentes (`marill`, `Pikachu`).
String capitalizar(String texto) =>
    texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';

/// `poke-ball` → "Poke Ball".
String nombreDeObjeto(String nombre) =>
    nombre.split('-').where((p) => p.isNotEmpty).map(capitalizar).join(' ');

/// Número de especie con tres cifras: 7 → "007".
String numeroEspecie(int id) => id.toString().padLeft(3, '0');

/// Porcentaje sin decimales innecesarios: 0.5 → "50 %", 0.6667 → "66.7 %".
/// `null` → "—" (nunca 0 %). Con [pegado] no lleva espacio antes de `%`
/// (en cifras bitmap el espacio abre un hueco de una celda entera).
String porcentaje(double? valor, {bool pegado = false}) {
  if (valor == null) return '—';
  final p = valor * 100;
  final texto = p == p.roundToDouble()
      ? p.toStringAsFixed(0)
      : p.toStringAsFixed(1);
  return pegado ? '$texto%' : '$texto %';
}
