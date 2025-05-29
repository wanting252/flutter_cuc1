import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/data/models/d_player.dart';
import 'package:claude_cuc/data/models/d_mission.dart';
import 'package:claude_cuc/data/models/d_level.dart';
import 'package:claude_cuc/data/models/d_episode.dart';
import 'package:claude_cuc/ui/widgets/custom_gradient_progress_bar.dart';
import 'package:claude_cuc/ui/widgets/coin_display.dart';
import 'package:claude_cuc/ui/widgets/picture_component.dart';
import 'package:claude_cuc/ui/widgets/answer_component.dart';
import 'package:claude_cuc/ui/widgets/option_component.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

class PlayScreen extends StatefulWidget {
  final String episodeId;
  final String levelId;
  
  const PlayScreen({
    Key? key,
    required this.episodeId,
    required this.levelId,
  }) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late DEpisode currentEpisode;
  late DLevel currentLevel;
  late DMission currentMission;
  int currentZoomLevel = Consts.SCALE_LEVEL_1;
  List<String> playerAnswer = [];
  List<String> optionLetters = [];
  List<bool> selectedOptions = [];
  
  // Key to access OptionComponent for shake animation
  final GlobalKey<OptionComponentState> _optionKey = GlobalKey<OptionComponentState>();
  
  @override
  void initState() {
    super.initState();
    print("{PlayScreen.initState} Initializing play screen");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }
  
  @override
  void dispose() {
    // Save current mission state when leaving the screen
    if (mounted) {
      currentMission.saveMissionState();
    }
    super.dispose();
  }
  
  void _initializeGame() async {
    print("{PlayScreen._initializeGame} Setting up game data");
    
    // Find the current episode and level
    currentEpisode = DPlayer.episodes.firstWhere((ep) => ep.id == widget.episodeId);
    currentLevel = currentEpisode.levels.firstWhere((level) => level.id == widget.levelId);
    
    // Get current mission based on level progress
    if (currentLevel.currentIndex < currentLevel.answers.length) {
      currentMission = currentLevel.answers[currentLevel.currentIndex];
    } else {
      // Level completed, show first mission
      currentMission = currentLevel.answers.first;
    }
    
    await _loadMissionState();
  }
  
  Future<void> _loadMissionState() async {
    print("{PlayScreen._loadMissionState} Loading mission state");
    
    // Load saved mission state
    await currentMission.loadMissionState();
    
    // If no options generated yet, generate them
    if (!currentMission.hasGeneratedOptions) {
      currentMission.generateOptionLetters();
    }
    
    // Update local state from mission
    setState(() {
      currentZoomLevel = currentMission.currentZoomLevel;
      playerAnswer = List.from(currentMission.playerAnswer);
      optionLetters = List.from(currentMission.optionLetters);
      selectedOptions = List.from(currentMission.selectedOptions);
    });
    
    print("{PlayScreen._loadMissionState} Mission state loaded");
  }
  
  void _onLetterSelected(int index, String letter) {
    print("{PlayScreen._onLetterSelected} Letter '$letter' selected at index $index");
    
    if (selectedOptions[index]) return; // Already selected
    
    // Check if this letter is correct for the next position
    final nextEmptyPosition = currentMission.getNextEmptyPosition();
    if (nextEmptyPosition == -1) return; // No empty positions
    
    final correctAnswer = currentMission.answer.toUpperCase();
    final expectedLetter = correctAnswer[nextEmptyPosition];
    
    if (letter == expectedLetter) {
      // CORRECT: Fill the answer
      if (currentMission.selectOptionLetter(index)) {
        setState(() {
          playerAnswer = List.from(currentMission.playerAnswer);
          selectedOptions = List.from(currentMission.selectedOptions);
        });
        
        // Save state and check answer
        currentMission.saveMissionState();
        _checkAnswer();
      }
    } else {
      // WRONG: Shake the button and don't fill answer
      _optionKey.currentState?.shakeButton(index);
      print("{PlayScreen._onLetterSelected} Wrong letter! Expected '$expectedLetter', got '$letter'");
    }
  }
  
  void _onAnswerLetterRemoved(int answerIndex) {
    print("{PlayScreen._onAnswerLetterRemoved} Removing letter at answer index $answerIndex");
    
    if (currentMission.removeLetterAt(answerIndex)) {
      setState(() {
        playerAnswer = List.from(currentMission.playerAnswer);
        selectedOptions = List.from(currentMission.selectedOptions);
      });
      
      // Save state
      currentMission.saveMissionState();
    }
  }
  
  void _checkAnswer() {
    if (currentMission.checkAnswer()) {
      _onCorrectAnswer();
    }
  }
  
  void _onCorrectAnswer() async {
    print("{PlayScreen._onCorrectAnswer} Correct answer!");
    
    // Clear mission state since it's completed
    await currentMission.clearMissionState();
    
    // Award coins and advance mission
    DPlayer.coin += 10;
    currentLevel.currentIndex++;
    await currentLevel.saveProgress();
    await DPlayer.savePlayerPrefs();
    
    // Show success message
    Fluttertoast.showToast(
      msg: "Correct! +10 coins",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    
    // Move to next mission or complete level
    if (currentLevel.currentIndex < currentLevel.answers.length) {
      // Load next mission
      setState(() {
        currentMission = currentLevel.answers[currentLevel.currentIndex];
      });
      await _loadMissionState();
    } else {
      // Level completed
      _onLevelCompleted();
    }
  }
  
  void _onLevelCompleted() async {
    print("{PlayScreen._onLevelCompleted} Level completed!");
    
    Fluttertoast.showToast(
      msg: "Level Completed! +50 bonus coins",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
    
    DPlayer.coin += 50;
    await DPlayer.savePlayerPrefs();
    
    // Return to level selection or episode selection
    Navigator.pop(context);
  }
  
  void _onZoomPressed() async {
    if (DPlayer.coin >= 60) {
      if (currentZoomLevel < Consts.SCALE_LEVEL_3) {
        setState(() {
          currentZoomLevel++;
          currentMission.currentZoomLevel = currentZoomLevel;
        });
        
        DPlayer.coin -= 60;
        await DPlayer.savePlayerPrefs();
        await currentMission.saveMissionState();
        
        Fluttertoast.showToast(
          msg: "Zoom level increased! -60 coins",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Maximum zoom level reached",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Not enough coins! Need 60 coins",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  
  void _onAnswerPressed() async {
    if (DPlayer.coin >= 40) {
      if (currentMission.fillNextCorrectLetter()) {
        setState(() {
          playerAnswer = List.from(currentMission.playerAnswer);
          selectedOptions = List.from(currentMission.selectedOptions);
        });
        
        DPlayer.coin -= 40;
        await DPlayer.savePlayerPrefs();
        await currentMission.saveMissionState();
        
        Fluttertoast.showToast(
          msg: "Letter revealed! -40 coins",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );
        
        _checkAnswer();
      } else {
        Fluttertoast.showToast(
          msg: "No more letters to reveal",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Not enough coins! Need 40 coins",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  
  void _onRemovePressed() async {
    if (DPlayer.coin >= 20) {
      if (currentMission.removeWrongLetter()) {
        setState(() {
          optionLetters = List.from(currentMission.optionLetters);
        });
        
        DPlayer.coin -= 20;
        await DPlayer.savePlayerPrefs();
        await currentMission.saveMissionState();
        
        Fluttertoast.showToast(
          msg: "Wrong letter removed! -20 coins",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "No wrong letters to remove",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Not enough coins! Need 20 coins",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  
  void _onSkipPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Skip Mission"),
        content: const Text("Are you sure you want to skip this mission?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await currentMission.clearMissionState(); // Clear state when skipping
              _onCorrectAnswer(); // Skip to next mission
            },
            child: const Text("Skip"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("{PlayScreen.build} Building play screen");
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate the 4 virtual area heights with responsive scaling
    final topBarHeight = Consts.getDimension(context, 144.0); // Responsive top bar
    final titleSectionHeight = (0.1 * screenHeight).clamp(
      Consts.getDimension(context, 150.0), // Responsive min
      Consts.getDimension(context, 250.0)  // Responsive max
    );
    final topAreaHeight = topBarHeight + titleSectionHeight;
    
    final answerAreaHeight = (0.15 * screenHeight).clamp(
      Consts.getDimension(context, 150.0), // Responsive min
      Consts.getDimension(context, 300.0)  // Responsive max
    );
    
    final optionAreaHeight = (0.25 * screenHeight).clamp(
      Consts.getDimension(context, 446.0), // Responsive min (from mockup)
      Consts.getDimension(context, 500.0)  // Responsive max
    );
    
    // Calculate center area height with minimum constraint
    final remainingHeight = screenHeight - topAreaHeight - answerAreaHeight - optionAreaHeight;
    final centerAreaHeight = remainingHeight.clamp(
      Consts.getDimension(context, 200.0), // Responsive minimum
      double.infinity
    );
    
    // Debug print to check calculations
    print("{PlayScreen.build} Screen: ${screenHeight.toInt()}, Top: ${topAreaHeight.toInt()}, Center: ${centerAreaHeight.toInt()}, Answer: ${answerAreaHeight.toInt()}, Option: ${optionAreaHeight.toInt()}");
    
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF), // White background
        ),
        child: Column(
          children: [
            // Top Area (TopBar + Title)
            Container(
              height: topAreaHeight,
              child: _buildTopArea(screenWidth, topBarHeight, titleSectionHeight),
            ),
            
            // Center Area (PictureComponent + help buttons)
            Container(
              height: centerAreaHeight,
              child: _buildCenterArea(screenWidth, centerAreaHeight),
            ),
            
            // AnswerComponent Area
            Container(
              height: answerAreaHeight,
              child: _buildAnswerArea(screenWidth, answerAreaHeight),
            ),
            
            // OptionComponent Area
            Container(
              height: optionAreaHeight,
              child: _buildOptionArea(screenWidth, optionAreaHeight),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopArea(double screenWidth, double topBarHeight, double titleSectionHeight) {
    return Column(
      children: [
        // TopBar Section
        Container(
          width: screenWidth,
          height: topBarHeight, // Already responsive from build method
          padding: EdgeInsets.symmetric(horizontal: Consts.getSpacing(context, 24.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button - single icon
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  size: Consts.getDimension(context, 84.0), // 84x84
                  color: const Color(Consts.COLOR_MAIN_TEXT),
                ),
              ),
              
              // Custom coin box
              _buildCoinBox(context),
            ],
          ),
        ),
        
        // Title Section
        Container(
          width: screenWidth,
          height: titleSectionHeight, // Already responsive from build method
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level title
              Text(
                _formatLevelTitle(currentEpisode.name, currentLevel.id),
                style: TextStyle(
                  color: const Color(0xFF34495e),
                  fontSize: Consts.getFontSize(context, 72.0),
                  fontFamily: Consts.FONT_TITLE,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: Consts.getSpacing(context, 16.0)),
              
              // Progress bar
              SizedBox(
                width: screenWidth * 0.5,
                child: CustomGradientProgressBar(
                  value: currentLevel.answers.isEmpty ? 0.0 : 
                         (currentLevel.currentIndex / currentLevel.answers.length).clamp(0.0, 1.0),
                  height: Consts.getDimension(context, 24.0),
                  gradientColors: const [
                    Color(0xFF02A3FF),
                    Color(0xFF2AF6CD),
                  ],
                  backgroundColor: const Color(0xFFE0E0E0),
                  borderRadius: Consts.getRadius(context, 12.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCenterArea(double screenWidth, double centerAreaHeight) {
    // Calculate picture component width (assuming square)
    final pictureSize = Consts.getDimension(context, 400.0);
    final gapHelpButton = (screenWidth - pictureSize) / 2;
    
    return Container(
      width: screenWidth,
      height: centerAreaHeight,
      child: Stack(
        children: [
          // Picture Component (center)
          Center(
            child: PictureComponent(
              mission: currentMission,
              zoomLevel: currentZoomLevel,
            ),
          ),
          
          // Left buttons
          Positioned(
            left: gapHelpButton / 2 - Consts.getDimension(context, 66.0), // Center in left gap (132/2 = 66)
            top: centerAreaHeight / 2 - Consts.getDimension(context, 200.0), // Center in gap, adjusted for 3 buttons
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.zoom_in,
                  label: "Zoom",
                  badgeCount: currentZoomLevel,
                  onPressed: _onZoomPressed,
                ),
                SizedBox(height: Consts.getSpacing(context, 16.0)),
                _buildActionButton(
                  icon: Icons.edit,
                  label: "Answer",
                  badgeCount: 40,
                  onPressed: _onAnswerPressed,
                ),
                SizedBox(height: Consts.getSpacing(context, 16.0)),
                _buildActionButton(
                  icon: Icons.delete,
                  label: "Remove",
                  badgeCount: 20,
                  onPressed: _onRemovePressed,
                ),
              ],
            ),
          ),
          
          // Right button (skip)
          Positioned(
            right: gapHelpButton / 2 - Consts.getDimension(context, 66.0), // Center in right gap
            top: centerAreaHeight / 2 - Consts.getDimension(context, 66.0), // Center vertically
            child: _buildSkipButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnswerArea(double screenWidth, double answerAreaHeight) {
    return Container(
      width: screenWidth,
      height: answerAreaHeight,
      child: Center(
        child: AnswerComponent(
          answer: playerAnswer,
          onLetterRemoved: _onAnswerLetterRemoved,
        ),
      ),
    );
  }
  
  Widget _buildOptionArea(double screenWidth, double optionAreaHeight) {
    // Calculate actual option area height with new constraints
    final actualOptionHeight = (0.25 * MediaQuery.of(context).size.height).clamp(446.0, double.infinity);
    
    return Container(
      width: screenWidth,
      height: actualOptionHeight,
      decoration: BoxDecoration(
        color: const Color(Consts.COLOR_MAIN), // Const.COLOR_MAIN background
        border: const Border(
          top: BorderSide(
            color: Color(0xFF06a9c6), // Top line color
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: OptionComponent(
          key: _optionKey, // Add key to access shake method
          letters: optionLetters,
          selectedStates: selectedOptions,
          onLetterSelected: _onLetterSelected,
        ),
      ),
    );
  }
  
  Widget _buildCoinBox(BuildContext context) {
    return Container(
      height: Consts.getDimension(context, 100.0),
      padding: EdgeInsets.symmetric(
        horizontal: Consts.getSpacing(context, 16.0),
        vertical: Consts.getSpacing(context, 8.0),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20), // Alpha 0.08
        borderRadius: BorderRadius.circular(Consts.getRadius(context, 24.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left icon - add_circle
          Icon(
            Icons.add_circle,
            size: Consts.getDimension(context, 60.0),
            color: const Color(Consts.COLOR_MAIN_TEXT),
          ),
          
          SizedBox(width: Consts.getSpacing(context, 12.0)),
          
          // Coin count text
          Text(
            DPlayer.coin.toString(),
            style: TextStyle(
              fontSize: Consts.getFontSize(context, 44.0),
              fontFamily: Consts.FONT_TITLE,
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(width: Consts.getSpacing(context, 12.0)),
          
          // Right icon - coin image
          Image.asset(
            'assets/images/ic_coin.png',
            width: Consts.getDimension(context, 100.0),
            height: Consts.getDimension(context, 100.0),
            errorBuilder: (context, error, stackTrace) {
              // Fallback to coin icon if image not found
              return Icon(
                Icons.monetization_on,
                size: Consts.getDimension(context, 100.0),
                color: Colors.orange,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int badgeCount,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            InnerShadowButton(
              width: Consts.getDimension(context, 132.0), // 132x132
              height: Consts.getDimension(context, 132.0),
              borderRadius: Consts.getRadius(context, 20.0),
              backgroundColor: const Color(Consts.COLOR_MAIN_TEXT),
              shadowColor: const Color(0xFF0088CC),
              onPressed: onPressed,
              child: Icon(
                icon,
                size: Consts.getDimension(context, 48.0),
                color: Colors.white,
              ),
            ),
            
            // Badge
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: EdgeInsets.all(Consts.getSpacing(context, 8.0)),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(Consts.getRadius(context, 20.0)),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Consts.getFontSize(context, 24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Consts.getSpacing(context, 8.0)),
        Text(
          label,
          style: TextStyle(
            color: Colors.black, // Black for white background
            fontSize: Consts.getFontSize(context, 32.0),
            fontFamily: Consts.FONT_MAIN,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSkipButton() {
    return Column(
      children: [
        InnerShadowButton(
          width: Consts.getDimension(context, 132.0), // 132x132
          height: Consts.getDimension(context, 132.0),
          borderRadius: Consts.getRadius(context, 20.0),
          backgroundColor: Colors.orange,
          shadowColor: Colors.orange.shade700,
          onPressed: _onSkipPressed,
          child: Icon(
            Icons.skip_next,
            size: Consts.getDimension(context, 48.0),
            color: Colors.white,
          ),
        ),
        SizedBox(height: Consts.getSpacing(context, 8.0)),
        Text(
          "Skip",
          style: TextStyle(
            color: Colors.black, // Black for white background
            fontSize: Consts.getFontSize(context, 32.0),
            fontFamily: Consts.FONT_MAIN,
          ),
        ),
      ],
    );
  }
  
  /// Format level title according to specification
  /// Example: episode "starter", level "starter2" => "STARTER 02"
  String _formatLevelTitle(String episodeName, String levelId) {
    // Extract episode name
    final episodeFormatted = episodeName.toUpperCase();
    
    // Extract number from level ID
    final numberMatch = RegExp(r'\d+').firstMatch(levelId);
    final levelNumber = numberMatch?.group(0) ?? "1";
    final levelInt = int.tryParse(levelNumber) ?? 1;
    
    // Format number with leading zero if < 10
    final levelFormatted = levelInt < 10 ? "0$levelInt" : levelInt.toString();
    
    return "$episodeFormatted $levelFormatted";
  }
}