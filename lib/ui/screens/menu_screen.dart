import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/ui/widgets/custom_gradient_progress_bar.dart';
import 'package:claude_cuc/ui/screens/list_episode_screen.dart';
import 'package:claude_cuc/ui/screens/list_level_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedTopHeight = screenHeight * 0.25;
    final minTopHeight = Consts.getDimension(context, 520); // Responsive 480px based on 1080px mockup
    final topViewHeight = calculatedTopHeight < minTopHeight ? minTopHeight : calculatedTopHeight;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFF42c0ce), // Bottom color
              Color(0xFF15d5f6), // Top color
            ],
          ),
        ),
        child: Stack(
          children: [
            // TopView
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topViewHeight,
              child: _buildTopView(context),
            ),
            
            // BottomView (overlays TopView)
            Positioned(
              top: topViewHeight - Consts.getDimension(context, 40), // Start slightly overlapping
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopView(BuildContext context) {
    return Column(
      children: [
        // TopBar
        _buildTopBar(context),
        
        // Spacer to push PlayerStats to bottom
        const Spacer(),
        
        // PlayerStats
        _buildPlayerStats(context),
        
        // Bottom padding
        SizedBox(height: Consts.getDimension(context, 20)),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Consts.getDimension(context, 8),
        right: Consts.getDimension(context, 8),
        top: MediaQuery.of(context).padding.top + Consts.getDimension(context, 8),
      ),
      child: Row(
        children: [
          // Shop Button
          GestureDetector(
            onTap: _onShopPressed,
            child: Image.asset(
              'assets/images/btn_shop.png',
              width: Consts.getDimension(context, 150),
              height: Consts.getDimension(context, 150),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: Consts.getDimension(context, 150),
                  height: Consts.getDimension(context, 150),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(Consts.getRadius(context, 12)),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: Consts.getDimension(context, 60),
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          
          // Title
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  // Drop shadow
                  Positioned(
                    left: Consts.getDimension(context, 2),
                    top: Consts.getDimension(context, 2),
                    child: Text(
                      'CLOSE UP CHARACTER',
                      style: TextStyle(
                        fontFamily: Consts.FONT_TITLE,
                        fontSize: Consts.getFontSize(context, 64),
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withAlpha(76), // 0.3 * 255 ≈ 76
                      ),
                    ),
                  ),
                  // Main text
                  Text(
                    'CLOSE UP CHARACTER',
                    style: TextStyle(
                      fontFamily: Consts.FONT_TITLE,
                      fontSize: Consts.getFontSize(context, 64),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Settings Button
          GestureDetector(
            onTap: _onSettingsPressed,
            child: Image.asset(
              'assets/images/btn_setting.png',
              width: Consts.getDimension(context, 108),
              height: Consts.getDimension(context, 108),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: Consts.getDimension(context, 108),
                  height: Consts.getDimension(context, 108),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    size: Consts.getDimension(context, 54),
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final centerX = screenWidth / 2;
    final rightX = centerX - Consts.getDimension(context, 132);
    final leftImageWidth = Consts.getDimension(context, 288);
    final leftImageHeight = Consts.getDimension(context, 320);
    final leftX = rightX - Consts.getDimension(context, 28) - leftImageWidth;
    
    // Make PlayerStats panel higher by 0.02% of screen height and reduce Y position
    final heightIncrease = screenHeight * 0.0005; // 0.02% of screen height
    final adjustedHeight = leftImageHeight + heightIncrease;
    final yOffset = -Consts.getDimension(context, 10); // Reduce Y position a bit
    
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: SizedBox(
        height: adjustedHeight,
        child: Stack(
          children: [
            // Left icon
            Positioned(
              left: leftX,
              bottom: 0,
              child: Image.asset(
                'assets/images/ic_menu.png',
                width: leftImageWidth,
                height: leftImageHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: leftImageWidth,
                    height: leftImageHeight,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(Consts.getRadius(context, 20)),
                    ),
                    child: Icon(
                      Icons.person,
                      size: leftImageWidth * 0.6,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            
            // Right stats panel
            Positioned(
              left: rightX,
              bottom: 0,
              child: Container(
                width: Consts.getDimension(context, 600),
                height: adjustedHeight,
                padding: EdgeInsets.all(Consts.getDimension(context, 20)),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(25), // Black with alpha 0.1 (25/255 ≈ 0.1)
                  borderRadius: BorderRadius.circular(Consts.getRadius(context, 44)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mission solved text
                    Text(
                      '${DPlayer.levelCompletedCount} PICS SOLVED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Consts.FONT_MAIN,
                        fontSize: Consts.getFontSize(context, 40),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF), // White color
                      ),
                    ),
                    
                    SizedBox(height: Consts.getSpacing(context, 8)),
                    
                    // Game completed ratio
                    Text(
                      '${(DPlayer.gameCompleteRatio * 100).toStringAsFixed(1)}% GAME COMPLETED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Consts.FONT_MAIN,
                        fontSize: Consts.getFontSize(context, 32),
                        color: const Color(0xFFFFFFFF), // White color
                      ),
                    ),
                    
                    SizedBox(height: Consts.getSpacing(context, 16)),
                    
                    // Progress bar
                    CustomGradientProgressBar(
                      value: DPlayer.gameCompleteRatio,
                      width: Consts.getDimension(context, 428),
                      height: Consts.getDimension(context, 24),
                      gradientColors: const [
                        Color(0xFFf4a425),
                        Color(0xFFf4a425),
                      ],
                      backgroundColor: const Color(0xFFe0f0fc),
                      borderRadius: Consts.getRadius(context, 12),
                      dropShadowSize: 0, // Hide drop shadow
                    ),
                    
                    SizedBox(height: Consts.getSpacing(context, 16)),
                    
                    // Combined better than text
                    Text(
                      "You're better than:\n82.2% players!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Consts.FONT_MAIN,
                        fontSize: Consts.getFontSize(context, 36),
                        color: const Color(0xFFFFFFFF), // White color
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Line height for better spacing
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(242), // 0.95 * 255 ≈ 242
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Consts.getRadius(context, 30)),
          topRight: Radius.circular(Consts.getRadius(context, 30)),
        ),
      ),
      child: Column(
        children: [
          // Tab selector
          Container(
            margin: EdgeInsets.all(Consts.getDimension(context, 20)),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(Consts.getRadius(context, 25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Consts.getDimension(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0 ? AppColors.buttonBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(Consts.getRadius(context, 25)),
                      ),
                      child: Text(
                        'Daily Challenge',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Consts.FONT_MAIN,
                          fontSize: Consts.getFontSize(context, 32),
                          fontWeight: FontWeight.bold,
                          color: _currentIndex == 0 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: Consts.getDimension(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1 ? AppColors.buttonBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(Consts.getRadius(context, 25)),
                      ),
                      child: Text(
                        'Choose game pack to play',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Consts.FONT_MAIN,
                          fontSize: Consts.getFontSize(context, 32),
                          fontWeight: FontWeight.bold,
                          color: _currentIndex == 1 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                ListEpisodeScreen(),
                ListLevelScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onShopPressed() {
    // TODO: Implement shop functionality
    debugPrint('Shop button pressed');
  }

  void _onSettingsPressed() {
    // TODO: Implement settings functionality
    debugPrint('Settings button pressed');
  }
}