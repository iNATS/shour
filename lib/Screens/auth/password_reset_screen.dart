import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('تعيين كلمة سر جديدة')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.lock_reset_rounded, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'تأكيد البريد وتحديث كلمة السر',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل بريد حسابك، ثم استخدم رمز التأكيد لتعيين كلمة سر جديدة.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading && !_codeSent,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: _validateEmail,
                      ),
                      if (_codeSent) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'رمز التأكيد',
                            prefixIcon: Icon(Icons.pin_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال رمز التأكيد';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'كلمة السر الجديدة',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'إظهار كلمة السر'
                                  : 'إخفاء كلمة السر',
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة السر',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirmPassword
                                  ? 'إظهار كلمة السر'
                                  : 'إخفاء كلمة السر',
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'كلمتا السر غير متطابقتين';
                            }
                            return _validatePassword(value);
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isLoading
                            ? null
                            : _codeSent
                                ? _confirmNewPassword
                                : _sendCode,
                        child: _isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_codeSent
                                ? 'حفظ كلمة السر الجديدة'
                                : 'إرسال رمز التأكيد'),
                      ),
                      if (_codeSent)
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => setState(() {
                                    _codeSent = false;
                                    _codeController.clear();
                                  }),
                          child: const Text('تغيير البريد'),
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

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<Auth>();
    final sent = await auth.sendPasswordResetCode(_emailController.text);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _codeSent = sent;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'تم إرسال رمز التأكيد'
              : auth.lastError ?? 'تعذر إرسال رمز التأكيد',
        ),
      ),
    );
  }

  Future<void> _confirmNewPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<Auth>();
    final saved = await auth.confirmPasswordReset(
      email: _emailController.text,
      code: _codeController.text,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(saved ? 'تم تحديث كلمة السر' : auth.lastError ?? 'فشل الحفظ'),
      ),
    );
    if (saved) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
    if (!email.contains('@') || !email.contains('.')) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'يرجى إدخال كلمة السر';
    if (value.length < 6) return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
    return null;
  }
}
