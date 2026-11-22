import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _violet = Color(0xFF7C4DFF);
const _pink = Color(0xFFFF4D67);
const _cyan = Color(0xFF35C4F0);

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'El correo electrónico no tiene un formato válido.';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada.';
    case 'user-not-found':
    case 'invalid-credential':
    case 'wrong-password':
      return 'Correo o contraseña incorrectos.';
    case 'email-already-in-use':
      return 'Ese correo ya está registrado.';
    case 'weak-password':
      return 'La contraseña es demasiado débil.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
    case 'network-request-failed':
      return 'No hay conexión con el servidor.';
    case 'popup-blocked':
    case 'popup-closed-by-user':
      return 'La ventana de inicio de sesión fue cerrada o bloqueada.';
    case 'account-exists-with-different-credential':
      return 'El correo ya está asociado a otro método de inicio de sesión.';
    case 'operation-not-allowed':
      return 'Este proveedor no está habilitado en Firebase.';
    case 'app-not-authorized':
      return 'Facebook no reconoce esta aplicación. Revisa el URI de OAuth.';
    default:
      return 'No se pudo completar la operación: ${error.message ?? error.code}';
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onRegister,
    required this.onLoggedIn,
  });

  final VoidCallback onRegister;
  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runAuth(Future<void> Function() operation) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await operation();
      if (mounted) widget.onLoggedIn();
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo completar el inicio de sesión.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    await _runAuth(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _loginGoogle() async {
    await _runAuth(() async {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        return;
      }

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final account = await googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    });
  }

  Future<void> _loginFacebook() async {
    await _runAuth(() async {
      if (kIsWeb) {
        await FacebookAuth.instance.webAndDesktopInitialize(
          appId: '1422543106532715',
          cookie: true,
          xfbml: true,
          version: 'v21.0',
        );
        final result = await FacebookAuth.instance.login(
          permissions: const ['public_profile'],
        );
        if (result.status != LoginStatus.success ||
            result.accessToken == null) {
          throw FirebaseAuthException(code: 'popup-closed-by-user');
        }
        final credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        final result = await FacebookAuth.instance.login();
        if (result.status != LoginStatus.success ||
            result.accessToken == null) {
          throw FirebaseAuthException(
            code: 'account-exists-with-different-credential',
          );
        }
        final credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Bienvenido',
      subtitle: 'Inicia sesión y descubre nuevos momentos',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthField(
              controller: _emailController,
              label: 'Correo electrónico',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Ingresa tu correo.';
                if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(text)) {
                  return 'Ingresa un correo válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_rounded,
              obscureText: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white70,
                ),
              ),
              validator: (value) =>
                  (value ?? '').isEmpty ? 'Ingresa tu contraseña.' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 18),
            _GradientButton(
              onPressed: _loading ? null : _loginEmail,
              loading: _loading,
              label: 'Iniciar sesión',
            ),
            const SizedBox(height: 16),
            const _DividerLabel(text: 'o continúa con'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    onPressed: _loading ? null : _loginGoogle,
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Google',
                    color: _pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SocialButton(
                    onPressed: _loading ? null : _loginFacebook,
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: _loading ? null : widget.onRegister,
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onLogin,
    required this.onRegistered,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegistered;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      await credential.user?.reload();
      if (mounted) widget.onRegistered();
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo crear la cuenta.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Únete y empieza a compartir',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthField(
              controller: _nameController,
              label: 'Nombre completo',
              icon: Icons.person_rounded,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Ingresa tu nombre completo.'
                  : null,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: _emailController,
              label: 'Correo electrónico',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Ingresa tu correo.';
                if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(text)) {
                  return 'Ingresa un correo válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: _passwordController,
              label: 'Contraseña',
              icon: Icons.lock_rounded,
              obscureText: _obscurePassword,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white70,
                ),
              ),
              validator: (value) {
                final text = value ?? '';
                if (text.isEmpty) return 'Ingresa una contraseña.';
                if (text.length < 6) {
                  return 'Debe tener al menos 6 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: _confirmController,
              label: 'Confirmar contraseña',
              icon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirm,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white70,
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Confirma tu contraseña.';
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden.';
                }
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 18),
            _GradientButton(
              onPressed: _loading ? null : _register,
              loading: _loading,
              label: 'Crear cuenta',
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loading ? null : widget.onLogin,
              child: const Text(
                '¿Ya tienes cuenta? Inicia sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17152B), Color(0xFF34205F), Color(0xFF0E1728)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -70, right: -50, child: _GlowCircle(color: _pink)),
            Positioned(
              bottom: -100,
              left: -70,
              child: _GlowCircle(color: _cyan),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [_pink, _violet, _cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _pink.withValues(alpha: 0.35),
                                blurRadius: 28,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xCC18172A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 32,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0x26FFFFFF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _pink),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _pink, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8F9D)),
      ),
      validator: validator,
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.loading,
    required this.label,
  });

  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_pink, _violet]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _pink.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 26),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x33FF4D67),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66FF4D67)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF8F9D),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFB4BF)),
            ),
          ),
        ],
      ),
    );
  }
}
