import 'package:basic_utils/basic_utils.dart';
import 'package:mustache_template/mustache.dart';
import 'package:polyglot_cli/features/gen/arb_gen.dart';
import 'package:polyglot_cli/features/gen/templates/node_template.dart';

String delegateTemplate({
  required Iterable<ExportNode> nodes,
  required Set<String> locales,
  String className = 'Locales',
  String defaultLocale = 'en',
}) {
  final template = Template(_template, htmlEscapeValues: false);
  final List<String> allLocales = locales.toList();
  final Set<String> copyLocales = Set.from(locales)..remove(defaultLocale);
  final List<String> localesWitOutMain = copyLocales.toList();

  final rootNode = nodes.firstWhere((element) => element.root);
  final nonRootNodes = nodes.where((element) => !element.root);

  return template.renderString({
    'className': className,
    'allLocales': allLocales,
    'locales': localesWitOutMain,
    'defaultLocale': defaultLocale,
    'pascalCase': (LambdaContext value) {
      return StringUtils.toPascalCase(value.renderString());
    },
    'rootNode': (LambdaContext value) {
      return nodeRefRender(node: rootNode, header: false);
    },
    'nonRootNodes': _nonRootNodes(nonRootNodes),
    'nodeImplements': _nodeImplements(nodes),
  });
}

LambdaFunction _nonRootNodes(Iterable<ExportNode> nodes) {
  return (LambdaContext context) {
    final result = <String>[];
    for (final item in nodes) {
      result.add(nodeRefRender(node: item, header: true));
    }
    return result.join("\n");
  };
}

LambdaFunction _nodeImplements(Iterable<ExportNode> nodes) {
  return (LambdaContext context) {
    final locale = context.renderString();
    final result = <String>[];

    for (final node in nodes) {
      result.add(nodeImplRender(
        locale: locale,
        node: node,
      ));
    }
    return result.join("\n");
  };
}

const _template = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes
// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

abstract class {{ className }} {
  {{ className }}(String locale): localeName = Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static {{ className }} of(BuildContext context) {
    return Localizations.of<{{ className }}>(context, {{ className }})!;
  }
  
  static const List<Locale> supportedLocales = [
  {{# allLocales }}
    Locale('{{ . }}'),
  {{/ allLocales }}
  ];

  static const LocalizationsDelegate<{{ className }}> delegate = _Delegate();
  
  {{ rootNode }}
}

class _Delegate extends LocalizationsDelegate<{{ className }}> {
  const _Delegate();

  @override
  Future<{{ className }}> load(Locale locale) {
    return SynchronousFuture<{{ className }}>(_lookupLocales(locale));
  }
  
  @override
  bool isSupported(Locale locale) {
    return <String>['{{ defaultLocale }}'{{# locales }}, '{{ . }}' {{/ locales }}].contains(locale.languageCode);
  }

  @override
  bool shouldReload(_Delegate old) => false;

  {{ className }} _lookupLocales(Locale locale) {
    Intl.defaultLocale = locale.languageCode;
    
    switch (locale.languageCode) {
      {{# locales }}
      case '{{ . }}':
        return {{ className }}{{# pascalCase }}{{ . }}{{/ pascalCase }}('{{ . }}');
      {{/ locales }}
      default: 
        return {{ className }}{{# pascalCase }}{{ defaultLocale }}{{/ pascalCase }}('{{ defaultLocale }}');
    }
  }
}

{{ nonRootNodes }}

{{# allLocales }}
/// Implements for Locale('{{ . }}')
{{# nodeImplements }}{{ . }}{{/ nodeImplements }}
{{/ allLocales }}
''';
