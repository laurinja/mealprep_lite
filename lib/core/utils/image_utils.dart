import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import '../errors/exceptions.dart';

class ImageUtils {
  static Future<File> compressImage(XFile file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 512,
      minHeight: 512,
      quality: 80,
      autoCorrectionAngle: true,
      keepExif: false,
    );

    if (result == null) {
      throw ImageException('Falha ao comprimir imagem');
    }
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'temp_compressed.jpg'));
    await tempFile.writeAsBytes(result);
    return tempFile;
  }

  static Future<String> saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = p.join(directory.path, 'avatar.jpg');
    await imageFile.copy(newPath);
    return newPath;
  }

  static Future<void> deleteImageFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}