import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_math_fork/flutter_math.dart';

class MarkdownDisplay extends StatelessWidget {
  final String text;
  const MarkdownDisplay({super.key, required this.text});

  // Convert [ ... ] to LaTeX display math \[ ... \]
  String preprocessMathBrackets(String input) {
    // Replace [ ... ] with \\[ ... \\]
    return input.replaceAllMapped(
      RegExp(r'\[\s*([^\[\]]+?)\s*\]'),
      (m) => '\\[${m[1]}\\]',
    );
  }

  List<Widget> parseContent(BuildContext context, String input) {
    final widgets = <Widget>[];
    // Preprocess [ ... ] to LaTeX display math
    final processedInput = preprocessMathBrackets(input);

    // Match LaTeX display math (\[ ... \]) and inline math (\( ... \))
    final regex = RegExp(r'(\\\\\[([\s\S]*?)\\\\\]|\\\\\((.*?)\\\\\))');
    int lastEnd = 0;

    for (final match in regex.allMatches(processedInput)) {
      if (match.start > lastEnd) {
        widgets.add(MarkdownBody(
          data: processedInput.substring(lastEnd, match.start),
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            code: const TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Color(0xFFEFEFEF),
            ),
          ),
          builders: {'code': CodeElementBuilder()},
        ));
      }
      final mathExpr = match.group(2) ?? match.group(3);
      if (mathExpr != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Math.tex(
            mathExpr.trim(),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < processedInput.length) {
      widgets.add(MarkdownBody(
        data: processedInput.substring(lastEnd),
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          code: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Color(0xFFEFEFEF),
          ),
        ),
        builders: {'code': CodeElementBuilder()},
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parseContent(context, text),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: code));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: const Color(0xFFEFEFEF),
        child: SelectableText(
          code,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}