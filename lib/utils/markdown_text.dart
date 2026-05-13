import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Widget untuk render teks dengan format markdown sederhana:
/// **bold**, *italic*, # heading, numbered list, bullet list
class MarkdownText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const MarkdownText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = AppTheme.textDark,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) => _buildLine(line)).toList(),
    );
  }

  Widget _buildLine(String line) {
    // Heading ## atau #
    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: _buildRichText(
          line.substring(3),
          baseFontSize: fontSize + 3,
          baseWeight: FontWeight.w700,
        ),
      );
    }
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: _buildRichText(
          line.substring(2),
          baseFontSize: fontSize + 5,
          baseWeight: FontWeight.w800,
        ),
      );
    }

    // Numbered list: "1. " "2. " dst
    final numberedMatch = RegExp(r'^\d+\.\s').firstMatch(line);
    if (numberedMatch != null) {
      final number = numberedMatch.group(0)!;
      final content = line.substring(number.length);
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number,
                style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 2),
            Expanded(child: _buildRichText(content)),
          ],
        ),
      );
    }

    // Bullet list: "- " atau "• "
    if (line.startsWith('- ') || line.startsWith('• ')) {
      final content = line.substring(2);
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(
                    fontSize: fontSize,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700)),
            Expanded(child: _buildRichText(content)),
          ],
        ),
      );
    }

    // Baris kosong → spacing
    if (line.trim().isEmpty) {
      return const SizedBox(height: 6);
    }

    // Baris biasa
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: _buildRichText(line),
    );
  }

  Widget _buildRichText(
    String line, {
    double? baseFontSize,
    FontWeight baseWeight = FontWeight.normal,
  }) {
    final spans = _parseInline(
      line,
      baseFontSize: baseFontSize ?? fontSize,
      baseWeight: baseWeight,
    );

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// Parse inline markdown: **bold**, *italic*, ***bold italic***
  List<TextSpan> _parseInline(
    String text, {
    required double baseFontSize,
    FontWeight baseWeight = FontWeight.normal,
  }) {
    final spans = <TextSpan>[];
    final baseStyle = TextStyle(
      fontSize: baseFontSize,
      color: color,
      fontWeight: baseWeight,
      height: 1.5,
    );

    // Regex: ***bold italic***, **bold**, *italic*
    final pattern = RegExp(r'\*\*\*(.+?)\*\*\*|\*\*(.+?)\*\*|\*(.+?)\*');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // Teks sebelum match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // ***bold italic***
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (match.group(2) != null) {
        // **bold**
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(3) != null) {
        // *italic*
        spans.add(TextSpan(
          text: match.group(3),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastEnd = match.end;
    }

    // Sisa teks setelah match terakhir
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    // Kalau tidak ada match sama sekali
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return spans;
  }
}
