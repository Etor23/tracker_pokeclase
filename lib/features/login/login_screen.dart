import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/session/session_controller.dart';
import '../../data/auth_repository.dart';

/// Al iniciar sesión no se navega a mano: el router escucha la sesión y
/// redirige a la ruta pedida (`?from=`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (context.read<SessionController>().ultimoMotivo ==
        MotivoFinSesion.expirada) {
      _error = 'Tu sesión expiró. Vuelve a iniciar sesión.';
    }
  }

  @override
  void dispose() {
    _usuario.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await context.read<AuthRepository>().login(
        _usuario.text.trim(),
        _password.text,
      );
    } on UnauthorizedException {
      _mostrarError('Usuario o contraseña incorrectos.');
    } catch (e) {
      _mostrarError(mensajeParaUsuario(e));
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _error = mensaje;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const .all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Text(
                      'Tracker Pokémon',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesión con tu cuenta del juego.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usuario,
                      enabled: !_enviando,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                      autofillHints: const [AutofillHints.username],
                      textInputAction: .next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe tu usuario'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      enabled: !_enviando,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      autofillHints: const [AutofillHints.password],
                      textInputAction: .done,
                      onFieldSubmitted: (_) => _enviar(),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Escribe tu contraseña'
                          : null,
                    ),
                    if (_error case final error?) ...[
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: TextStyle(color: theme.colorScheme.error),
                        semanticsLabel: 'Error: $error',
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _enviando ? null : _enviar,
                      child: _enviando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
