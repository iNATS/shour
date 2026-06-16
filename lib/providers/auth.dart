// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

class Auth with ChangeNotifier {
  String? token = "";
  String? userId = "";
  String? phone = "";
  String? first_name = "";
  String? last_name = "";
  String? image = "";
  String? type = "";
  String? lastError;
  bool login_status = false;

  Future<bool> signup(
    String name,
    String email,
    String password,
    String phone,
    String accountType,
  ) async {
    lastError = null;
    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      final normalizedPhone = normalizePhone(phone);
      final isConsultant = accountType == 'consultant';
      final response = await supabase.auth.signUp(
        phone: normalizedPhone,
        password: password,
        data: {
          'first_name': name,
          'phone': normalizedPhone,
          'account_type': accountType,
          'active': !isConsultant,
        },
      );

      final user = response.user;
      final session = response.session;

      if (user != null && session != null) {
        await supabase.auth.updateUser(UserAttributes(email: email.trim()));
        await _upsertProfile(
          userId: user.id,
          firstName: name,
          phone: normalizedPhone,
          email: email.trim(),
          accountType: accountType,
          active: !isConsultant,
        );
        _setAuthenticatedUser(
          token: session.accessToken,
          userId: user.id,
          phone: normalizedPhone,
          firstName: name,
          lastName: '',
          image: '',
          type: accountType,
        );
      }

      return user != null;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> login(String identifier, String password) async {
    login_status = false;
    lastError = null;

    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return;
    }

    try {
      final normalizedPhone =
          identifier.contains('@') ? '' : normalizePhone(identifier);
      final response = await supabase.auth.signInWithPassword(
        email: identifier.contains('@') ? identifier.trim() : null,
        phone: identifier.contains('@') ? null : normalizedPhone,
        password: password,
      );

      final user = response.user;
      final session = response.session;
      if (user == null || session == null) {
        lastError = 'تعذر تسجيل الدخول';
        notifyListeners();
        return;
      }

      final profile = await _loadProfile(user.id);
      _setAuthenticatedUser(
        token: session.accessToken,
        userId: user.id,
        phone: user.phone ?? profile['phone']?.toString() ?? normalizedPhone,
        firstName: profile['first_name']?.toString() ?? '',
        lastName: profile['last_name']?.toString() ?? '',
        image: profile['avatar_url']?.toString() ?? '',
        type: profile['account_type']?.toString() ?? 'user',
      );
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
    }
  }

  Future<bool> loginForRole({
    required String username,
    required String password,
    required String requiredRole,
  }) async {
    login_status = false;
    lastError = null;

    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      final identifier = username.trim();
      final resolved = await _resolveLoginIdentifier(identifier);
      final response = await supabase.auth.signInWithPassword(
        email: resolved.email,
        phone: resolved.phone,
        password: password,
      );

      final user = response.user;
      final session = response.session;
      if (user == null || session == null) {
        lastError = 'تعذر تسجيل الدخول';
        notifyListeners();
        return false;
      }

      final profile = await _loadProfile(user.id);
      final accountType = profile['account_type']?.toString() ?? 'user';
      final isActive = profile['active'] != false;
      if (accountType != requiredRole || !isActive) {
        await supabase.auth.signOut();
        lastError = 'لا يملك هذا الحساب صلاحية الدخول لهذه الواجهة';
        notifyListeners();
        return false;
      }

      _setAuthenticatedUser(
        token: session.accessToken,
        userId: user.id,
        phone: user.phone ?? profile['phone']?.toString() ?? '',
        firstName: profile['first_name']?.toString() ?? '',
        lastName: profile['last_name']?.toString() ?? '',
        image: profile['avatar_url']?.toString() ??
            profile['image_url']?.toString() ??
            '',
        type: accountType,
      );
      return true;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<_LoginIdentifier> _resolveLoginIdentifier(String identifier) async {
    if (identifier.contains('@')) return _LoginIdentifier(email: identifier);

    final supabase = SupabaseService.client;
    if (supabase != null) {
      try {
        final response = await supabase.rpc(
          'resolve_login_username',
          params: {'login_username': identifier},
        );
        final row = response is List && response.isNotEmpty
            ? response.first
            : response is Map
                ? response
                : null;
        if (row is Map) {
          final email = row['email']?.toString();
          final phone = row['phone']?.toString();
          if (email != null && email.isNotEmpty) {
            return _LoginIdentifier(email: email);
          }
          if (phone != null && phone.isNotEmpty) {
            return _LoginIdentifier(phone: normalizePhone(phone));
          }
        }
      } catch (_) {
        // If the secure resolver is not installed, try the direct profile lookup.
      }

      try {
        final profile = await supabase
            .from('profiles')
            .select('email, phone')
            .eq('username', identifier)
            .maybeSingle();
        final email = profile?['email']?.toString();
        final phone = profile?['phone']?.toString();
        if (email != null && email.isNotEmpty) {
          return _LoginIdentifier(email: email);
        }
        if (phone != null && phone.isNotEmpty) {
          return _LoginIdentifier(phone: normalizePhone(phone));
        }
      } catch (_) {
        // If username lookup is not enabled by RLS, use the identifier as phone.
      }
    }

    return _LoginIdentifier(phone: normalizePhone(identifier));
  }

  static String normalizePhone(String input) {
    var value = input.trim();
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
    for (var index = 0; index < 10; index++) {
      value = value
          .replaceAll(arabicDigits[index], '$index')
          .replaceAll(persianDigits[index], '$index');
    }
    value = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (value.startsWith('00')) return '+${value.substring(2)}';

    final defaultCode = SupabaseService.defaultPhoneCountryCode;
    if (defaultCode.isNotEmpty &&
        value.startsWith('0') &&
        !value.startsWith('+')) {
      return '$defaultCode${value.substring(1)}';
    }
    return value;
  }

  Future<bool> sendEmailCode(String email) async {
    lastError = null;
    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        data: {'account_type': 'user'},
      );
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailCode(String email, String code) async {
    login_status = false;
    lastError = null;

    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );

      final user = response.user;
      final session = response.session;
      if (user == null || session == null) {
        lastError = 'رمز التأكيد غير صالح';
        notifyListeners();
        return false;
      }

      final profile = await _loadProfile(user.id);
      final emailName = user.email?.split('@').first ?? '';
      _setAuthenticatedUser(
        token: session.accessToken,
        userId: user.id,
        phone: user.phone ?? profile['phone']?.toString() ?? '',
        firstName: profile['first_name']?.toString() ?? emailName,
        lastName: profile['last_name']?.toString() ?? '',
        image: profile['avatar_url']?.toString() ?? '',
        type: profile['account_type']?.toString() ?? 'user',
      );

      if (profile.isEmpty) {
        await _upsertProfile(
          userId: user.id,
          firstName: emailName,
          phone: user.phone ?? '',
          email: user.email,
          accountType: 'user',
          active: true,
        );
      }

      return true;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetCode(String email) async {
    lastError = null;
    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      await supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false,
      );
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    lastError = null;
    final supabase = SupabaseService.client;
    if (supabase == null) {
      lastError = 'Supabase غير مهيأ';
      notifyListeners();
      return false;
    }

    try {
      final response = await supabase.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: OtpType.email,
      );
      if (response.session == null || response.user == null) {
        lastError = 'رمز التأكيد غير صالح';
        notifyListeners();
        return false;
      }

      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      await supabase.auth.signOut();
      login_status = false;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      lastError = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final supabase = SupabaseService.client;
    if (supabase != null) await supabase.auth.signOut();

    token = "";
    userId = "";
    phone = "";
    first_name = "";
    last_name = "";
    image = "";
    type = "";
    login_status = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> _loadProfile(String userId) async {
    final supabase = SupabaseService.client;
    if (supabase == null) return {};

    try {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return profile == null ? {} : Map<String, dynamic>.from(profile);
    } catch (_) {
      return {};
    }
  }

  Future<void> _upsertProfile({
    required String userId,
    required String firstName,
    required String phone,
    required String accountType,
    required bool active,
    String? email,
  }) async {
    final supabase = SupabaseService.client;
    if (supabase == null) return;

    await supabase.from('profiles').upsert({
      'id': userId,
      'first_name': firstName,
      'phone': phone,
      if (email != null) 'email': email,
      'account_type': accountType,
      'active': active,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  void _setAuthenticatedUser({
    required String token,
    required String userId,
    required String phone,
    required String firstName,
    required String lastName,
    required String image,
    required String type,
  }) {
    this.token = token;
    this.userId = userId;
    this.phone = phone;
    first_name = firstName;
    last_name = lastName;
    this.image = image;
    this.type = type;
    login_status = true;
    notifyListeners();
  }
}

class _LoginIdentifier {
  const _LoginIdentifier({this.email, this.phone});

  final String? email;
  final String? phone;
}
