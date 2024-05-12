import 'package:collection/collection.dart';

extension IterableExtensions on Iterable<MapEntry<String, dynamic>> {
  Iterable<MapEntry<String, dynamic>> excludeLocaleParam() =>
      whereNot((param) => param.key == '@@locale');
}
