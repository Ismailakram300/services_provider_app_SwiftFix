import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final double width;
  final double height;


  const MyElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 16.0,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.elevation = 2.0,
    this.width = double.infinity,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor, backgroundColor: backgroundColor, // Ripple effect color
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
