import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'resources/resources.dart';
import 'utils/io.dart';

void main([List<String>? args]) {
  group('Command Init. ', () {
    late Directory workingDirectory;
    setUp(() {
      workingDirectory = createTempDirectory();
    });
    test('Common', () async {
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['init'],
      );
      final defaultConf =
          File(PolyglotConfigurations.defaultConfig).readAsStringSync();
      final target = loadYaml(defaultConf);
      final actualConf =
          File('${workingDirectory.path}/polyglot.yaml').readAsStringSync();

      final actual = loadYaml(actualConf);

      expect(actual, target);
    });

    tearDown(() {
      workingDirectory.deleteSync(recursive: true);
    });
  });
}
