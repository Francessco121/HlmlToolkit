import 'dart:collection';
import 'dart:typed_data';

import 'package:mar/mar.dart' as mar;

import '../mmar_error.dart';
import '../mmar_program.dart';
import '../output_type.dart';
import '../source.dart';
import 'compile_ast_lines.dart';
import 'compile_macros.dart';
import 'extract_identifiers.dart';
import 'parse.dart';
import 'scan.dart';

/// Assembles a full MMAR program starting at the [entrySource].
/// 
/// Use the [outputType] argument to specify whether the output
/// should be binary or text.
AssembleResult assembleProgram(Source entrySource, {
  OutputType outputType = OutputType.text
}) {
  assert(entrySource != null);
  assert(outputType != null);

  // Create a program state
  final program = MmarProgram(entrySource);

  // Scan the entry file
  final scanResult = scan(entrySource);

  // Parse the entry file
  final parseResult = parse(scanResult.tokens);

  // Compile macros from the entry file to get the full program AST
  final macroCompileResult = compileMacros(parseResult.statements,
    source: entrySource,
    sourceTreeNode: program.sourceTree.root,
    program: program
  );

  // Extract identifiers
  final extractResult = extractIdentifiers(macroCompileResult.lines);

  // Compile MMAR source lines into a MAR IR
  final compileResult = compileAstLines(macroCompileResult.lines, extractResult.identifiers);

  // Aggregate errors
  final List<MmarError> aggregatedErrors = [];

  aggregatedErrors
    ..addAll(scanResult.errors)
    ..addAll(parseResult.errors)
    ..addAll(macroCompileResult.errors)
    ..addAll(extractResult.errors)
    ..addAll(compileResult.errors);

  // Compile final output
  if (aggregatedErrors.isNotEmpty) {
    // Don't output assembly if an error occurred
    return AssembleResult(program, errors: aggregatedErrors);
  } else {
    if (outputType == OutputType.text) {
      // Write the IR to a textual MAR form
      final String compiledMarContents = mar.assembleText(compileResult.marLines);

      return AssembleResult(program, output: compiledMarContents);
    } else if (outputType == OutputType.binary) {
      // Write the IR to binary MAR form
      final UnmodifiableListView<Uint8List> binary = mar.assembleBinary(compileResult.marLines);

      return AssembleResult(program, output: binary);
    } else {
      throw new ArgumentError.value(outputType, 'outputType');
    }
  }
}

class AssembleResult {
  /// Will be of type [String] if the output type was text.
  /// 
  /// Will be of type [UnmodifiableListView<Uint8List>] if the output type was binary.
  /// 
  /// Will be `null` if there were [errors].
  final dynamic output;

  /// A list of errors encountered while assembling the program.
  final List<MmarError> errors;

  /// The full program that was assembled.
  final MmarProgram program;

  AssembleResult(this.program, {this.output, this.errors = const []});
}