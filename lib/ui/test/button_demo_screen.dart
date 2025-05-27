import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:claude_cuc/config/const.dart';
import 'package:claude_cuc/ui/widgets/inner_shadow_button.dart';

class ButtonDemoScreen extends StatefulWidget {
  const ButtonDemoScreen({Key? key}) : super(key: key);

  @override
  State<ButtonDemoScreen> createState() => _ButtonDemoScreenState();
}

class _ButtonDemoScreenState extends State<ButtonDemoScreen> {
  // Controller for color customization
  Color buttonColor = const Color(0xFFd0f7fe);
  Color shadowColor = Colors.cyan;
  double shadowSize = 5.0;
  double dropShadowSize = 10.0;
  
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe5f9fc),
      appBar: AppBar(
        title: const Text('Inner Shadow Buttons'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Inner Shadow Text Button',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Example of letter button like in your image
                Center(
                  child: InnerShadowTextButton(
                    text: 'U',
                    width: Consts.getDimension(context, 120),
                    height: Consts.getDimension(context, 120),
                    backgroundColor: buttonColor,
                    shadowColor: shadowColor,
                    shadowSize: shadowSize,
                    dropShadowSize: dropShadowSize,
                    borderRadius: 16,
                    fontSize: 60,
                    onPressed: () => _showToast('Letter button pressed'),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Inner Shadow Icon Button',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Row of icon buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InnerShadowIconButton(
                      icon: Icons.home,
                      backgroundColor: buttonColor,
                      shadowColor: shadowColor,
                      shadowSize: shadowSize,
                      dropShadowSize: dropShadowSize,
                      onPressed: () => _showToast('Home button pressed'),
                    ),
                    InnerShadowIconButton(
                      icon: Icons.favorite,
                      backgroundColor: buttonColor,
                      shadowColor: shadowColor,
                      shadowSize: shadowSize,
                      dropShadowSize: dropShadowSize,
                      onPressed: () => _showToast('Favorite button pressed'),
                    ),
                    InnerShadowIconButton(
                      icon: Icons.settings,
                      backgroundColor: buttonColor,
                      shadowColor: shadowColor,
                      shadowSize: shadowSize,
                      dropShadowSize: dropShadowSize,
                      onPressed: () => _showToast('Settings button pressed'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Regular Inner Shadow Button',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Standard button with text
                InnerShadowButton(
                  backgroundColor: buttonColor,
                  shadowColor: shadowColor,
                  shadowSize: shadowSize,
                  dropShadowSize: dropShadowSize,
                  onPressed: () => _showToast('Button pressed'),
                  child: const Text(
                    'Press Me',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF345560),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Customize Button Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Controls to customize button appearance
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inner Shadow Size'),
                        Slider(
                          value: shadowSize,
                          min: 1.0,
                          max: 15.0,
                          divisions: 14,
                          label: shadowSize.toString(),
                          onChanged: (value) {
                            setState(() {
                              shadowSize = value;
                            });
                          },
                        ),
                        
                        const Text('Drop Shadow Size'),
                        Slider(
                          value: dropShadowSize,
                          min: 1.0,
                          max: 20.0,
                          divisions: 19,
                          label: dropShadowSize.toString(),
                          onChanged: (value) {
                            setState(() {
                              dropShadowSize = value;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    buttonColor = const Color(0xFFd0f7fe);
                                    shadowColor = Colors.cyan;
                                  });
                                },
                                child: const Text('Default Colors'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    buttonColor = const Color(0xFFffd0d0);
                                    shadowColor = Colors.redAccent;
                                  });
                                },
                                child: const Text('Red Theme'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  setState(() {
                                    buttonColor = const Color(0xFFd0ffd0);
                                    shadowColor = Colors.green;
                                  });
                                },
                                child: const Text('Green Theme'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                ),
                                onPressed: () {
                                  setState(() {
                                    buttonColor = const Color(0xFFf0d0ff);
                                    shadowColor = Colors.purple;
                                  });
                                },
                                child: const Text('Purple Theme'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Example of Shadow Letter Button Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Row of letter buttons to demonstrate use case
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (var letter in ['F', 'L', 'U', 'T', 'T', 'E', 'R'])
                      InnerShadowTextButton(
                        text: letter,
                        width: Consts.getDimension(context, 60),
                        height: Consts.getDimension(context, 60),
                        backgroundColor: buttonColor,
                        shadowColor: shadowColor,
                        shadowSize: shadowSize,
                        dropShadowSize: dropShadowSize,
                        borderRadius: 12,
                        onPressed: () => _showToast('Letter $letter pressed'),
                      ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}