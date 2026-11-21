import 'package:material_ui/material_ui.dart';

/// Tema provisional y neutro. Se reemplaza en la Fase 1 (dirección visual),
/// donde los colores, la tipografía y el espaciado pasan a ser tokens.
ThemeData buildAppTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF455A64)),
);
