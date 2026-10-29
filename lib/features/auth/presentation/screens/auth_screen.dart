import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsRegister;

  const AuthScreen({super.key, this.initialIsRegister = false});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isRegister;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initialIsRegister;
    _nameController.text = 'Aiman';
    _emailController.text = 'kacangdong2@gmail.com';
    _passwordController.text = 'Aiman123';
    _confirmPasswordController.text = 'Aiman123';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode(bool register) {
    if (_isRegister == register) return;
    setState(() {
      _isRegister = register;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final notifier = ref.read(authProvider.notifier);
      String? error;
      if (_isRegister) {
        error = await notifier.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        error = await notifier.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (error != null && mounted) {
        setState(() => _errorMessage = error);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Header
                  const Center(child: BuildHausLogo(size: 52)),
                  const SizedBox(height: 24),
                  Text(
                    _isRegister
                        ? 'Buat Akun BuildHaus'
                        : 'Selamat Datang Kembali',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRegister
                        ? 'Daftarkan diri Anda untuk mulai memantau kesehatan dan jadwal servis motor kesayangan.'
                        : 'Masuk ke akun Anda untuk memantau kondisi kesehatan motor dan asisten AI.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.muted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Segmented Login / Register Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeTabButton(
                            label: 'Masuk',
                            icon: Icons.login_rounded,
                            selected: !_isRegister,
                            onTap: () => _toggleMode(false),
                          ),
                        ),
                        Expanded(
                          child: _ModeTabButton(
                            label: 'Daftar Akun',
                            icon: Icons.person_add_alt_1_rounded,
                            selected: _isRegister,
                            onTap: () => _toggleMode(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.line),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BuildHausTheme.danger.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: BuildHausTheme.danger.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: BuildHausTheme.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: BuildHausTheme.danger,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (_isRegister) ...[
                            _FieldLabel('Nama Lengkap'),
                            TextFormField(
                              key: const ValueKey('auth_name_field'),
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Contoh: Budi Santoso',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  size: 20,
                                ),
                              ),
                              validator: (v) {
                                if (!_isRegister) return null;
                                if (v == null || v.trim().isEmpty) {
                                  return 'Nama lengkap wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          _FieldLabel('Email atau Nomor HP'),
                          TextFormField(
                            key: const ValueKey('auth_email_field'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: budi@email.com',
                              prefixIcon: Icon(
                                Icons.alternate_email_rounded,
                                size: 20,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email atau nomor HP wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          _FieldLabel('Kata Sandi'),
                          TextFormField(
                            key: const ValueKey('auth_password_field'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: _isRegister
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!_isRegister) _submit();
                            },
                            decoration: InputDecoration(
                              hintText: 'Minimal 4 karakter',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Kata sandi wajib diisi';
                              }
                              if (_isRegister && v.length < 4) {
                                return 'Kata sandi minimal 4 karakter';
                              }
                              return null;
                            },
                          ),

                          if (_isRegister) ...[
                            const SizedBox(height: 14),
                            _FieldLabel('Konfirmasi Kata Sandi'),
                            TextFormField(
                              key: const ValueKey(
                                'auth_confirm_password_field',
                              ),
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: 'Ketik ulang kata sandi',
                                prefixIcon: const Icon(
                                  Icons.verified_user_outlined,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (!_isRegister) return null;
                                if (v != _passwordController.text) {
                                  return 'Konfirmasi kata sandi tidak cocok';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: BuildHausTheme.ok.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: BuildHausTheme.ok.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.health_and_safety_outlined,
                                    color: BuildHausTheme.ok,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Setelah mendaftar, Anda akan diarahkan untuk mengisi data kondisi awal motor guna menghitung status kesehatan pertama.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.ink,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              key: const ValueKey('auth_submit_button'),
                              onPressed: _submitting ? null : _submit,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _isRegister
                                          ? Icons.arrow_forward_rounded
                                          : Icons.login_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _isRegister
                                    ? 'Daftar & Setup Motor Pertama'
                                    : 'Masuk ke Aplikasi',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Switch link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _isRegister
                            ? 'Sudah punya akun BuildHaus? '
                            : 'Belum punya akun BuildHaus? ',
                        style: TextStyle(fontSize: 12, color: context.muted),
                      ),
                      GestureDetector(
                        onTap: () => _toggleMode(!_isRegister),
                        child: Text(
                          _isRegister ? 'Masuk di sini' : 'Daftar sekarang',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: BuildHausTheme.ok,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? context.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? context.bg : context.muted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: selected ? context.bg : context.muted,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.ink,
        ),
      ),
    );
  }
}
