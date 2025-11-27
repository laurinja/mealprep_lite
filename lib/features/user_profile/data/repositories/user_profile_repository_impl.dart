import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/avatar_local_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final AvatarLocalDataSource localDataSource;

  UserProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String?>> getUserPhoto() async {
    try {
      final photoPath = await localDataSource.getUserPhotoPath();
      return Right(photoPath);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> saveUserPhoto(XFile photo) async {
    try {
      final savedPath = await localDataSource.saveUserPhoto(photo);
      return Right(savedPath);
    } on ImageException catch (e) {
      return Left(ImageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeUserPhoto() async {
    try {
      await localDataSource.removeUserPhoto();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}