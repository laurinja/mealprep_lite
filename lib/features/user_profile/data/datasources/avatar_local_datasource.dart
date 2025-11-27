import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/image_utils.dart';

abstract class AvatarLocalDataSource {
  Future<String?> getUserPhotoPath();
  Future<String> saveUserPhoto(XFile photo);
  Future<void> removeUserPhoto();
}

class AvatarLocalDataSourceImpl implements AvatarLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _userPhotoKey = 'user_photo_path';

  AvatarLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<String?> getUserPhotoPath() async {
    return sharedPreferences.getString(_userPhotoKey);
  }

  @override
  Future<String> saveUserPhoto(XFile photo) async {
    try {
      final compressedFile = await ImageUtils.compressImage(photo);
      final savedPath = await ImageUtils.saveImageLocally(compressedFile);
      await sharedPreferences.setString(_userPhotoKey, savedPath);
      return savedPath;
    } catch (e) {
      throw ImageException('Falha ao salvar foto');
    }
  }

  @override
  Future<void> removeUserPhoto() async {
    final currentPath = sharedPreferences.getString(_userPhotoKey);
    if (currentPath != null) {
      await ImageUtils.deleteImageFile(currentPath);
    }
    await sharedPreferences.remove(_userPhotoKey);
  }
}