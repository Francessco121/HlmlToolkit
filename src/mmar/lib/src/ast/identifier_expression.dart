import 'package:meta/meta.dart';

import '../token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';
import 'memory_value.dart';

@immutable
class IdentifierExpression implements ConstExpression, MemoryValue {
  final Token identifier;

  const IdentifierExpression({
    @required this.identifier
  })
    : assert(identifier != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitIdentifierExpression(this);
  }
}