import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Tema del mundo "especimen bitmap": esquinas rectas, reglas de 2 px, papel,
/// tinta y rojo. Los controles siguen siendo los de Material; solo cambia su
/// vestido.
ThemeData buildAppTheme() {
  const cuadrado = RoundedRectangleBorder();
  const regla = BorderSide(color: Paleta.tinta, width: Espacio.regla);
  const reglaRoja = BorderSide(color: Paleta.rojo, width: Espacio.regla);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: Paleta.rojo,
        surface: Paleta.papel,
      ).copyWith(
        primary: Paleta.rojo,
        onPrimary: Paleta.blanco,
        secondary: Paleta.tinta,
        onSecondary: Paleta.papel,
        surface: Paleta.papel,
        onSurface: Paleta.tinta,
        onSurfaceVariant: Paleta.tintaSuave,
        outline: Paleta.tinta,
        outlineVariant: Paleta.linea,
        error: Paleta.rojo,
        onError: Paleta.blanco,
      );

  // Foco de teclado visible: regla roja de 3 px.
  WidgetStateProperty<BorderSide?> lado(BorderSide normal) =>
      WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.focused)
            ? const BorderSide(color: Paleta.rojo, width: 3)
            : normal,
      );

  final etiquetaBoton = Tipos.etiqueta;

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Paleta.papel,
    fontFamily: 'Archivo',
    splashFactory: NoSplash.splashFactory,
    textTheme: const TextTheme(
      bodyLarge: Tipos.cuerpo,
      bodyMedium: Tipos.cuerpo,
      bodySmall: Tipos.pequeno,
      titleMedium: Tipos.titulo,
      labelLarge: TextStyle(fontFamily: 'Archivo', fontWeight: FontWeight.w600),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Paleta.tinta,
      selectionColor: Paleta.rojo.withValues(alpha: 0.25),
      selectionHandleColor: Paleta.rojo,
    ),
    scrollbarTheme: const ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(Paleta.tinta),
      radius: Radius.zero,
      thickness: WidgetStatePropertyAll(6),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(cuadrado),
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Espacio.l),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? Paleta.linea : Paleta.rojo,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.disabled) ? Paleta.tenue : Paleta.blanco,
        ),
        overlayColor: const WidgetStatePropertyAll(Color(0x1F000000)),
        side: lado(regla),
        textStyle: WidgetStatePropertyAll(etiquetaBoton),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(cuadrado),
        minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
        foregroundColor: const WidgetStatePropertyAll(Paleta.tinta),
        overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
        side: lado(regla),
        textStyle: WidgetStatePropertyAll(etiquetaBoton),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(cuadrado),
        foregroundColor: const WidgetStatePropertyAll(Paleta.tinta),
        overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
        side: lado(BorderSide.none),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Archivo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(cuadrado),
        foregroundColor: const WidgetStatePropertyAll(Paleta.tinta),
        overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
        side: lado(BorderSide.none),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Paleta.blanco,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: Espacio.m, vertical: 14),
      labelStyle: TextStyle(color: Paleta.tintaSuave),
      floatingLabelStyle: TextStyle(color: Paleta.tinta),
      hintStyle: TextStyle(color: Paleta.tenue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: regla,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: regla,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: reglaRoja,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: reglaRoja,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Paleta.rojo, width: 3),
      ),
      errorStyle: TextStyle(color: Paleta.rojo, fontWeight: FontWeight.w600),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Paleta.tinta,
      unselectedLabelColor: Paleta.tintaSuave,
      labelStyle: const TextStyle(
        fontFamily: 'Archivo',
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Archivo',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: Paleta.rojo, width: 4),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Paleta.tinta,
      dividerHeight: Espacio.regla,
      overlayColor: const WidgetStatePropertyAll(Color(0x14000000)),
      tabAlignment: TabAlignment.start,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Paleta.papel,
      indicatorColor: Paleta.rojo,
      indicatorShape: cuadrado,
      height: 64,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? Paleta.blanco
              : Paleta.tinta,
        ),
      ),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Archivo',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Paleta.tinta,
        ),
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(color: Paleta.tinta),
      textStyle: TextStyle(
        fontFamily: 'Archivo',
        fontSize: 13,
        color: Paleta.papel,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Paleta.rojo,
      linearTrackColor: Paleta.linea,
    ),
    dividerTheme: const DividerThemeData(
      color: Paleta.linea,
      thickness: 1,
      space: 1,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Paleta.papel,
      shape: RoundedRectangleBorder(side: regla),
      elevation: 0,
    ),
  );
}
