import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:polyglot_cli/config.dart';
import 'package:yaml/yaml.dart';

class CliHelper {
  static const String projectDirOption = 'project-dir';
  static const String verboseFlag = 'verbose';
  static const String forceFlag = 'force';

  static String projectDir([String? dir]) {
    if (dir == null) {
      return p.current;
    }

    var path = p.normalize(dir);
    if (!p.isAbsolute(path)) {
      path = p.join(p.current, path);
    }

    if (Directory(path).existsSync()) {
      return path;
    }
    throw Exception('invalid dir');
  }

  static Config loadConfig(String? dir) {
    final filePath = configPath(dir);
    final YamlMap yaml = loadYaml(File(filePath!).readAsStringSync());

    return Config.fromJson(yaml.cast());
  }

  static String? configPath(String? dir) {
    if (dir != null) {
      return p.join(dir, 'polyglot.yaml');
    }
    return null;
  }

  static bool existConfig(String? dir) {
    var cfgPath = CliHelper.configPath(dir);
    if (cfgPath != null) {
      var file = File(cfgPath);
      if (file.existsSync()) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static File pathToFile(String path, [String? dir]) {
    final file = File(path);

    if (!file.isAbsolute) {
      final newFile = File(
        p.canonicalize(p.join(dir ?? projectDir(), file.path)),
      );
      return newFile;
    }

    return File(p.canonicalize(file.path));
  }

  static Directory pathToDir(String path, [String? dir]) {
    if (p.isAbsolute(path)) {
      return Directory(path);
    }

    final newPath = dir != null ? p.join(dir, path) : path;

    return Directory(p.normalize(newPath));
  }
}
