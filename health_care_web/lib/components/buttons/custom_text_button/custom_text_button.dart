import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final String shape;
  final double borderRadius;
  final double cornerRadius;
  final double? width;
  final Color? borderColor;
  final double height;
  final String? img;

  static const String shapeRounded = 'rounded';
  static const String shapeSquare = 'square';

  const CustomTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.img,
    this.isLoading = false,
    this.borderColor,
    this.shape = shapeRounded,
    this.borderRadius = 30,
    this.cornerRadius = 30,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(width ?? double.infinity, height),
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: textColor ?? Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(
            horizontal: width ?? 0, vertical: height * 0.1),
        shape: shape == shapeRounded
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: borderColor != null
                    ? BorderSide(color: borderColor!, width: 2)
                    : BorderSide.none,
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius),
                side: borderColor != null
                    ? BorderSide(color: borderColor!, width: 2)
                    : BorderSide.none,
              ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                ] else if (img != null) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      img ?? "", // Assuming `img` is a String path to an asset
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
