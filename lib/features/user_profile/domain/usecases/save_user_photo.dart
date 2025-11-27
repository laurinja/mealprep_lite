import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_profile_repository.dart';

class SaveUserPhoto implements UseCase<String, XFile> {
  final UserProfileRepository repository;

  SaveUserPhoto(this.repository);

  @override
  Future<Either<Failure, String>> call(XFile photo) async {
    return await repository.saveUserPhoto(photo);
  }
}