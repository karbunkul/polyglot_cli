import 'package:polyglot_cli/types.dart';

class ArbPartDto {
  final String name;
  final String value;
  final String? description;
  final Map<String, String>? translates;
  final Map<String, dynamic>? placeholdersRaw;

  ArbPartDto({
    required this.name,
    required this.value,
    this.description,
    this.translates,
    this.placeholdersRaw,
  });

  bool get isMethod => placeholdersRaw?.isNotEmpty == true;
  Map<String, String> get args {
    final result = <String, String>{};

    final typeMap = {
      'text': 'String',
      'string': 'String',
      'int': 'int',
      'double': 'double',
      'datetime': 'DateTime',
      'num': 'num',
      'float': 'double',
      'bool': 'bool',
    };

    if (placeholdersRaw?.isNotEmpty == true) {
      for (final key in placeholdersRaw!.keys) {
        final String type = placeholdersRaw?[key]?['type'] ?? 'String';
        result.putIfAbsent(key, () => typeMap[type.toLowerCase()]!);
      }
    }

    return result;
  }

  static ArbPartDto fromJson(Json data) {
    final hasTranslates = data['translates'] != null;
    Map<String, String>? translates = {};

    if (hasTranslates) {
      final keys = (data['translates'] as Map).keys;
      for (final key in keys) {
        translates[key] = data['translates'][key] as String;
      }
    }

    return ArbPartDto(
      name: data['name'],
      value: data['value'],
      placeholdersRaw: data['placeholders'],
      translates: hasTranslates ? translates : null,
      description: data['description'],
    );
  }

  List<IPlaceholder> get placeholders {
    final result = <IPlaceholder>[];

    if (placeholdersRaw?.isNotEmpty == true) {
      for (final key in placeholdersRaw!.keys) {
        Map<String, dynamic> json = placeholdersRaw![key] ?? {};
        json['id'] = key;
        final type = json['type'] ?? 'text';
        switch (type) {
          case 'int':
          case 'double':
          case 'num':
            {
              final Map<String, dynamic> optionalParameters =
                  json['optionalParameters'] ?? {};
              json['symbol'] = optionalParameters['symbol'];
              json['decimalDigits'] = optionalParameters['decimalDigits'];
              json['customPattern'] = optionalParameters['customPattern'];

              result.add(NumPlaceholder.fromJson(json));
              break;
            }
          case 'DateTime':
            {
              result.add(DateTimePlaceholder.fromJson(json));
              break;
            }
          default:
            {
              result.add(StringPlaceholder.fromJson(json));
              break;
            }
        }
      }
    }

    return result;
  }

  bool get hasExtra {
    return description != null || placeholdersRaw?.keys.isNotEmpty == true;
  }

  Json get extra {
    return {
      if (description != null) 'description': description,
      if (placeholdersRaw != null) 'placeholders': placeholdersRaw,
    };
  }

  List<String> locales(String mainLocale) {
    return [
      mainLocale,
      ...(translates?.keys.toList() ?? []),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      if (description != null) 'description': description,
      if (translates != null) 'translates': translates,
      if (placeholdersRaw != null) 'placeholders': placeholdersRaw,
    };
  }

  @override
  String toString() {
    return {'name': name}.toString();
  }
}

enum PlaceholderType { string, double, int, dateTime, num }

abstract class IPlaceholder {
  String get id;
  PlaceholderType get type;
  String? get description => null;
  String? get example => null;
  String? get context => null;
  String? get formatterCode => null;

  static IPlaceholder fromJson(Map<String, dynamic> data) {
    throw UnimplementedError();
  }
}

class StringPlaceholder extends IPlaceholder {
  @override
  final String id;
  @override
  final String? description;
  @override
  final String? example;
  @override
  final String? context;

  StringPlaceholder(
      {required this.id, this.description, this.example, this.context});

  @override
  PlaceholderType get type => PlaceholderType.string;

  static StringPlaceholder fromJson(Map<String, dynamic> data) {
    final String id = data['id'];
    final String? description = data['description'];
    final String? example = data['example'];
    final String? context = data['context'];

    return StringPlaceholder(
      id: id,
      description: description?.trim(),
      example: example?.trim(),
      context: context?.trim(),
    );
  }
}

class DateTimePlaceholder extends IPlaceholder {
  @override
  final String id;
  final String format;
  final bool isCustomDateFormat;

  @override
  final String? description;
  @override
  final String? example;
  @override
  final String? context;

  DateTimePlaceholder({
    required this.id,
    required this.format,
    this.description,
    this.example,
    this.context,
    this.isCustomDateFormat = false,
  });

  @override
  PlaceholderType get type => PlaceholderType.dateTime;

  static DateTimePlaceholder fromJson(Map<String, dynamic> data) {
    final String format = data['format']!;
    final String? description = data['description'];
    final String? example = data['example'];
    final String? context = data['context'];
    final bool isCustomDateFormat = data['isCustomDateFormat'] == 'true';

    return DateTimePlaceholder(
      id: data['id'],
      format: format,
      isCustomDateFormat: isCustomDateFormat,
      description: description?.trim(),
      example: example?.trim(),
      context: context?.trim(),
    );
  }

  @override
  String? get formatterCode {
    return 'DateFormat(\'$format\').format($id)';
  }
}

class NumPlaceholder extends IPlaceholder {
  @override
  final String id;
  final String format;
  final String? symbol;
  final int? decimalDigits;
  final String? customPattern;

  @override
  final String? description;
  @override
  final String? example;
  @override
  final String? context;

  NumPlaceholder({
    required this.id,
    required this.format,
    this.customPattern,
    this.decimalDigits,
    this.symbol,
    this.description,
    this.example,
    this.context,
  });

  @override
  PlaceholderType get type => PlaceholderType.num;

  static NumPlaceholder fromJson(Map<String, dynamic> data) {
    final String format = data['format'] ?? 'decimalPattern';
    final String? description = data['description'];
    final String? example = data['example'];
    final String? context = data['context'];

    return NumPlaceholder(
      id: data['id'],
      format: format,
      decimalDigits: data['decimalDigits'],
      symbol: data['symbol'],
      customPattern: data['customPattern'],
      description: description?.trim(),
      example: example?.trim(),
      context: context?.trim(),
    );
  }

  bool get _isSymbol {
    return [
      'compactCurrency',
      'currency',
    ].contains(format);
  }

  bool get _isDecimalDigits {
    return [
      'compactCurrency',
      'compactSimpleCurrency',
      'currency',
      'decimalPercentPattern',
      'simpleCurrency',
    ].contains(format);
  }

  @override
  String? get formatterCode {
    final params = [
      if (symbol != null && _isSymbol) 'symbol: "$symbol"',
      if (decimalDigits != null && _isDecimalDigits)
        'decimalDigits: $decimalDigits',
      if (format == 'currency' && customPattern != null)
        'customPattern: "$customPattern"',
    ];

    return 'NumberFormat.$format(${params.join(', ')}).format($id)';
  }
}
