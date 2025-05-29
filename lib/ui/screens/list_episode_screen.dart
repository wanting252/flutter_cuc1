import 'package:flutter/material.dart';
import 'package:claude_cuc/config/const.dart';

class ListEpisodeScreen extends StatelessWidget {
  const ListEpisodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Consts.getDimension(context, 20)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: Consts.getDimension(context, 80),
              color: AppColors.buttonBlue,
            ),
            SizedBox(height: Consts.getSpacing(context, 20)),
            Text(
              'Daily Challenge',
              style: TextStyle(
                fontFamily: Consts.FONT_TITLE,
                fontSize: Consts.getFontSize(context, 48),
                fontWeight: FontWeight.bold,
                color: const Color(Consts.COLOR_MAIN),
              ),
            ),
            SizedBox(height: Consts.getSpacing(context, 10)),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontFamily: Consts.FONT_MAIN,
                fontSize: Consts.getFontSize(context, 36),
                color: const Color(Consts.COLOR_DESCRIPTION),
              ),
            ),
          ],
        ),
      ),
    );
  }
}