import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'resources/resources.dart';
import 'utils/delegate_analysis/delegate_analysis.dart';
import 'utils/file_extensions.dart';
import 'utils/io.dart';
import 'utils/string_extension.dart';

void main([List<String>? args]) {
  group('Command Gen. ', () {
    late Directory workingDirectory;
    late Directory partsDirectory;
    setUp(() {
      workingDirectory = createTempDirectory();
      final configFile = File(PolyglotConfigurations.defaultConfig);

      configFile.copySync('${workingDirectory.path}/$configurationFileName');
      partsDirectory = Directory('${workingDirectory.path}/parts')
        ..createSync();
    });
    test('Common', () async {
      final targetLocaleFile = File(PartYamlLocales.commonPart);
      final YamlMap localeYaml = loadYaml(targetLocaleFile.readAsStringSync());

      targetLocaleFile
          .copySync('${partsDirectory.path}/${targetLocaleFile.fileName!}');
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['gen'],
      );
      final delegateFile = File('${workingDirectory.path}/$delegateFileName');
      final analysis = DelegateAnalysis(
        delegateDartFile: delegateFile,
        targetLibraryDirectory: workingDirectory,
      )..parseFile();
      final appLocales = analysis.delegatesInfo
          .singleWhere((element) => element.className == delegateClassName);
      final allImplementsOfAppLocales = analysis.delegatesInfo
          .where(
            (element) => element.extendedClass == delegateClassName,
          )
          .toList();

      expect(
        allImplementsOfAppLocales.map((e) => e.getters),
        everyElement(
          unorderedEquals(appLocales.getters),
        ),
      );
      expect(
        appLocales.getters,
        contains(localeYaml['name']),
      );
    });

    test('With other language', () async {
      final targetLocaleFile = File(PartYamlLocales.readyPart);

      targetLocaleFile
          .copySync('${partsDirectory.path}/${targetLocaleFile.fileName!}');
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['gen'],
      );
      final delegateFile = File('${workingDirectory.path}/$delegateFileName');
      final analysis = DelegateAnalysis(
        delegateDartFile: delegateFile,
        targetLibraryDirectory: workingDirectory,
      )..parseFile();
      final allImplementsOfAppLocales = analysis.delegatesInfo
          .where(
            (element) => element.extendedClass == delegateClassName,
          )
          .toList();

      expect(allImplementsOfAppLocales.length, equals(2));
    });

    test('Method with parameter', () async {
      final targetLocaleFile = File(PartYamlLocales.unitsPart);
      final YamlMap localeYaml = loadYaml(targetLocaleFile.readAsStringSync());
      targetLocaleFile
          .copySync('${partsDirectory.path}/${targetLocaleFile.fileName!}');
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['gen'],
      );
      final delegateFile = File('${workingDirectory.path}/$delegateFileName');
      final analysis = DelegateAnalysis(
        delegateDartFile: delegateFile,
        targetLibraryDirectory: workingDirectory,
      )..parseFile();
      final appLocales = analysis.delegatesInfo
          .singleWhere((element) => element.className == delegateClassName);
      final allImplementsOfAppLocales = analysis.delegatesInfo
          .where(
            (element) => element.extendedClass == delegateClassName,
          )
          .toList();

      expect(
        allImplementsOfAppLocales.map(
          (e) => e.methods.map(
            (method) => method.name,
          ),
        ),
        everyElement(
          unorderedEquals(appLocales.methods.map((e) => e.name)),
        ),
      );
      expect(
        appLocales.methods.map((e) => e.name),
        contains(localeYaml['name']),
      );
    });

    test('Method with parameter & other locales', () async {
      final targetLocaleFile = File(PartYamlLocales.fullValuePart);
      final YamlMap localeYaml = loadYaml(targetLocaleFile.readAsStringSync());
      targetLocaleFile
          .copySync('${partsDirectory.path}/${targetLocaleFile.fileName!}');
      await runInMock(
        workingDirectory: workingDirectory.path,
        additionalArgs: ['gen'],
      );
      final delegateFile = File('${workingDirectory.path}/$delegateFileName');
      final analysis = DelegateAnalysis(
        delegateDartFile: delegateFile,
        targetLibraryDirectory: workingDirectory,
      )..parseFile();

      final ruLocale = analysis.delegatesInfo.singleWhere(
          (element) => element.className.toLowerCase().contains('ru'));
      expect(
        ruLocale
            .methods.single.bodyReturnExpression?.fullString.withoutDartSymbols,
        contains(localeYaml['translates']['ru']),
      );
    });

    tearDown(() {
      // workingDirectory.deleteSync(recursive: true);
    });
  });
}
