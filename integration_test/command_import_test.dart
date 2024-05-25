import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'resources/resources.dart';
import 'utils/iterable_extensions.dart';
import 'utils/io.dart';

void main([List<String>? args]) {
  group('Command Import. ', () {
    late Directory workingDirectory;
    late Directory partsDirectory;
    setUp(() async {
      workingDirectory = createTempDirectory();
      print('Current test working directory: $workingDirectory');
      partsDirectory = Directory('${workingDirectory.path}/parts');
      partsDirectory.createSync();
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['init'],
      );
    });
    test('Common', () async {
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: [
          'import',
          '--file',
          relativePathForMock(ArbLocales.common),
          '-p',
          'parts'
        ],
      );
      final commonArbContent = File(ArbLocales.common).readAsStringSync();
      final jsonCommon = jsonDecode(commonArbContent) as Map<String, dynamic>;
      final allPartFilesExists = jsonCommon.entries.excludeLocaleParam().map(
        (e) {
          final filePart = File('${partsDirectory.path}/${e.key}.part.yaml');
          return filePart.existsSync();
        },
      ).toList();

      expect(allPartFilesExists.every((element) => element), isTrue);
    });

    test('No `@@locale` param exists', () async {
      final exec = await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: [
          'import',
          '--file',
          relativePathForMock(ArbLocales.withoutLocale),
          '-p',
          'parts'
        ],
      );

      expect(exec.exitCode, isNot(0));
    });

    test('Sinle placeholder `String`', () async {
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: [
          'import',
          '--file',
          relativePathForMock(ArbLocales.singlePlaceholderString),
          '-p',
          'parts'
        ],
      );
      final unitsPartContent =
          File(PartYamlLocales.unitsPart).readAsStringSync();
      final target = loadYaml(unitsPartContent);
      final actualPart =
          File('${partsDirectory.path}/units.part.yaml').readAsStringSync();

      final actual = loadYaml(actualPart);

      expect(actual, target);
    });

    tearDown(() {
      workingDirectory.deleteSync(recursive: true);
    });
  });
}
