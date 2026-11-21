import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/router.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/auth_repository.dart';

/// Raíz de la app. Recibe las dependencias ya armadas (ver `main.dart`) para
/// que las pruebas puedan inyectar un `MockClient` y un `MemorySessionStore`.
class TrackerApp extends StatefulWidget {
  const TrackerApp({super.key, required this.session, required this.api});

  final SessionController session;
  final ApiClient api;

  @override
  State<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends State<TrackerApp> {
  late final GoRouter _router = createRouter(widget.session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: widget.session),
      Provider.value(value: widget.api),
      Provider(create: (_) => AuthRepository(widget.api, widget.session)),
    ],
    child: MaterialApp.router(
      title: 'Tracker Pokémon',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    ),
  );
}
