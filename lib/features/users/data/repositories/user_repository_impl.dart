import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> authenticate(String email, String password) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .filter('deleted_at', 'is', 'null')
          .maybeSingle();

      if (response != null && response['password'] == password) return response;
    } catch (e) { 
      debugPrint('Erro login: $e'); 
    }
    return null;
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    try {
      final existing = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      
      if (existing != null) return false;
      
      await _supabase.from('profiles').insert({
        'email': email, 
        'name': name, 
        'password': password, 
        'updated_at': DateTime.now().toIso8601String()
      });
      return true;
    } catch (e) { 
      debugPrint('Erro cadastro: $e'); 
      return false; 
    }
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
    try {
      await _supabase.from('profiles').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('email', email);
    } catch (e) {
      debugPrint('Erro ao excluir conta: $e');
      throw Exception('Falha ao desativar conta');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, String name, {String? photoUrl}) async {
      final updates = {
        'nome_completo': name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (photoUrl != null) {
        updates['avatar_url'] = photoUrl;
      }

      await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.name.split('.').last;
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          contentType: imageFile.mimeType,
          upsert: true
        ),
      );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      debugPrint('Erro no upload da imagem: $e');
      return null;
    }
  }
}