import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/types.dart';

class ArbPartJoin {
  final List<ArbPartDto> _parts = [];

  void add(ArbPartDto part) {
    _parts.add(part);
  }

  Map<String, Json> join(String locale) {
    return _parts.fold(<String, Json>{}, (ac, part) {
      for (final arbLocale in part.locales(locale)) {
        final isMain = arbLocale == locale;

        if (!ac.containsKey(arbLocale)) {
          ac[arbLocale] = <String, dynamic>{'@@locale': arbLocale};
        }

        if (isMain) {
          ac[arbLocale]![part.name] = part.value;
          if (part.hasExtra) {
            ac[arbLocale]!['@${part.name}'] = part.extra;
          }
        } else {
          ac[arbLocale]![part.name] = part.translates![arbLocale];
        }
      }

      return ac;
    });
  }
}
