import 'dart:io';

import 'enviroment.dart';

const String _mockPrefix = 'mock_';

/// This command executing local instance `polyglot` in directory
/// [workingDirectory] with additional parameters [additionalArgs]
Future<ProcessResult> runInMock({
  required String workingDirectory,
  List<String> additionalArgs = const [],
}) {
  return Process.run(
    'dart',
    [
      'run',
      executablePathInMock,
      ...additionalArgs,
    ],
    workingDirectory: workingDirectory,
  );
}

/// Creates a temporary folder where tests will be run.
Directory createTempDirectory() {
  final mockDir = Directory(mockFolder).createTempSync(_mockPrefix);
  return mockDir;
}

/// Returns relative path for [mockFolder] and temporary folder.
String relativePathForMock(String path) => '../../../$path';
