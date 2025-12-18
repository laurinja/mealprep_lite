abstract class UserRepository {
  Future<Map<String, dynamic>?> authenticate(String email, String password);

  Future<bool> register(String name, String email, String password);

  Future<void> syncProfile(String name, String email, String? photoPath);

  Future<void> deleteAccount(String email);

  Future<void> updateUserProfile(String userId, String name, {String? photoUrl});
}