import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_mission.dart';

/// Picture component that displays the zoomed-in mission image
/// with different zoom levels and border styling
class PictureComponent extends StatelessWidget {
  final DMission mission;
  final int zoomLevel;
  
  const PictureComponent({
    Key? key,
    required this.mission,
    this.zoomLevel = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("{PictureComponent.build} Building picture component for mission: ${mission.imagePath}");
    
    // Calculate responsive dimensions
    final pictureSize = Consts.getDimension(context, 400.0);
    final borderWidth = Consts.getDimension(context, 12.0);
    final shadowSize = Consts.getDimension(context, 8.0);
    
    return Container(
      width: pictureSize,
      height: pictureSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 16.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77), // 0.3 opacity
            blurRadius: shadowSize,
            offset: Offset(0, shadowSize / 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Border container
          _buildPicBorder(context, pictureSize),
          
          // Inner picture with zoom
          Positioned(
            left: borderWidth,
            top: borderWidth,
            right: borderWidth,
            bottom: borderWidth,
            child: _buildPicInside(context),
          ),
        ],
      ),
    );
  }
  
  /// Builds the white border frame around the picture
  Widget _buildPicBorder(BuildContext context, double pictureSize) {
    return Container(
      width: pictureSize,
      height: pictureSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 16.0)),
        border: Border.all(
          color: const Color(Consts.COLOR_LINE_GRAY),
          width: Consts.getDimension(context, 2.0),
        ),
      ),
    );
  }
  
  /// Builds the inner picture with zoom effect
  Widget _buildPicInside(BuildContext context) {
    final borderRadius = Consts.getRadius(context, 12.0);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: OverflowBox(
          child: Transform.scale(
            scale: _getZoomScale(),
            child: Image.asset(
              'assets/data/${mission.imagePath}.jpg', // Load from assets/data/
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("{PictureComponent._buildPicInside} Error loading image: assets/data/${mission.imagePath}.jpg");
                return _buildErrorPlaceholder(context);
              },
            ),
          ),
        ),
      ),
    );
  }
  
  /// Returns the zoom scale based on current zoom level
  double _getZoomScale() {
    switch (zoomLevel) {
      case Consts.SCALE_LEVEL_1:
        return 1.5; // Most zoomed in
      case Consts.SCALE_LEVEL_2:
        return 1.2; // Medium zoom
      case Consts.SCALE_LEVEL_3:
        return 1.0; // Least zoomed in (full view)
      default:
        return 1.5;
    }
  }
  
  /// Builds error placeholder when image fails to load
  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 12.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: Consts.getDimension(context, 80.0),
            color: Colors.grey.shade600,
          ),
          SizedBox(height: Consts.getSpacing(context, 16.0)),
          Text(
            'Image not found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: Consts.getFontSize(context, 32.0),
              fontFamily: Consts.FONT_MAIN,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Consts.getSpacing(context, 8.0)),
          Text(
            mission.imagePath,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: Consts.getFontSize(context, 24.0),
              fontFamily: Consts.FONT_MAIN,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}