import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../services/supabase_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _accountType = 'user';
  XFile? _consultantPdf;
  late final Future<List<Map<String, dynamic>>> _requiredPapersFuture =
      _loadRequiredPapers();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(Auth authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountType == 'consultant' && _consultantPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى رفع ملف PDF للأوراق المطلوبة')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final success = await authProvider.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        phoneController.text.trim(),
        _accountType,
      );
      if (success) {
        if (_accountType == 'consultant') {
          final submitted = await _submitConsultantApplication(authProvider);
          if (!submitted) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إنشاء الحساب ولم يتم حفظ طلب المستشار: ${SupabaseService.errorFor('consultant_applications') ?? SupabaseService.lastError ?? 'تحقق من إعدادات قاعدة البيانات والتخزين'}',
                ),
              ),
            );
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _accountType == 'consultant'
                  ? 'تم إرسال طلب المستشار للمراجعة'
                  : 'تم إنشاء الحساب بنجاح',
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.lastError ?? 'فشل في التسجيل')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ابدأ مع شور',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أنشئ حسابك لإرسال الطلبات ومتابعة الخدمات.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      nameController,
                      'الاسم',
                      icon: Icons.person_outline,
                    ),
                    _buildTextField(
                      phoneController,
                      'رقم الهاتف الجوال',
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                    ),
                    _buildTextField(
                      emailController,
                      'البريد الإلكتروني',
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.mail_outline_rounded,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'هذا الحقل مطلوب';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'البريد الإلكتروني غير صالح';
                        }
                        return null;
                      },
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'user',
                          icon: Icon(Icons.person_outline_rounded),
                          label: Text('مستخدم'),
                        ),
                        ButtonSegment(
                          value: 'consultant',
                          icon: Icon(Icons.support_agent_outlined),
                          label: Text('مستشار'),
                        ),
                      ],
                      selected: {_accountType},
                      onSelectionChanged: isLoading
                          ? null
                          : (value) {
                              setState(() => _accountType = value.first);
                            },
                    ),
                    if (_accountType == 'consultant') ...[
                      const SizedBox(height: 14),
                      _RequiredPapersPanel(future: _requiredPapersFuture),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _pickConsultantPdf,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: Text(
                          _consultantPdf == null
                              ? 'رفع ملف PDF'
                              : _consultantPdf!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    _buildTextField(
                      passwordController,
                      'كلمة السر',
                      obscureText: _obscurePassword,
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'إظهار كلمة السر'
                            : 'إخفاء كلمة السر',
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    _buildTextField(
                      confirmPasswordController,
                      'إعادة إدخال كلمة السر',
                      obscureText: _obscureConfirmPassword,
                      icon: Icons.lock_reset_outlined,
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirmPassword
                            ? 'إظهار كلمة السر'
                            : 'إخفاء كلمة السر',
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (value != passwordController.text) {
                          return 'كلمتا السر غير متطابقتين';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          isLoading ? null : () => _submitForm(authProvider),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('إنشاء الحساب'),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'لديك حساب؟',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('تسجيل الدخول'),
                        ),
                      ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          suffixIcon: suffixIcon,
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
              if (controller == passwordController && value.length < 6) {
                return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadRequiredPapers() {
    return SupabaseService.listWhere(
      'consultant_required_documents',
      column: 'active',
      value: true,
    );
  }

  Future<void> _pickConsultantPdf() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'PDF',
          extensions: ['pdf'],
          mimeTypes: ['application/pdf'],
        ),
      ],
    );
    if (file == null) return;
    if (!file.name.toLowerCase().endsWith('.pdf')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار ملف PDF فقط')),
      );
      return;
    }
    setState(() => _consultantPdf = file);
  }

  Future<bool> _submitConsultantApplication(Auth authProvider) async {
    final userId = authProvider.userId;
    final file = _consultantPdf;
    if (userId == null || userId.isEmpty || file == null) return false;

    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}-${file.name}';
    final documentUrl = await SupabaseService.uploadBinary(
      bucket: 'consultant-applications',
      path: path,
      bytes: await file.readAsBytes(),
      contentType: 'application/pdf',
    );
    if (documentUrl == null) return false;

    return SupabaseService.insert('consultant_applications', {
      'user_id': userId,
      'full_name': nameController.text.trim(),
      'phone': Auth.normalizePhone(phoneController.text),
      'email': emailController.text.trim(),
      'document_url': documentUrl,
      'status': 'pending',
    });
  }
}

class _RequiredPapersPanel extends StatelessWidget {
  const _RequiredPapersPanel({required this.future});

  final Future<List<Map<String, dynamic>>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        final papers = snapshot.data ?? [];
        return Card.outlined(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأوراق المطلوبة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator()
                else if (papers.isEmpty)
                  Text(
                    'سيتم مراجعة ملف PDF من الإدارة.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...papers.map(
                    (paper) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description_outlined),
                      title: Text(
                        paper['title']?.toString() ?? 'مستند مطلوب',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
