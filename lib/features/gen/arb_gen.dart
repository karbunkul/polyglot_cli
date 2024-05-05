import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:polyglot_cli/arb_part_dto.dart';
import 'package:polyglot_cli/features/gen/export_extension.dart';
import 'package:polyglot_cli/features/gen/templates/delegate_template.dart';
import 'package:yaml/yaml.dart';

class ArbPartGen {
  final Set<String> _availableLocales = {};

  Map<String, ExportNode> _nodes({
    required Directory root,
    required List<File> files,
    required String locale,
    required String className,
  }) {
    final rootId = 'RootNode_${DateTime.now().millisecondsSinceEpoch}';
    final rootNode = ExportNode(id: className, root: true);
    final nodes = <String, ExportNode>{rootId: rootNode};

    for (final file in files) {
      // загружаем часть
      final YamlMap yaml = loadYaml(file.readAsStringSync());
      final jsonStr = jsonEncode(yaml);
      final part = ArbPartDto.fromJson(jsonDecode(jsonStr));

      _availableLocales.addAll(part.locales(locale));

      final dirSeparator = p.separator;

      // убираем рут из пути
      final last = file.path.replaceFirst('${root.path}$dirSeparator', '');
      // разбиваем остаток пути на / (разделитель папки в ОС)
      final dirs = last.split(dirSeparator);
      // удалаяем хвост с именем файла
      dirs.removeLast();
      final countOfSegment = dirs.length;

      // если вложенных папок нет добавляем к руту
      if (dirs.isEmpty) {
        rootNode.addChild(part);
      }

      // пока есть папки перебираем их
      while (dirs.isNotEmpty) {
        final namespace = dirs.join('_').toArbExportNamespace;
        final name = dirs.join('_').toArbExportName;
        nodes.putIfAbsent(namespace, () => ExportNode(id: namespace));

        if (dirs.length == countOfSegment) {
          // если папка крайняя то добавляем part
          nodes[namespace]!.addChild(part);
        }

        final childName = dirs.last.toArbExportName;
        dirs.removeLast();

        if (dirs.isEmpty) {
          rootNode.addNode(NodeInfo(id: namespace, name: name));
        } else {
          final parent = dirs.join('_').toArbExportNamespace;
          nodes.putIfAbsent(parent, () => ExportNode(id: parent));
          nodes[parent]!.addNode(NodeInfo(name: childName, id: namespace));
        }
      }
    }

    return nodes;
  }

  String delegate({
    required Directory root,
    required List<File> files,
    required String locale,
  }) {
    final className = 'AppLocales';

    final nodes = _nodes(
      root: root,
      files: files,
      locale: locale,
      className: className,
    );

    return delegateTemplate(
      className: className,
      defaultLocale: locale,
      nodes: nodes.values.toList(),
      locales: _availableLocales,
    );
  }
}

class ExportNode {
  final String id;
  final bool root;

  final Set<NodeInfo> _nodes = {};
  final Set<ArbPartDto> _items = {};

  void addNode(NodeInfo data) {
    final node = _nodes.firstWhereOrNull((e) => e.id == data.id);
    if (node == null) {
      _nodes.add(data);
    }
  }

  void addChild(ArbPartDto data) {
    final child = _items.firstWhereOrNull((e) => e.name == data.name);
    if (child == null) {
      _items.add(data);
    }
  }

  List<NodeInfo> get nodes => _nodes.toList();
  List<ArbPartDto> get items => _items.toList();

  ExportNode({required this.id, this.root = false});

  @override
  String toString() {
    return {
      if (nodes.isNotEmpty) 'nodes': nodes,
      if (items.isNotEmpty) 'items': items,
    }.toString();
  }
}

class NodeInfo {
  final String? name;
  final String id;

  NodeInfo({required this.id, this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
