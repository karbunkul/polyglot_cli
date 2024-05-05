import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:polyglot_cli/cli_helper.dart';
import 'package:polyglot_cli/commands/commands.dart';

class PolyglotRunner extends CommandRunner {
  PolyglotRunner() : super('polyglot', '') {
    _setup();
  }

  void _setup() {
    argParser.addOption(
      CliHelper.projectDirOption,
      abbr: 'p',
      help: 'Default current directory',
    );

    argParser.addFlag(
      CliHelper.forceFlag,
      abbr: 'f',
      help: 'Attempt to call action without prompting',
      defaultsTo: false,
    );

    argParser.addFlag(
      CliHelper.verboseFlag,
      help: 'Output log information',
      abbr: 'd',
      defaultsTo: true,
    );

    addCommand(InitCommand());
    addCommand(ImportCommand());
    addCommand(JoinCommand());
    addCommand(GenCommand());
    addCommand(MigrateCommand());
  }

  @override
  Future run(Iterable<String> args) async {
    final results = parse(args);
    final verbose = results[CliHelper.verboseFlag];

    if (verbose) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        final level = record.level.name;
        final time = record.time.toString().substring(0, 19);
        print('$level: $time: ${record.message}');
      });
    }

    return super.run(args);
  }
}
