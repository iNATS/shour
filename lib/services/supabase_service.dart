import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _definedUrl = String.fromEnvironment('SUPABASE_URL');
  static const _definedAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static final Map<String, String> _tableErrors = {};
  static String? lastError;

  static String get url => dotenv.env['SUPABASE_URL'] ?? _definedUrl;
  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? _definedAnonKey;
  static String get defaultPhoneCountryCode =>
      dotenv.env['DEFAULT_PHONE_COUNTRY_CODE'] ?? '';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    return Supabase.instance.client;
  }

  static String? errorFor(String table) => _tableErrors[table];

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint(
          'Supabase is not configured. Pass SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static Future<List<Map<String, dynamic>>> list(String table) async {
    final supabase = client;
    if (supabase == null) return [];

    try {
      final response = await supabase.from(table).select().order(
            'created_at',
            ascending: false,
          );
      _clearTableError(table);
      return response.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      try {
        final response = await supabase.from(table).select();
        _clearTableError(table);
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (fallbackError) {
        _setTableError(table, fallbackError);
        debugPrint('Supabase list failed for $table: $fallbackError');
        return [];
      }
    }
  }

  static Future<List<Map<String, dynamic>>> listWhere(
    String table, {
    String? column,
    Object? value,
  }) async {
    final supabase = client;
    if (supabase == null) return [];

    try {
      var query = supabase.from(table).select();
      if (column != null && value != null) {
        query = query.eq(column, value);
      }
      final response = await query.order('created_at', ascending: false);
      _clearTableError(table);
      return response.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      try {
        var query = supabase.from(table).select();
        if (column != null && value != null) {
          query = query.eq(column, value);
        }
        final response = await query;
        _clearTableError(table);
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (fallbackError) {
        _setTableError(table, fallbackError);
        debugPrint('Supabase filtered list failed for $table: $fallbackError');
        return [];
      }
    }
  }

  static Future<bool> insert(String table, Map<String, dynamic> data) async {
    final supabase = client;
    if (supabase == null) return false;

    try {
      await supabase.from(table).insert(data);
      _clearTableError(table);
      return true;
    } catch (error) {
      _setTableError(table, error);
      debugPrint('Supabase insert failed for $table: $error');
      return false;
    }
  }

  static Future<bool> upsert(String table, Map<String, dynamic> data) async {
    final supabase = client;
    if (supabase == null) return false;

    try {
      await supabase.from(table).upsert(data);
      _clearTableError(table);
      return true;
    } catch (error) {
      _setTableError(table, error);
      debugPrint('Supabase upsert failed for $table: $error');
      return false;
    }
  }

  static Future<bool> updateWhere(
    String table,
    Map<String, dynamic> data, {
    required String column,
    required Object value,
  }) async {
    final supabase = client;
    if (supabase == null) return false;

    try {
      await supabase.from(table).update(data).eq(column, value);
      _clearTableError(table);
      return true;
    } catch (error) {
      _setTableError(table, error);
      debugPrint('Supabase update failed for $table: $error');
      return false;
    }
  }

  static Future<String?> uploadBinary({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final supabase = client;
    if (supabase == null) return null;

    try {
      await supabase.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: false,
            ),
          );
      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (error) {
      lastError = error.toString();
      debugPrint('Supabase upload failed for $bucket/$path: $error');
      return null;
    }
  }

  static void _setTableError(String table, Object error) {
    final message = error.toString();
    _tableErrors[table] = message;
    lastError = message;
  }

  static void _clearTableError(String table) {
    _tableErrors.remove(table);
    if (_tableErrors.isEmpty) lastError = null;
  }
}
