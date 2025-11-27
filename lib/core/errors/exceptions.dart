class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}

class ImageException implements Exception {
  final String message;
  ImageException(this.message);
}