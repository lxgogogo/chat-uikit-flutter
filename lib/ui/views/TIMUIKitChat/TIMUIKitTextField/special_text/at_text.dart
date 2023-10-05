import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AtText extends SpecialText {
  AtText(TextStyle? textStyle,
      {this.showAtBackground = false, required this.start})
      : super(flag, ' ', textStyle);
  static const String flag = '@';
  final int start;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final TextStyle? textStyle = this.textStyle?.copyWith(
          color: const Color(0xFF1F1F1F),
        );

    final String atText = toString();

    return SpecialTextSpan(
      text: atText,
      actualText: atText,
      start: start,
      style: textStyle,
    );
  }
}
