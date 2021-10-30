import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:memo/noteless/test_matsumoto/formatter/flutter_highlight_takeshi.dart';
import 'package:rich_code_editor/exports.dart';

//ignore_for_file: prefer_interpolation_to_compose_strings
class NotelessSyntaxHighlighter implements SyntaxHighlighterBase {
  NotelessSyntaxHighlighter({this.accentColor});
  Color accentColor;

  Map<String, TextStyle> styles;

  void init(Color accentColor) {
    this.accentColor = accentColor;
    styles = <String, TextStyle>{
      '1': const TextStyle(
        fontStyle: FontStyle.italic,
      ),
      '2': const TextStyle(fontWeight: FontWeight.bold),
      '3': const TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
      '4': const TextStyle(
        color: Colors.blue,
      ),
      '5': const TextStyle(
        color: Colors.purple,
      ),
      '6': const TextStyle(
        decoration: TextDecoration.lineThrough,
      ),
      '7': TextStyle(
        color: accentColor,
        fontWeight: FontWeight.bold,
      ),
    };
  }

  @override
  TextEditingValue addTextRemotely(TextEditingValue oldValue, String newText) {
    return null;
  }

  @override
  TextEditingValue onBackSpacePress(
      TextEditingValue oldValue, TextSpan currentSpan) {
    return null;
  }

  /// Enterキーが押されたときに呼び出される
  @override
  TextEditingValue onEnterPress(TextEditingValue oldValue) {
    final int oldStart = oldValue.selection.start;

    final String bef = oldValue.text.substring(0, oldStart - 1);

    String befLine = bef.split('\n').last;

    int trimSpace = befLine.length;

    befLine = befLine.trimLeft();

    trimSpace = trimSpace - befLine.length;

    if (befLine.startsWith('- ') || befLine.startsWith('* ')) {
      if (befLine.length <= 2) {
        if (trimSpace == 0) {
          final TextEditingValue newValue = oldValue.copyWith(
            text: bef.substring(0, oldStart - 3) +
                '\n\n' +
                oldValue.text.substring(oldStart + 1),
            composing: const TextRange(start: -1, end: -1),
            selection: TextSelection.fromPosition(
              TextPosition(
                  affinity: TextAffinity.upstream, offset: bef.length - 1),
            ),
          );

          return newValue;
        } else {
          final TextEditingValue newValue = oldValue.copyWith(
            text: oldValue.text.substring(0, oldStart - 1 - 4) +
                oldValue.text.substring(oldStart - 3, oldStart) +
                oldValue.text.substring(oldStart + 1),
            composing: const TextRange(start: -1, end: -1),
            selection: TextSelection.fromPosition(
              TextPosition(
                  affinity: TextAffinity.upstream, offset: bef.length - 2),
            ),
          );

          return newValue;
        }
      }

      String sym = befLine.startsWith('* ') ? '*' : '-';

      for (int i = 0; i < trimSpace; i++) {
        sym = ' ' + sym;
      }

      final TextEditingValue newValue = oldValue.copyWith(
        text: bef + '\n$sym \n' + oldValue.text.substring(oldStart + 1),
        composing: const TextRange(start: -1, end: -1),
        selection: TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.upstream,
              offset: bef.length + 3 + trimSpace),
        ),
      );

      return newValue;
    }

    return null;

    int start = oldStart;

    int breakCount = 0;

    while (start > 0) {
      start--;
      if (oldValue.text[start] == '\n') {
        if (breakCount >= 1) break;
        breakCount++;
      }
    }
    if (start != 0) start++;

    String startOfLine = oldValue.text.substring(
      start,
    );
    final before = oldValue.text.substring(0, oldStart);

    print(startOfLine.substring(0, 10));

    if (startOfLine.startsWith('- ')) {
      int length = 1;

      if (startOfLine.startsWith('- ')) length++;
/*       _rec.text = before + startOfLine.substring(1).trimLeft();
      _rec.selection = TextSelection(
          baseOffset: oldStart - length, extentOffset: oldStart - length); */
      var newValue = oldValue.copyWith(
        text: before + '- \n' + oldValue.text,
        composing: TextRange(start: -1, end: -1),
        selection: TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.upstream, offset: before.length + 2),
        ),
      );

      return newValue;
    } else {}
    return oldValue;
  }

  @override
  List<TextSpan> parseText(TextEditingValue tev) {
    final List<String> texts = tev.text.split('\n');

    final List<TextSpan> lsSpans = <TextSpan>[];

    bool inCodeBlock = false;

//    final HighlightTextSpan highlightTextSpan = HighlightTextSpan();

    int i = 0;
    // 一行ごとにチェックをしていく
    texts.forEach((String text) {
      i++;
      // print('"$text"');

      if (text.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        lsSpans.add(TextSpan(text: text, style: styles['4']));
        /*   if (text.endsWith(' ')) {
          lsSpans.add(TextSpan(text: ' '));
        } */
        lsSpans.add(const TextSpan(text: '\n'));
        return;
      }

      if (inCodeBlock) {
        //lsSpans.add(TextSpan(text: text)); // Original
        final HighlightTextSpan highlightTextSpan = HighlightTextSpan(text);
        lsSpans.add(highlightTextSpan.buildTextSpan()); // Original

        /*      if (text.endsWith(' ')) {
          lsSpans.add(TextSpan(text: ' '));
        } */
        lsSpans.add(const TextSpan(text: '\n')); // Original

        return;
      }

      int lengthDiff = text.length;

      text = text.trimLeft();

      lengthDiff = lengthDiff - text.length;

      String lineStart = '';

      for (int i = 0; i < lengthDiff; i++) {
        lineStart += ' ';
      }

      if (lineStart != null) {
        lsSpans.add(
          TextSpan(
            text: lineStart,
          ),
        );
      }

      /// 関数内関数
      void addPrefix(String prefix) {
        lsSpans.add(
          TextSpan(
            text: prefix,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
          ),
        );
      }

      if (text.startsWith('# ')) {
        addPrefix('# ');
        text = text.substring(2);
      } else if (text.startsWith('## ')) {
        addPrefix('## ');
        text = text.substring(3);
      } else if (text.startsWith('### ')) {
        addPrefix('### ');
        text = text.substring(4);
      } else if (text.startsWith('#### ')) {
        addPrefix('#### ');
        text = text.substring(5);
      } else if (text.startsWith('##### ')) {
        addPrefix('##### ');
        text = text.substring(6);
      } else if (text.startsWith('###### ')) {
        addPrefix('###### ');
        text = text.substring(7);
      } else if (text.startsWith('- ')) {
        addPrefix('- ');
        text = text.substring(2);
      } else if (text.startsWith('> ')) {
        while (text.startsWith('> ')) {
          addPrefix('> ');
          text = text.substring(2);
        }
      } else if (text.startsWith('* ')) {
        addPrefix('* ');
        text = text.substring(2);
      } else {}

      /*   String str = ''; */

      // Star

      String s = text.replaceAllMapped(
          RegExp(r'(?<![\w\*])\*[^\*]+\*(?![\w\*])'),
          (Match match) =>
              '<nless-format-tmp>1' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'(?<!\*)\*\*[^\*]+\*\*(?!\*)'),
          (Match match) =>
              '<nless-format-tmp>2' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'(?<!\*)\*\*\*[^\*]+\*\*\*(?!\*)'),
          (Match match) =>
              '<nless-format-tmp>3' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Underscore

      s = s.replaceAllMapped(
          RegExp(r'(?<![\w_])_[^_]+_(?![\w_])'),
          (Match match) =>
              '<nless-format-tmp>1' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'(?<!_)__[^_]+__(?!_)'),
          (Match match) =>
              '<nless-format-tmp>2' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'(?<!_)___[^_]+___(?!_)'),
          (Match match) =>
              '<nless-format-tmp>3' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Strikethrough

      s = s.replaceAllMapped(
          RegExp(r'~~[^~]+~~'),
          (Match match) =>
              '<nless-format-tmp>6' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Inline Code

      s = s.replaceAllMapped(
          RegExp(r'\`[^\`]+\`'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Divider ---

      s = s.replaceAllMapped(
          RegExp(r'^---$'),
          (Match match) =>
              '<nless-format-tmp>7' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'^\*\*\*$'),
          (Match match) =>
              '<nless-format-tmp>7' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // KaTeX

      s = s.replaceAllMapped(
          RegExp(r'(?<![\w\$])\$[^\$]+\$(?![\w\$])'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'\$\$[^\$]+\$\$'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // AsciiMath

      s = s.replaceAllMapped(
          RegExp(r'(?<![\w&])&[^&]+&(?![\w&])'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      s = s.replaceAllMapped(
          RegExp(r'&&[^&]+&&'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Wiki-Style note links like [[Note]]

      s = s.replaceAllMapped(RegExp(r'\[\[[^\]]+\]\]'), (Match match) {
        final String str = match.input.substring(match.start, match.end);

        final String title = str.substring(2).split(']').first;

        // ignore: lines_longer_than_80_chars
        return '<nless-format-tmp>7[[<nless-format-tmp>0$title<nless-format-tmp>7]]<nless-format-tmp>0';
      });

      // Emojis

      s = s.replaceAllMapped(
          RegExp(r'(?<![\w:]):[^:]+:(?![\w:])'),
          (Match match) =>
              '<nless-format-tmp>4' +
              match.input.substring(match.start, match.end) +
              '<nless-format-tmp>0');

      // Links

      s = s.replaceAllMapped(RegExp(r'(!)?\[[^\]]*\]\([^\)]+\)'),
          (Match match) {
        String str = match.input.substring(match.start, match.end);
        String out = '';
        if (str.startsWith('!')) {
          str = str.substring(1);
          out += '<nless-format-tmp>4!';
        }
        final String title = str.substring(1).split(']').first;

        out +=
            '<nless-format-tmp>7[<nless-format-tmp>0$title<nless-format-tmp>7]';

        str = str.substring(title.length + 2);

        // ignore: join_return_with_assignment
        out += '<nless-format-tmp>4' + str + '<nless-format-tmp>0';

        return out;
      });

      s = '0$s';

      for (final String part in s.split('<nless-format-tmp>')) {
        final TextStyle style = styles[part[0]];

        lsSpans.add(TextSpan(
          text: part.substring(1),
          style: style,
        ));
        /*     if (part == '*') {
          lsSpans.add(TextSpan(
              text: str, style: TextStyle(fontWeight: FontWeight.bold)));
          str = '';
        } */
      }

      if (i < texts.length) {
        lsSpans.add(const TextSpan(text: '\n'));
      }
    });
    return lsSpans;
  }
}
