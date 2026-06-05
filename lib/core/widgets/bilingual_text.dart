import 'package:flutter/material.dart';
import '../utils/locale_utils.dart';

class BilingualText extends StatelessWidget {
  const BilingualText({
    super.key,
    required this.en,
    required this.zh,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String en;
  final String zh;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleUtils.pick(context, en: en, zh: zh),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
