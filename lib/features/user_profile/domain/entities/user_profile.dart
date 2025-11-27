import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? photoPath;

  const UserProfile({this.photoPath});

  @override
  List<Object?> get props => [photoPath];
}