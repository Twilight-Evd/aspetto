import 'dart:io';

import 'package:sharebox/utils/path.dart';

class UtilHelper {
  static String _shellPath = "";

  static String getShellPath() {
    if (_shellPath.isNotEmpty) {
      return _shellPath;
    }
    String resolvedExecutablePath = Platform.resolvedExecutable;
    String rootPath = "";
    if (Platform.isMacOS) {
      rootPath = PathHelper.dirname(PathHelper.dirname(resolvedExecutablePath));
      _shellPath = PathHelper.join(rootPath, "Resources");
    } else if (Platform.isWindows) {
      rootPath = PathHelper.dirname(resolvedExecutablePath);
      _shellPath = PathHelper.join(rootPath, "tools");
    }
    return _shellPath;
  }
}
