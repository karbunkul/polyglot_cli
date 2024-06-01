import 'package:meta/meta.dart';

/// Method of instance class declarasion (not getter and not static)
@immutable
final class MethodDecl {
  const MethodDecl({
    required this.optionalParameters,
    required this.requiredParamters,
    required this.outputType,
    required this.name,
    required this.bodyReturnExpression,
  });

  final String name;
  final List<String> optionalParameters;
  final List<String> requiredParamters;
  final String outputType;
  final ReturnDecl? bodyReturnExpression;
}

@immutable
final class ReturnDecl {
  const ReturnDecl({required this.fullString, required this.elements});

  /// Represents full return value of String without keyword `return`.
  final String fullString;

  /// Represent as interpolated String of [fullString]
  final List<String> elements;
}

@immutable
final class DelegateInfo {
  const DelegateInfo({
    required this.className,
    required this.isAbstractClass,
    required this.extendedClass,
    required this.getters,
    required this.methods,
  });

  final String className;
  final bool isAbstractClass;
  final String? extendedClass;
  final List<String> getters;
  final List<MethodDecl> methods;

  bool get hasExtends => extendedClass != null;

  @override
  String toString() => '$runtimeType('
      'className: $className, '
      'isAbstractClass: $isAbstractClass, '
      'extendedClass: $extendedClass, '
      'getters: $getters, '
      'methods: $methods'
      ')';
}
