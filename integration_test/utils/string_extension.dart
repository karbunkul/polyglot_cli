extension StringExtension on String {
  String get withoutDartSymbols => replaceAll(RegExp(r'["$]{1,}'), '');
}
