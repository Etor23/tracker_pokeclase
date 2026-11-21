/// Configuración de compilación. Se cambia con `--dart-define=API_URL=...`.
abstract final class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://backpokemon.runasp.net',
  );
}
