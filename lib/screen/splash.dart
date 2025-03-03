import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:gobuddy/const.dart';
import 'package:gobuddy/pages/onboard_travel.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: Lottie.asset("assets/animation/splash.json"),
          )
        ],
      ),
      nextScreen: TravelOnBoardingScreen(),
      duration: 3000,
      backgroundColor: kBackgroundColor,
      splashIconSize: 500,
    );
  }
}