import 'dart:io';

/// Checks if a file exists and is not empty (valid for image loading)
bool isValidImageFile(File? file) {
  try {
    return file != null && file.existsSync() && file.lengthSync() > 0;
  } catch (_) {
    return false;
  }
}
