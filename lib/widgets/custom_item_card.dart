import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.height,
    required this.width,
    required this.borderColor,
    required this.shadowColor,
    this.imageProvider,
  });

  final double height;
  final double width;
  final Color borderColor;
  final Color shadowColor;
  final ImageProvider? imageProvider;

  // fixed values
  static const double _borderRadius = 12;
  static const double _borderWidth = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: borderColor,
          width: _borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider!,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: borderColor.withValues(alpha: 0.5),
              ),
            )
          : null,
    );
  }
}
