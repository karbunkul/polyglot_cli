import 'dart:io';

extension FileExtensions on File {
  /// File name with extension
  String? get fileName => path.split(RegExp(r'[\/\\]{1}')).lastOrNull;

  /// Same
  String? get fileNameWithoutExtension {
    if (fileName == null) {
      return null;
    }

    if (!fileName!.contains('.')) {
      return fileName;
    }

    return fileName!.split('.').first;
  }
}
