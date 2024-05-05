import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/base_command.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/features/join/arb_join.dart';
import 'package:yaml/yaml.dart';

class JoinCommand extends Command with BaseCommand {
  @override
  String get description => 'Join parts to arb files';

  @override
  String get name => 'join';

  @override
  FutureOr run() async {
    final config = loadConfig();
    final parts = findParts(CliHelper.pathToDir(config.parts, projectDir));

    final arbPartJoin = ArbPartJoin();

    for (final part in parts) {
      final content = part.readAsStringSync();
      final YamlMap yaml = loadYaml(content);

      final Map<String, dynamic> json = yaml.cast();
      arbPartJoin.add(ArbPartDto.fromJson(json));
    }

    final files = arbPartJoin.join(config.defaultLocale);
    final output = CliHelper.pathToDir(config.output, projectDir);
    for (final locale in files.keys) {
      final file = File(p.join(output.path, '$locale.arb'));
      file.writeAsStringSync(jsonEncode(files[locale]));
      logger.info('Save arb ${file.path}');
    }
  }
}
