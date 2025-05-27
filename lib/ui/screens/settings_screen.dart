import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/widgets/title_bar.dart';

/// Settings screen that displays game settings and player information
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showAvatarSelectorOverlay = false;

  @override
  void initState() {
    super.initState();
    print("SettingsScreen.initState initializing settings screen");
  }

  /// Handle sound toggle
  void _toggleSound(bool value) {
    print("SettingsScreen.toggleSound sound toggled to: $value");
    
    setState(() {
      DPlayer.isSoundEnabled = value;
    });
  }

  /// Handle music toggle
  void _toggleMusic(bool value) {
    print("SettingsScreen.toggleMusic music toggled to: $value");
    
    setState(() {
      DPlayer.isMusicEnabled = value;
    });
  }

  /// Show reset game confirmation dialog
  void _showResetGameDialog() {
    print("SettingsScreen.showResetGameDialog showing reset confirmation");
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Game',
            style: TextStyle(
              fontSize: Consts.getFontSize(context, 36.0),
              fontFamily: Consts.FONT_MAIN,
              fontWeight: FontWeight.normal,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all game progress? This action cannot be undone.',
            style: TextStyle(
              fontSize: Consts.getFontSize(context, 28.0),
              fontFamily: Consts.FONT_MAIN,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: Consts.getFontSize(context, 28.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: Consts.getFontSize(context, 28.0),
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reset the game progress
  Future<void> _resetGame() async {
    print("SettingsScreen.resetGame resetting game progress");
    
    try {
      await DPlayer.resetProgress();
      
      Fluttertoast.showToast(
        msg: "Game progress has been reset",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      print("SettingsScreen.resetGame error: $e");
      
      Fluttertoast.showToast(
        msg: "Failed to reset game progress",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Show avatar selection overlay with animation
  void _showAvatarSelection() {
    print("SettingsScreen.showAvatarSelection opening avatar selector");
    
    setState(() {
      _showAvatarSelectorOverlay = true;
    });
  }

  /// Close avatar selection overlay with animation
  void _closeAvatarSelection() {
    print("SettingsScreen.closeAvatarSelection closing avatar selector");
    
    setState(() {
      _showAvatarSelectorOverlay = false;
    });
  }

  /// Handle avatar selection
  void _selectAvatar(int index) {
    print("SettingsScreen.selectAvatar selected avatar index: $index");
    
    setState(() {
      DPlayer.currentAvatarIndex = index;
    });
    _closeAvatarSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main settings content
          Column(
            children: [
              // Title bar
              TitleBar(
                title: "GAME SETTINGS",
                onBackPressed: () {
                  print("SettingsScreen.build back button pressed");
                  // Navigate to menu_screen instead of just popping
                  Navigator.of(context).pushReplacementNamed('/menu');
                },
              ),
              
              // Settings content
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Player profile section
                        _buildPlayerProfileSection(),
                        
                        // Main separator (32px) between avatar and settings
                        _buildMainSeparator(),
                        
                        // Settings options
                        _buildSettingsOptions(),
                        
                        // Reset game button
                        _buildResetGameButton(),
                        
                        // Bottom spacing
                        SizedBox(height: Consts.getDimension(context, 40.0)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Avatar selector overlay
          if (_showAvatarSelectorOverlay) _buildAvatarSelectorOverlay(),
        ],
      ),
    );
  }

  /// Build the player profile section with avatar and ID
  Widget _buildPlayerProfileSection() {
    final avatarSize = Consts.getDimension(context, 160.0);
    final spacing = Consts.getDimension(context, 24.0);
    final changeButtonSize = Consts.getDimension(context, 48.0);
    
    return Container(
      padding: EdgeInsets.all(spacing),
      color: Colors.white,
      child: Row(
        children: [
          // Avatar with change button overlay
          GestureDetector(
            onTap: _showAvatarSelection,
            child: Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF33CCCC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51), // Drop shadow
                        offset: Offset(0, Consts.getDimension(context, 4.0)),
                        blurRadius: Consts.getDimension(context, 8.0),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      '${Consts.PATH_ICONS}${DPlayer.currentAvatarFileName}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF33CCCC),
                          child: Icon(
                            Icons.person,
                            size: avatarSize * 0.6,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Change avatar button (orange circle with arrows)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: changeButtonSize,
                    height: changeButtonSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: Consts.getDimension(context, 2.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          offset: Offset(0, Consts.getDimension(context, 2.0)),
                          blurRadius: Consts.getDimension(context, 4.0),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cached,
                      color: Colors.white,
                      size: Consts.getDimension(context, 24.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: spacing),
          
          // Player ID section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your ID',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: Consts.getFontSize(context, 32.0),
                    fontFamily: Consts.FONT_MAIN,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: Consts.getDimension(context, 8.0)),
                Text(
                  DPlayer.currentPlayerId,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: Consts.getFontSize(context, 38.0),
                    fontFamily: Consts.FONT_MAIN,
                    fontWeight: FontWeight.normal,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a separator line for between avatar section and settings
  Widget _buildMainSeparator() {
    return Container(
      height: Consts.getDimension(context, 32.0), // 32px gap for avatar section
      color: const Color(Consts.COLOR_LINE_GRAY),
    );
  }

  /// Build a thin separator line between setting rows
  Widget _buildRowSeparator() {
    return Container(
      height: Consts.getDimension(context, 1.0), // 1px gap between setting rows
      color: const Color(Consts.COLOR_LINE_GRAY),
    );
  }

  /// Build the settings options list
  Widget _buildSettingsOptions() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Sound setting
          _buildSettingItem(
            title: 'Sound',
            trailing: _buildToggleSwitch(DPlayer.isSoundEnabled, _toggleSound),
          ),
          
          _buildRowSeparator(),
          
          // Music setting
          _buildSettingItem(
            title: 'Music',
            trailing: _buildToggleSwitch(DPlayer.isMusicEnabled, _toggleMusic),
          ),
          
          _buildRowSeparator(),
          
          // Rate Game
          _buildSettingItem(
            title: 'Rate Game',
            onTap: () {
              print("SettingsScreen.buildSettingsOptions rate game tapped");
              Fluttertoast.showToast(
                msg: "Opening app store...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
          ),
          
          _buildRowSeparator(),
          
          // About Us
          _buildSettingItem(
            title: 'About Us',
            onTap: () {
              print("SettingsScreen.buildSettingsOptions about us tapped");
              Fluttertoast.showToast(
                msg: "About Us clicked",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
          ),
          
          _buildRowSeparator(),
          
          // Our Fanpage
          _buildSettingItem(
            title: 'Our Fanpage',
            onTap: () {
              print("SettingsScreen.buildSettingsOptions fanpage tapped");
              Fluttertoast.showToast(
                msg: "Opening fanpage...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build a single setting item
  Widget _buildSettingItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // Row height = max(0.08 screen height, Consts.getDimension(context, 120.0))
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedHeight = screenHeight * 0.08;
    final minimumHeight = Consts.getDimension(context, 120.0);
    final lineHeight = calculatedHeight > minimumHeight ? calculatedHeight : minimumHeight;
    final horizontalPadding = Consts.getDimension(context, 24.0);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: lineHeight, // Height = max(0.08 screen height, Consts.getDimension(context, 120.0))
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: Consts.getFontSize(context, 36.0),
                  fontFamily: Consts.FONT_MAIN,
                  fontWeight: FontWeight.normal,
                  height: 1.0,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  /// Build a toggle switch widget
  Widget _buildToggleSwitch(bool value, ValueChanged<bool> onChanged) {
    // Calculate switch size to match text height
    final textFontSize = Consts.getFontSize(context, 36.0);
    final switchScale = textFontSize / 24.0; // Default switch height is ~24px
    
    return Transform.scale(
      scale: switchScale,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF4CAF50),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFBDBDBD),
      ),
    );
  }

  /// Build the reset game button
  Widget _buildResetGameButton() {
    final buttonWidth = Consts.getDimension(context, 520.0);
    final buttonHeight = Consts.getDimension(context, 128.0);
    final buttonMargin = Consts.getDimension(context, 64.0);
    final borderRadius = Consts.getRadius(context, 64.0);
    
    return Container(
      margin: EdgeInsets.all(buttonMargin),
      child: GestureDetector(
        onTap: _showResetGameDialog,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7B68EE),
                Color(0xFF4169E1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                offset: Offset(0, Consts.getDimension(context, 6.0)),
                blurRadius: Consts.getDimension(context, 12.0),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'RESET GAME',
              style: TextStyle(
                color: Colors.white,
                fontSize: Consts.getFontSize(context, 48.0),
                fontFamily: Consts.FONT_MAIN, // Already using FONT_MAIN
                fontWeight: FontWeight.normal,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the avatar selector overlay with animations
  Widget _buildAvatarSelectorOverlay() {
    return AnimatedOpacity(
      opacity: _showAvatarSelectorOverlay ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: AnimatedScale(
        scale: _showAvatarSelectorOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: Container(
          color: Colors.black.withAlpha(51), // Full screen black with 0.2 alpha
          child: Center(
            child: _buildAvatarSelectionContent(),
          ),
        ),
      ),
    );
  }

  /// Build the avatar selection content
  Widget _buildAvatarSelectionContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final gap = Consts.getDimension(context, 44.0);
    final avatarWidth = (screenWidth - gap * 4) / 3; // (screenWidth - gap * 4) / 3
    final avatarHeight = (320 / 300) * avatarWidth; // Keep 320/300 ratio
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar grid - 3 columns, 2 rows
        Container(
          padding: EdgeInsets.all(gap),
          child: Column(
            children: [
              // First row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarOption(0, avatarWidth, avatarHeight),
                  SizedBox(width: gap),
                  _buildAvatarOption(1, avatarWidth, avatarHeight),
                  SizedBox(width: gap),
                  _buildAvatarOption(2, avatarWidth, avatarHeight),
                ],
              ),
              SizedBox(height: gap),
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarOption(3, avatarWidth, avatarHeight),
                  SizedBox(width: gap),
                  _buildAvatarOption(4, avatarWidth, avatarHeight),
                  SizedBox(width: gap),
                  _buildAvatarOption(5, avatarWidth, avatarHeight),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: gap),
        
        // Close button with gradient
        GestureDetector(
          onTap: _closeAvatarSelection,
          child: Container(
            width: Consts.getDimension(context, 300.0),
            height: Consts.getDimension(context, 92.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF8763FD), // From 0x8763fd
                  Color(0xFF2A85F6), // To 0x2a85f6
                ],
              ),
              borderRadius: BorderRadius.circular(Consts.getRadius(context, 40.0)),
            ),
            child: Center(
              child: Text(
                'CLOSE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Consts.getFontSize(context, 40.0),
                  fontFamily: Consts.FONT_MAIN,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a single avatar option in the selector
  Widget _buildAvatarOption(int index, double avatarWidth, double avatarHeight) {
    final isSelected = index == DPlayer.currentAvatarIndex;
    final checkSize = avatarWidth * 0.25; // Check size = 0.3 * avatarWidth
    
    return GestureDetector(
      onTap: () => _selectAvatar(index),
      child: SizedBox(
        width: avatarWidth,
        height: avatarHeight, // Increase height to accommodate lowered check icon
        child: Stack(
          children: [
            // Avatar image with drop shadow, no border
            Container(
              width: avatarWidth,
              height: avatarHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // Drop shadow
                    offset: Offset(0, Consts.getDimension(context, 4.0)),
                    blurRadius: Consts.getDimension(context, 8.0),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  '${Consts.PATH_ICONS}${Consts.listAvatars[index]}',
                  width: avatarWidth,
                  height: avatarHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF33CCCC),
                      child: Icon(
                        Icons.person,
                        size: avatarWidth * 0.6,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Selected indicator - align center x, bottom y (lowered by 8px)
            if (isSelected)
              Positioned(
                left: (avatarWidth - checkSize) / 2, // Center X
                bottom: 0, // Bottom point lowered by 8px
                child: Container(
                  width: checkSize, // width = 0.3 * avatarWidth
                  height: checkSize, // height = width
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: checkSize * 0.6, // Icon size proportional to container
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}