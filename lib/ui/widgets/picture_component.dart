import 'package:flutter/material.dart';

class PictureComponent extends StatelessWidget {
  final String imagePath;
  final double scaleFactor; // Scale factor for zooming (3, 2, 1)
  final double picScaleRatio; // Ratio of screen width for imageBorder
  final double gap; // Gap between imageBorder and pictureMain

  const PictureComponent({
    required this.imagePath,
    required this.scaleFactor,
    this.picScaleRatio = 0.5,
    this.gap = 8.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate imageBorder size (square, based on picScaleRatio)
    final imageBorderSize = screenWidth * picScaleRatio;

    // Calculate pictureMain size (imageBorder size minus 2 * gap)
    final pictureMainSize = imageBorderSize - 2 * gap;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // imageBorder (outer square)
          Container(
            width: imageBorderSize,
            height: imageBorderSize, // Square shape
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.grey[300], // Optional background color for border
            ),
          ),
          // pictureMain (inner image, masked and zoomed)
          ClipRect(
            child: SizedBox(
              width: pictureMainSize,
              height: pictureMainSize, // Square shape
              child: Transform.scale(
                scale: scaleFactor,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Ensure the image fills the square
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}