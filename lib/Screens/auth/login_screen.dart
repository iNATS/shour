import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  int _selectedMode = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailCodeSent = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 118,
                      height: 118,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Image.asset('assets/images/intro/Sure-logo1.png'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'مرحبًا بك في شور',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سجل الدخول لمتابعة طلباتك وخدماتك',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        icon: Icon(Icons.phone_outlined),
                        label: Text('الجوال'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.mail_outline_rounded),
                        label: Text('البريد'),
                      ),
                    ],
                    selected: {_selectedMode},
                    onSelectionChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMode = value.first;
                              _emailCodeSent = false;
                              codeController.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _selectedMode == 0
                        ? _PhoneLoginForm(
                            key: const ValueKey('phone-login'),
                            formKey: _phoneFormKey,
                            phoneController: phoneController,
                            passwordController: passwordController,
                            obscurePassword: _obscurePassword,
                            isLoading: _isLoading,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onSubmit: _submitPhoneLogin,
                          )
                        : _EmailCodeForm(
                            key: const ValueKey('email-login'),
                            formKey: _emailFormKey,
                            emailController: emailController,
                            codeController: codeController,
                            codeSent: _emailCodeSent,
                            isLoading: _isLoading,
                            onSendCode: _sendEmailCode,
                            onVerifyCode: _verifyEmailCode,
                          ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                        child: const Text('إنشاء حساب جديد'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: colorScheme.outlineVariant),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/admin'),
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: const Text('الإدارة'),
                      ),
                      TextButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  '/consultant-app',
                                ),
                        icon: const Icon(Icons.support_agent_outlined),
                        label: const Text('المستشارون'),
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

  Future<void> _submitPhoneLogin() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<Auth>();
    await authProvider.login(
      phoneController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (authProvider.login_status) {
      _goHome();
    } else {
      _showError(authProvider.lastError);
    }
  }

  Future<void> _sendEmailCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<Auth>();
    final sent = await authProvider.sendEmailCode(emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _emailCodeSent = sent;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'تم إرسال رمز التأكيد إلى بريدك'
              : authProvider.lastError ?? 'تعذر إرسال رمز التأكيد',
        ),
      ),
    );
  }

  Future<void> _verifyEmailCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<Auth>();
    final verified = await authProvider.verifyEmailCode(
      emailController.text.trim(),
      codeController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (verified) {
      _goHome();
    } else {
      _showError(authProvider.lastError);
    }
  }

  void _goHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'تعذر تسجيل الدخول')),
    );
  }
}

class _PhoneLoginForm extends StatelessWidget {
  const _PhoneLoginForm({
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'الجوال أو البريد الإلكتروني',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الجوال أو البريد الإلكتروني';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'كلمة السر',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip:
                    obscurePassword ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة السر';
              }
              if (value.length < 6) {
                return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pushNamed(context, '/reset-password'),
              child: const Text('نسيت كلمة السر؟'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: isLoading ? null : onSubmit,
            child:
                isLoading ? const _ButtonLoader() : const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}

class _EmailCodeForm extends StatelessWidget {
  const _EmailCodeForm({
    required this.formKey,
    required this.emailController,
    required this.codeController,
    required this.codeSent,
    required this.isLoading,
    required this.onSendCode,
    required this.onVerifyCode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController codeController;
  final bool codeSent;
  final bool isLoading;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyCode;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction:
                codeSent ? TextInputAction.next : TextInputAction.done,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'يرجى إدخال البريد الإلكتروني';
              if (!email.contains('@') || !email.contains('.')) {
                return 'البريد الإلكتروني غير صالح';
              }
              return null;
            },
          ),
          if (codeSent) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: codeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'رمز التأكيد',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
              validator: (value) {
                if (!codeSent) return null;
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال رمز التأكيد';
                }
                if (value.trim().length < 4) return 'رمز التأكيد غير صالح';
                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed:
                isLoading ? null : (codeSent ? onVerifyCode : onSendCode),
            icon: isLoading
                ? const SizedBox.shrink()
                : Icon(codeSent ? Icons.verified_rounded : Icons.send_rounded),
            label: isLoading
                ? const _ButtonLoader()
                : Text(codeSent ? 'تأكيد الرمز' : 'إرسال رمز التأكيد'),
          ),
          if (codeSent)
            TextButton(
              onPressed: isLoading ? null : onSendCode,
              child: const Text('إعادة إرسال الرمز'),
            ),
        ],
      ),
    );
  }
}

class _ButtonLoader extends StatelessWidget {
  const _ButtonLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
