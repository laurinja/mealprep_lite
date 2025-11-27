import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({super.photoPath});

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(photoPath: profile.photoPath);
  }

  UserProfile toEntity() {
    return UserProfile(photoPath: photoPath);
  }
}