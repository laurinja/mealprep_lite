import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_user_photo.dart';
import '../../domain/usecases/remove_user_photo.dart';
import '../../domain/usecases/save_user_photo.dart';

class UserProfileProvider extends ChangeNotifier {
  final GetUserPhoto getUserPhotoUseCase;
  final SaveUserPhoto saveUserPhotoUseCase;
  final RemoveUserPhoto removeUserPhotoUseCase;

  UserProfileProvider({
    required this.getUserPhotoUseCase,
    required this.saveUserPhotoUseCase,
    required this.removeUserPhotoUseCase,
  });

  String? _userPhotoPath;
  bool _isLoading = false;
  String? _errorMessage;

  String? get userPhotoPath => _userPhotoPath;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserPhoto() async {
    _isLoading = true;
    notifyListeners();

    final result = await getUserPhotoUseCase(NoParams());

    result.fold(
      (failure) => _errorMessage = 'Erro ao carregar foto',
      (photoPath) => _userPhotoPath = photoPath,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> savePhoto(XFile photo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await saveUserPhotoUseCase(photo);

    result.fold(
      (failure) => _errorMessage = 'Erro ao salvar foto',
      (savedPath) => _userPhotoPath = savedPath,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await removeUserPhotoUseCase(NoParams());

    result.fold(
      (failure) => _errorMessage = 'Erro ao remover foto',
      (_) => _userPhotoPath = null,
    );

    _isLoading = false;
    notifyListeners();
  }
}