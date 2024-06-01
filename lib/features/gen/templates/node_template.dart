import 'package:basic_utils/basic_utils.dart';
import 'package:mustache_template/mustache.dart';
import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/features/gen/arb_gen.dart';
import 'package:polyglot_cli/features/gen/templates/method_impl_template.dart';

const _refTemplate = '''
abstract class {{ className }} {
  {{ ref }}
}
''';

String nodeRefRender({
  required ExportNode node,
  bool header = true,
}) {
  final template = Template(_refTemplate, htmlEscapeValues: false);

  if (!header) {
    return _node(node: node, refMode: true);
  }

  return template.renderString({
    'header': header,
    'className': node.id,
    'ref': (LambdaContext context) {
      return _node(node: node, refMode: true);
    },
  });
}

const _implTemplate = '''
class {{ className }}{{ locale }} extends {{ className }} {
  {{# isRoot }}{{ className }}{{ locale }}(super.locale);{{/ isRoot }}
  {{# ref }}{{/ ref }}
}''';

String nodeImplRender({
  required ExportNode node,
  required String locale,
}) {
  final template = Template(_implTemplate, htmlEscapeValues: false);

  return template.renderString({
    'locale': StringUtils.toPascalCase(locale),
    'className': node.id,
    'isRoot': node.root,
    'ref': (LambdaContext context) {
      return _node(node: node, refMode: false, locale: locale);
    },
  });
}

String _partToParams(ArbPartDto part) {
  final args = [];

  part.args.forEach((key, value) {
    args.add('$value $key');
  });
  return args.join(', ');
}

String _node({
  required ExportNode node,
  required bool refMode,
  String? locale,
}) {
  final template = Template(_template, htmlEscapeValues: false);
  final getters = node.items.where((element) {
    return !element.isMethod;
  }).map((e) {
    return {
      'id': e.name,
      'value': e.translates?[locale] ?? e.value,
      'description': e.description ?? e.value,
    };
  });

  final methods = node.items.where((element) {
    return element.isMethod;
  }).map((e) {
    return {
      'id': e.name,
      'description': e.description,
    };
  }).toList();

  return template.renderString({
    'ref': refMode,
    'locale': !refMode ? locale! : locale,
    'nodes': node.nodes.map((e) => e.toJson()),
    'getters': getters,
    'methods': methods,
    'methodRef': (LambdaContext context) {
      final id = context.renderString();
      final part = node.items.firstWhere((e) => e.name == id);

      return 'String $id(${_partToParams(part)})';
    },
    'methodImpl': (LambdaContext context) {
      final id = context.renderString();
      final part = node.items.firstWhere((e) => e.name == id);

      return methodImplRender(part, locale: locale);
    },
    'escape': (LambdaContext context) {
      return context
          .renderString()
          .replaceAll(RegExp(r'\n', multiLine: true, dotAll: true), "\\n")
          .replaceAll(RegExp(r'"'), '\\"');
    },
    'pascalCase': (LambdaContext value) {
      return StringUtils.toPascalCase(value.renderString());
    },
  });
}

const _template = '''
{{# ref }}
{{# nodes }}
{{ id }} get {{ name }};
{{/ nodes }}
{{# getters }}
  /// {{# escape }}{{ description }}{{/ escape }}
  String get {{ id }};
{{/ getters }}
{{# methods }}
  {{# description }}/// {{ . }}{{/ description }}
  {{# methodRef }}{{ id }}{{/ methodRef }};
{{/ methods }}
{{/ ref }}

{{^ ref }}
{{# nodes }}
  @override
  {{ id }} get {{ name }} {
    return {{ id }}{{# pascalCase }}{{ locale }}{{/ pascalCase }}();
  }
{{/ nodes }}
{{# getters }}
  @override  
  String get {{ id }} => "{{# escape }}{{ value }}{{/ escape }}";
{{/ getters }}
{{# methods }}
  @override
  {{# methodRef }}{{ id }}{{/ methodRef }} {
{{# methodImpl }}{{ id }}{{/ methodImpl }}  }
{{/ methods }}
{{/ ref }}
''';
