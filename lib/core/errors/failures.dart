import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
  
  @override
  List<Object> get props => [];
}

class CacheFailure extends Failure {}

class ImageFailure extends Failure {
  final String message;
  const ImageFailure(this.message);
  
  @override
  List<Object> get props => [message];
}