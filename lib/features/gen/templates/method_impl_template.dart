import 'package:mustache_template/mustache.dart';
import 'package:polyglot_cli/arb_part_dto.dart';

String methodImplRender(ArbPartDto part, {String? locale}) {
  final template = Template(_placeHoldersTemplate, htmlEscapeValues: false);
  String result = locale != null && part.translates?.containsKey(locale) == true
      ? part.translates![locale]!
      : part.value;
  final List<Map<String, String>> items = [];

  for (final placeholder in part.placeholders) {
    final formatterCode = placeholder.formatterCode;
    if (formatterCode != null) {
      items.add({'name': placeholder.id, 'value': formatterCode});
      result = result.replaceAll(
        '{${placeholder.id}}',
        '\${${placeholder.id}Str}',
      );
    } else {
      result = result.replaceAll(
        '{${placeholder.id}}',
        '\${${placeholder.id}}',
      );
    }
  }

  return template.renderString({
    'placeholders': items,
    'result': result,
    'escape': (LambdaContext context) {
      return context
          .renderString()
          .replaceAll(RegExp(r'\n', multiLine: true, dotAll: true), "\\n")
          .replaceAll(RegExp(r'"'), '\\"');
    },
  });
}

const _placeHoldersTemplate = '''
{{# placeholders }}
final {{ name }}Str = {{ value }};
{{/ placeholders }}
    return "{{# escape }}{{ result }}{{/ escape }}";
''';
