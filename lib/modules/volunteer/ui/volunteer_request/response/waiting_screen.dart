import 'package:flutter/material.dart';

import '../../../../../shared/styles/colors.dart';

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Waiting a volunteer!",
                style: TextStyle(color: GREY_COLOR, fontSize: 16),
              ),
              SizedBox(
                height: 50,
              ),
              LinearProgressIndicator(
                color: MAIN_COLOR,
                backgroundColor: GREY_COLOR,
                minHeight: 3,
              )
            ],
          ),
        ),
      ),
    );
  }
}
