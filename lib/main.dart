import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/config.dart';
import 'core/session/session_controller.dart';
import 'core/session/session_store.dart';

void main() {
  final session = SessionController(store: createSessionStore())..restore();
  final api = ApiClient(
    baseUrl: AppConfig.apiUrl,
    httpClient: http.Client(),
    tokenProvider: () => session.token,
    onUnauthorized: session.expire,
  );
  runApp(TrackerApp(session: session, api: api));
}
