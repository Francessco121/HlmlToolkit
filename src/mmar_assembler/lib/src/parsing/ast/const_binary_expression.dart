import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';

@immutable
class ConstBinaryExpression implements ConstExpression {
  final ConstExpression left;
  final Token operator_;
  final ConstExpression right;

  const ConstBinaryExpression({
    @required this.left,
    @required this.operator_,
    @required this.right
  })
    : assert(left != null),
      assert(operator_ != null),
      assert(right != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitConstBinaryExpression(this);
  }
}
