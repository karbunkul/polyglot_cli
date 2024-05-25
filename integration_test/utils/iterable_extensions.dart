import 'package:collection/collection.dart';

extension IterableExtensionsForMapEntry on Iterable<MapEntry<String, dynamic>> {
  Iterable<MapEntry<String, dynamic>> excludeLocaleParam() =>
      whereNot((param) => param.key == '@@locale');
}
