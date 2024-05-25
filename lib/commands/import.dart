import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/base_command.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/exceptions/exceptions.dart';
import 'package:polyglot_cli/features/import/arb_import.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'package:yaml_writer/yaml_writer.dart';

const pathOption = 'path';
const localeOption = 'locale';
const fileOption = 'file';

class ImportCommand extends Command with BaseCommand {
  ImportCommand() {
    argParser.addMultiOption(
      fileOption,
      abbr: 'a',
      help: 'File .arb to import',
    );

    argParser.addOption(
      localeOption,
      abbr: 'l',
      help: 'Main locale for part',
    );

    argParser.addOption(
      pathOption,
      abbr: 'p',
      help: 'Path to save parts',
    );
  }

  @override
  String get description => 'Import parts from arb files';

  @override
  String get name => 'import';

  @override
  FutureOr run() async {
    final files = _files();

    if (files.isNotEmpty) {
      final arbPartImport = ArbPartImport();

      for (final file in files) {
        try {
          final content = file.readAsStringSync();
          arbPartImport.add(jsonDecode(content));
          logger.info('Import from ${file.path}');
        } on ArbImportException catch (e) {
          logger.warning('${e.message} in ${file.path}');
          // https://gitlab.com/assimtech/sysexits/-/blob/main/lib/sysexits.dart?ref_type=heads
          exit(78);
        }
      }

      final importedLocales = arbPartImport.locales;

      if (importedLocales.isNotEmpty) {
        final locale = importedLocales.length <= 1
            ? importedLocales.first
            : _locale(importedLocales);

        _saveParts(arbPartImport.split(locale));
      }
    }
  }

  String _locale(List<String> locales) {
    if (argResults?.wasParsed(localeOption) == true) {
      return argResults![localeOption];
    }

    return prompts.choose(
      'Choose main locale',
      locales,
      chevron: false,
      interactive: false,
      defaultsTo: locales.first,
    )!;
  }

  Directory _outputPath() {
    if (argResults?.wasParsed(pathOption) == true) {
      return CliHelper.pathToDir(argResults![pathOption], projectDir);
    }
    final path = prompts.get('Path to save parts', validate: (value) {
      final directory = CliHelper.pathToDir(value, projectDir);
      return directory.existsSync();
    });

    return CliHelper.pathToDir(path, projectDir);
  }

  void _saveParts(List<ArbPartDto> parts) {
    final output = _outputPath();

    for (final part in parts) {
      final path = p.join(
        output.path,
        '${_toLowerUnderscore(part.name)}.part.yaml',
      );
      final partFile = File(path);
      final writer = YamlWriter();

      final yamlPart = writer.convert(part.toJson());

      partFile.writeAsStringSync(yamlPart);
      logger.info('Save part ${partFile.path}');
    }
  }

  List<File> _files() {
    if (argResults?.wasParsed(fileOption) == true) {
      return (argResults![fileOption] as List).map((e) {
        return CliHelper.pathToFile(e, projectDir);
      }).toList();
    }

    return [];
  }

  String _toLowerUnderscore(String s) {
    var sb = StringBuffer();
    var first = true;
    for (var rune in s.runes) {
      var char = String.fromCharCode(rune);
      if (char == char.toUpperCase() && !first) {
        if (char != '_') {
          sb.write('_');
        }
        sb.write(char.toLowerCase());
      } else {
        first = false;
        sb.write(char.toLowerCase());
      }
    }
    return sb.toString();
  }
}
