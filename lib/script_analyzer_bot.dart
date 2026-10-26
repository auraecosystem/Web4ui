// lib/analyzer.dart
// Existing code...

/// New Function: Count number of comments in a Dart script
int countComments(String script) {
  final commentRegex = RegExp(r'//.*?$|/\*.*?\*/', multiLine: true, dotAll: true);
  return commentRegex.allMatches(script).length;
}

/// New Function: Check if a script uses async/await
bool usesAsyncAwait(String script) {
  return script.contains('async') && script.contains('await');
}
/// Basic Script Analyzer Bot

class ScriptAnalyzer {
  final String script;

  ScriptAnalyzer(this.script);

  /// Counts the number of comments (// or /* */) in the script
  int countComments() {
    final commentRegex = RegExp(r'//.*?$|/\*.*?\*/', multiLine: true, dotAll: true);
    return commentRegex.allMatches(script).length;
  }

  /// Checks if the script uses async/await keywords
  bool usesAsyncAwait() {
    return script.contains('async') && script.contains('await');
  }

  /// Counts the number of TODO or FIXME comments
  int countTodoFixme() {
    final todoRegex = RegExp(r'(TODO|FIXME)', caseSensitive: false);
    return todoRegex.allMatches(script).length;
  }

  /// Checks for long functions (more than 50 lines)
  bool hasLongFunctions() {
    final functionRegex = RegExp(r'\w+\s+\w+\(.*\)\s*{', multiLine: true);
    final matches = functionRegex.allMatches(script);
    for (var match in matches) {
      final functionStart = match.start;
      final functionEnd = script.indexOf('}', functionStart);
      if (functionEnd != -1) {
        final functionBody = script.substring(functionStart, functionEnd);
        final lineCount = '\n'.allMatches(functionBody).length;
        if (lineCount > 50) {
          return true;
        }
      }
    }
    return false;
  }

  /// Analyzes the script and prints the results
  void analyze() {
    print('--- Script Analysis Report ---');
    print('Comments found: ${countComments()}');
    print('Uses async/await: ${usesAsyncAwait()}');
    print('TODO/FIXME comments: ${countTodoFixme()}');
    print('Has long functions (>50 lines): ${hasLongFunctions()}');
    print('--------------------------------');
  }
}
