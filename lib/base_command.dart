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
      logger.warning(message);
      // https://gitlab.com/assimtech/sysexits/-/blob/main/lib/sysexits.dart?ref_type=heads
      exit(72);
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
    if (!dir.existsSync()) {
      final message = 'Dir \'parts\', not exists. '
          'You can use \'polyglot init\' for init new project.';
      logger.warning(message);
      // https://gitlab.com/assimtech/sysexits/-/blob/main/lib/sysexits.dart?ref_type=heads
      exit(72);
    }

    return dir
        .listSync(recursive: true, followLinks: false)
        .where((e) {
          return e.path.endsWith('.part.yaml') || e.path.endsWith('.part.yml');
        })
        .map((e) => File(e.path))
        .toList();
  }
}
