import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:polyglot_cli/base_command.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/config.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'package:yaml_writer/yaml_writer.dart';

class InitCommand extends Command with BaseCommand {
  @override
  String get description => 'Init new project';

  @override
  String get name => 'init';

  @override
  FutureOr run() async {
    if (!CliHelper.existConfig(projectDir) || force) {
      _saveConfig();
    } else {
      final answer = prompts.get(
        'Config file already exists. You want override them?(y/n)',
        defaultsTo: 'n',
        validate: (value) {
          final safeValue = value.trim().toLowerCase();
          return ['y', 'n', 'yes', 'no'].contains(safeValue);
        },
      );

      if (answer.substring(0, 1) == 'y') {
        _saveConfig();
      }
    }
  }

  Future<void> _saveConfig() async {
    final configPath = CliHelper.configPath(projectDir);
    final configFile = File(configPath!);
    final config = Config().toJson();
    final yamlWriter = YamlWriter();
    configFile.writeAsStringSync(yamlWriter.write(config));
    logger.info('Save config \'polyglot.yaml\' into \'$projectDir\'');
  }
}
