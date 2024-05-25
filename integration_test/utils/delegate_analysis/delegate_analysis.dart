import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:collection/collection.dart';

import '../file_extensions.dart';
import 'models.dart';

final class DelegateAnalysis {
  DelegateAnalysis({
    required this.delegateDartFile,
    required this.targetLibraryDirectory,
  })  : assert(
          delegateDartFile.fileName == 'l10n_delegate.dart',
          'Invalid file name',
        ),
        assert(delegateDartFile.existsSync(), 'File not exists'),
        _sourceCode = delegateDartFile.readAsStringSync();

  final Directory targetLibraryDirectory;

  final File delegateDartFile;

  final String _sourceCode;
  final _visitor = _PlainAstVisitor();

  void parseFile() {
    final parseResult = parseString(content: _sourceCode);
    parseResult.unit.visitChildren(_visitor);
  }

  List<DelegateInfo> get delegatesInfo {
    assert(
      _visitor.delegates != null,
      'File not parsed! Please call `parseFile` before!',
    );
    return _visitor.delegates!;
  }
}

class _PlainAstVisitor extends GeneralizingAstVisitor {
  _PlainAstVisitor();

  List<DelegateInfo>? delegates;

  @override
  void visitNode(AstNode node) {
    if (node is ClassDeclaration) {
      delegates ??= [];

      if (node.classKeyword.next is Token &&
          node.classKeyword.next!.type == TokenType.IDENTIFIER) {
        delegates?.add(
          DelegateInfo(
            className: node.name.lexeme,
            isAbstractClass: node.abstractKeyword != null,
            extendedClass: node.extendsClause?.superclass.name2.lexeme,
            getters: node.members
                .whereType<MethodDeclaration>()
                .where((e) => e.isGetter)
                .map((e) => e.name.lexeme)
                .toList(),
            methods: node.members
                .whereType<MethodDeclaration>()
                .whereNot((e) => e.isGetter || e.isStatic)
                .map(
              (e) {
                final returnState = e.body is BlockFunctionBody
                    ? (e.body as BlockFunctionBody)
                        .block
                        .statements
                        .whereType<ReturnStatement>()
                        .singleOrNull
                    : null;
                return MethodDecl(
                  optionalParameters: e.parameters!.parameters
                      .where((param) => param.isOptional)
                      .map((param) => param.name!.lexeme)
                      .toList(),
                  requiredParamters: e.parameters!.parameters
                      .where((param) => param.isRequired)
                      .map((param) => param.name!.lexeme)
                      .toList(),
                  outputType: (e.returnType as NamedType).name2.lexeme,
                  name: e.name.lexeme,
                  bodyReturnExpression: returnState == null
                      ? null
                      : ReturnDecl(
                          fullString: returnState.expression!.toSource(),
                          elements: switch (returnState.expression) {
                            StringInterpolation(:final elements) =>
                              elements.map((exp) => exp.toSource()).toList(),
                            _ => [],
                          },
                        ),
                );
              },
            ).toList(),
          ),
        );
      }
    }
    super.visitNode(node);
  }
}
