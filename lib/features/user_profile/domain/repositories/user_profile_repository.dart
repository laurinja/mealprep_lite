import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, String?>> getUserPhoto();
  Future<Either<Failure, String>> saveUserPhoto(XFile photo);
  Future<Either<Failure, void>> removeUserPhoto();
}