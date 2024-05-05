import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:polyglot_cli/base_command.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/features/gen/arb_gen.dart';

class GenCommand extends Command with BaseCommand {
  @override
  String get description => 'Generate localizations delegate';

  @override
  String get name => 'gen';

  @override
  FutureOr run() {
    final config = loadConfig();
    final sourceDir = CliHelper.pathToDir(config.parts, projectDir);
    final files = findParts(sourceDir);

    final arbPartGen = ArbPartGen();
    final outputDir = CliHelper.pathToDir(config.output, projectDir);
    final result = arbPartGen.delegate(
      root: sourceDir,
      files: files,
      locale: config.defaultLocale,
    );

    final filePath = p.join(outputDir.path, 'l10n_delegate.dart');
    final resultFile = File(filePath);

    resultFile.writeAsStringSync(result);
  }
}
