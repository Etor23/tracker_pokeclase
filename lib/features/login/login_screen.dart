import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/franja_titulo.dart';
import '../../core/widgets/nota_vacia.dart';
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
    final compacto = MediaQuery.sizeOf(context).width < 600;
    final marca = compacto ? 32.0 : 48.0;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const .all(Espacio.m),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Semantics(
                  header: true,
                  label: 'Tracker Pokémon',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text('TRACKER', style: Tipos.bitmap(marca)),
                      const SizedBox(height: Espacio.s),
                      Text(
                        'POKÉMON',
                        style: Tipos.bitmap(marca, color: Paleta.rojo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Espacio.m),
                const Text(
                  'Las estadísticas de cada jugador del grupo: Pokédex, equipo, batallas y mochila.',
                  style: Tipos.cuerpoSuave,
                ),
                const SizedBox(height: Espacio.xl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Paleta.tinta,
                      width: Espacio.regla,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      const FranjaTitulo('Iniciar sesión'),
                      Padding(
                        padding: const .all(Espacio.l),
                        child: _formulario(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formulario() => AutofillGroup(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          const Text(
            'Usa la misma cuenta que en el juego.',
            style: Tipos.cuerpoSuave,
          ),
          const SizedBox(height: Espacio.l),
          TextFormField(
            controller: _usuario,
            enabled: !_enviando,
            decoration: const InputDecoration(labelText: 'Usuario'),
            autofillHints: const [AutofillHints.username],
            textInputAction: .next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe tu usuario' : null,
          ),
          const SizedBox(height: Espacio.m),
          TextFormField(
            controller: _password,
            enabled: !_enviando,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            autofillHints: const [AutofillHints.password],
            textInputAction: .done,
            onFieldSubmitted: (_) => _enviar(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
          ),
          if (_error case final error?) ...[
            const SizedBox(height: Espacio.m),
            Semantics(liveRegion: true, child: NotaVacia(error)),
          ],
          const SizedBox(height: Espacio.l),
          FilledButton(
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Paleta.tinta,
                      semanticsLabel: 'Entrando',
                    ),
                  )
                : const Text('ENTRAR'),
          ),
        ],
      ),
    ),
  );
}
