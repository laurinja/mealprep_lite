import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> authenticate(String email, String password) async {
    try {
      final response = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      if (response != null && response['password'] == password) return response;
    } catch (e) { debugPrint('Erro login: $e'); }
    return null;
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    try {
      final existing = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      if (existing != null) return false;
      await _supabase.from('profiles').insert({
        'email': email, 'name': name, 'password': password, 'updated_at': DateTime.now().toIso8601String()
      });
      return true;
    } catch (e) { debugPrint('Erro cadastro: $e'); return false; }
  }

  @override
  Future<void> syncProfile(String name, String email, String? photoPath) async {
    if (email.isEmpty) return;
    try {
      await _supabase.from('profiles').update({
        'name': name,
        'photo_url': photoPath,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('email', email);
    } catch (e) { debugPrint('Erro sync profile: $e'); }
  }

  @override
  Future<void> deleteAccount(String email) async {
    await _supabase.from('profiles').delete().eq('email', email);
  }
}