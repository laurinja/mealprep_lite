import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_profile_repository.dart';

class GetUserPhoto implements UseCase<String?, NoParams> {
  final UserProfileRepository repository;

  GetUserPhoto(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await repository.getUserPhoto();
  }
}