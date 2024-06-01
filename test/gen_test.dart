import 'dart:io';

import 'package:polyglot_cli/features/gen/arb_gen.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../integration_test/resources/resources.dart';

void main() {
  group('Command Gen. ', () {
    test('Other locales with parametrised methods', () {
      final fullValueFile = File(PartYamlLocales.fullValuePart);
      final YamlMap fullValueYaml = loadYaml(fullValueFile.readAsStringSync());

      final arbPartGen = ArbPartGen();
      final result = arbPartGen.delegate(
        root: Directory.current,
        files: [fullValueFile],
        locale: 'en',
      );
      final resultCharEscaped = result.replaceAll(RegExp(r'["$]{1,}'), '');

      expect(resultCharEscaped, contains(fullValueYaml['translates']['ru']));
    });
  });
}
