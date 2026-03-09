import 'package:flutter/material.dart';

class ArabicText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign? align;

  const ArabicText(this.text, {super.key, this.fontSize = 22, this.align});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        text,
        textAlign: align ?? TextAlign.right,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Amiri',
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
