import 'package:flutter/material.dart';

class ImageButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onPressed;

  const ImageButton({
    Key? key,
    required this.imagePath,
    this.onPressed,
  }) : super(key: key);

  @override
  ImageButtonState createState() => ImageButtonState();
}

// Make the state class public
class ImageButtonState extends State<ImageButton> {
  String _character = ''; // Default empty text

  void setCharacter(String newCharacter) {
    setState(() {
      _character = newCharacter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            widget.imagePath,
            width: 80, // Adjust width as needed
            height: 80, // Adjust height as needed
            fit: BoxFit.cover,
          ),
          Text(
            _character,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
