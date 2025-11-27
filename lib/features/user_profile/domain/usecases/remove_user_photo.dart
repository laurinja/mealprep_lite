import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_profile_repository.dart';

class RemoveUserPhoto implements UseCase<void, NoParams> {
  final UserProfileRepository repository;

  RemoveUserPhoto(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.removeUserPhoto();
  }
}