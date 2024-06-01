import 'dart:io';

import 'package:test/test.dart';
import 'resources/resources.dart';
import 'utils/file_extensions.dart';
import 'utils/io.dart';

void main([List<String>? args]) {
  group('Command Migrate. ', () {
    late Directory workingDirectory;
    setUp(() {
      workingDirectory = createTempDirectory();
    });
    test('Common', () async {
      File(PolyglotConfigurations.defaultConfig)
          .copySync('${workingDirectory.path}/polyglot.yaml');
      Directory('${workingDirectory.path}/parts').createSync();

      final arbFile = File(ArbLocales.common);
      arbFile.copySync(
          '${workingDirectory.path}/parts/${arbFile.fileNameWithoutExtension}.part.arb');
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['migrate'],
      );
      final transformedArb = File(
        '${workingDirectory.path}/parts/${arbFile.fileNameWithoutExtension}.part.yaml',
      );

      expect(transformedArb.existsSync(), isTrue);
    });

    tearDown(() {
      workingDirectory.deleteSync(recursive: true);
    });
  });
}
