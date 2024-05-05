import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:polyglot_cli/base_command.dart';
import 'package:polyglot_cli/cli_helper.dart';

class MigrateCommand extends Command with BaseCommand {
  @override
  String get description => 'Migrate from arb format to yaml';

  @override
  String get name => 'migrate';

  @override
  FutureOr run() async {
    final config = loadConfig();
    final dir = CliHelper.pathToDir(config.parts, projectDir);

    final parts = dir
        .listSync(recursive: true, followLinks: false)
        .where((e) => e.path.endsWith('.part.arb'))
        .map((e) => File(e.path))
        .toList();

    for (final part in parts) {
      final newPath = part.path.replaceAll('.part.arb', '.part.yaml');
      part.renameSync(newPath);
      logger.info('Migrate file ${part.path}');
    }
  }
}
