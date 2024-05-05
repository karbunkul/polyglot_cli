import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/exceptions/arb_import_exception.dart';
import 'package:polyglot_cli/types.dart';

class ArbPartImport {
  final Map<String, dynamic> _store = {};

  void add(Json data) {
    const localeId = '@@locale';
    final String? locale = data[localeId];

    if (locale == null) {
      throw ArbImportException('Arb must be contain $localeId element');
    }

    data.remove(localeId);
    data.removeWhere((key, value) => key.startsWith('@@'));
    _store[locale] = {};

    data.keys.fold(_store[locale], (ac, key) {
      final isExtra = key.startsWith('@');
      final id = isExtra ? key.substring(1) : key;

      if (ac[id] == null) {
        ac[id] = {};
      }

      if (isExtra) {
        final Map<String, dynamic> extra = data[key];

        for (final extraKey in extra.keys) {
          ac[id][extraKey] = extra[extraKey];
        }
      } else {
        ac[id]['value'] = data[id];
      }

      return ac;
    });
  }

  List<ArbPartDto> split(String locale) {
    if (!_store.keys.contains(locale)) {
      throw ArbImportException('Invalid main locale $locale');
    }

    final result = <ArbPartDto>[];
    final mainLocale = _store[locale] as Map;

    for (final key in mainLocale.keys) {
      final otherLocales = locales..remove(locale);

      final Map<String, String> translates = otherLocales.fold({}, (ac, id) {
        if (_store[id][key] != null) {
          ac[id] = _store[id][key]['value'];
        }

        return ac;
      });

      final part = ArbPartDto(
        name: key,
        value: mainLocale[key]['value'],
        description: mainLocale[key]['description'],
        translates: translates.keys.isNotEmpty ? translates : null,
        placeholdersRaw: mainLocale[key]['placeholders'],
      );
      result.add(part);
    }

    return result;
  }

  List<String> get locales => _store.keys.toList();
}
