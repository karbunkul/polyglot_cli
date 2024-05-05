import 'package:basic_utils/basic_utils.dart';

extension ArbExportUtil on String {
  String _toCapitalize(bool firstUppercase) {
    final clear = StringUtils.toPascalCase(replaceAll(RegExp(r'\s+'), '_'));
    if (firstUppercase) {
      return clear;
    }

    return clear[0].toLowerCase() + clear.substring(1);
  }

  String get toArbExportName => _toCapitalize(false);
  String get toArbExportNamespace => 'Node${_toCapitalize(true)}';
}
