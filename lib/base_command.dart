import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/config.dart';

mixin BaseCommand on Command {
  Config loadConfig() {
    if (!CliHelper.existConfig(projectDir)) {
      final message = 'Config file not found in \'$projectDir\', '
          'you can use arb-part init for init new project.';
      logger.info(message);
      exit(0);
    }
    return CliHelper.loadConfig(projectDir);
  }

  /// Return project directory, default current dir
  String get projectDir {
    return CliHelper.projectDir(globalResults?[CliHelper.projectDirOption]);
  }

  bool get force {
    if (globalResults?.wasParsed(CliHelper.forceFlag) == true) {
      return globalResults![CliHelper.forceFlag];
    }

    return false;
  }

  Logger get logger => Logger(runtimeType.toString());

  List<File> findParts(Directory dir) {
    return dir
        .listSync(recursive: true, followLinks: false)
        .where((e) {
          return e.path.endsWith('.part.yaml') || e.path.endsWith('.part.yml');
        })
        .map((e) => File(e.path))
        .toList();
  }
}
