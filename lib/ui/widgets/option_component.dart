import 'dart:math';
import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

/// Option component that displays 14 letter buttons in 2 rows × 7 columns
/// for the word guessing game
class OptionComponent extends StatefulWidget {
  final List<String> letters;
  final List<bool> selectedStates;
  final Function(int, String)? onLetterSelected;
  
  const OptionComponent({
    Key? key,
    required this.letters,
    required this.selectedStates,
    this.onLetterSelected,
  }) : super(key: key);

  @override
  State<OptionComponent> createState() => OptionComponentState();
}

class OptionComponentState extends State<OptionComponent>
    with TickerProviderStateMixin {
  
  List<AnimationController> _shakeControllers = [];
  List<Animation<double>> _shakeAnimations = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  @override
  void dispose() {
    for (var controller in _shakeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _initializeAnimations() {
    _shakeControllers.clear();
    _shakeAnimations.clear();
    
    for (int i = 0; i < 14; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
      
      _shakeControllers.add(controller);
      _shakeAnimations.add(animation);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("{OptionComponent.build} Building option component with ${widget.letters.length} letters");
    
    // Calculate responsive dimensions according to specifications
    final screenWidth = MediaQuery.of(context).size.width;
    final tmpGapButton = Consts.getDimension(context, 16.0); // Responsive gap between buttons
    final tmpGapButtonLeftRight = Consts.getDimension(context, 48.0); // Responsive gap from screen border
    
    // Calculate minimum option button width
    final minOptionButtonWidth = (screenWidth - tmpGapButton * (Consts.OPTION_COLS - 1) - tmpGapButtonLeftRight * 2) / Consts.OPTION_COLS;
    
    // Button dimensions - width = min(128, minOptionButtonWidth)
    final maxButtonWidth = Consts.getDimension(context, 128.0); // Responsive max width
    final buttonWidth = (minOptionButtonWidth < maxButtonWidth ? minOptionButtonWidth : maxButtonWidth).clamp(
      Consts.getDimension(context, 60.0), // Responsive min width 
      maxButtonWidth
    );
    final buttonHeight = Consts.getDimension(context, 120.0); // Responsive height
    final spacing = tmpGapButton; // Use responsive spacing
    final fontSize = Consts.getFontSize(context, 90.0).clamp(28.0, 90.0); // Minimum 28px font for readability
    final borderRadius = Consts.getDimension(context, 14.0).clamp(8.0, 20.0); // Minimum 8px radius
    
    print("{OptionComponent.build} Calculated sizes - Button: ${buttonWidth}x${buttonHeight}, Font: $fontSize");
    
    return Container(
      width: screenWidth,
      padding: EdgeInsets.symmetric(horizontal: tmpGapButtonLeftRight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First row (buttons 0-6)
          _buildButtonRow(
            context,
            0,
            Consts.OPTION_COLS,
            buttonWidth,
            buttonHeight,
            spacing,
            fontSize,
            borderRadius,
          ),
          
          SizedBox(height: spacing),
          
          // Second row (buttons 7-13)
          _buildButtonRow(
            context,
            7,
            Consts.OPTION_COLS,
            buttonWidth,
            buttonHeight,
            spacing,
            fontSize,
            borderRadius,
          ),
        ],
      ),
    );
  }
  
  Widget _buildButtonRow(BuildContext context, int startIndex, int count,
                        double buttonWidth, double buttonHeight, double spacing, 
                        double fontSize, double borderRadius) {
    
    List<Widget> buttons = [];
    
    for (int i = 0; i < count && (startIndex + i) < widget.letters.length; i++) {
      final letterIndex = startIndex + i;
      final letter = widget.letters[letterIndex];
      final isSelected = letterIndex < widget.selectedStates.length ? widget.selectedStates[letterIndex] : false;
      
      buttons.add(_buildLetterButton(
        context,
        letter,
        letterIndex,
        isSelected,
        buttonWidth,
        buttonHeight,
        fontSize,
        borderRadius,
      ));
      
      // Add spacing between buttons (except after the last one)
      if (i < count - 1 && (startIndex + i + 1) < widget.letters.length) {
        buttons.add(SizedBox(width: spacing));
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }
  
  Widget _buildLetterButton(BuildContext context, String letter, int index,
                           bool isSelected, double buttonWidth, double buttonHeight, 
                           double fontSize, double borderRadius) {
    
    // Check if letter is removed (empty string) or selected
    final bool isRemoved = letter.isEmpty;
    final bool shouldHide = isSelected || isRemoved;
    
    return AnimatedBuilder(
      animation: index < _shakeAnimations.length ? _shakeAnimations[index] : 
                 AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        // Shake effect calculation
        final shakeValue = index < _shakeAnimations.length ? _shakeAnimations[index].value : 0.0;
        final shakeOffset = sin(shakeValue * 3.14159 * 6) * 10 * (1 - shakeValue);
        
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Opacity(
            opacity: shouldHide ? 0.0 : 1.0, // Hide instead of fade when selected/removed
            child: InnerShadowButton(
              width: buttonWidth,
              height: buttonHeight,
              borderRadius: borderRadius,
              backgroundColor: Colors.white,
              shadowColor: const Color(0xFF8bdaf1), // shadowColor: 0x8bdaf1
              shadowSize: Consts.getDimension(context, 8.0).clamp(3.0, 12.0), // Responsive shadow size with minimum
              dropShadowSize: Consts.getDimension(context, 8.0).clamp(3.0, 12.0), // Responsive drop shadow with minimum
              onPressed: shouldHide ? null : () => _onLetterPressed(index, letter),
              showToastOnPress: false,
              child: Center(
                child: Text(
                  isRemoved ? '' : letter,
                  style: TextStyle(
                    color: const Color(Consts.COLOR_MAIN_TEXT), // color: Const.COLOR_MAIN_TEXT
                    fontSize: fontSize, // fontSize = 90
                    fontFamily: Consts.FONT_TITLE, // Font: Const.FONT_TITLE
                    fontWeight: FontWeight.normal, // normal weight
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center, // Center align both x and y
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _onLetterPressed(int index, String letter) {
    print("{OptionComponent._onLetterPressed} Letter '$letter' pressed at index $index");
    
    if (widget.onLetterSelected != null) {
      // The parent will determine if it's correct or wrong and call back
      widget.onLetterSelected!(index, letter);
    }
  }
  
  /// Trigger shake animation for wrong letter
  void shakeButton(int index) {
    if (index >= 0 && index < _shakeControllers.length) {
      _shakeControllers[index].forward().then((_) {
        _shakeControllers[index].reset();
      });
    }
  }
}