import 'package:meta/meta.dart';

import '../token.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class Comment implements Line {
  @override
  final Token comment;

  const Comment({
    @required this.comment
  })
    : assert(comment != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitComment(this);
  }
}