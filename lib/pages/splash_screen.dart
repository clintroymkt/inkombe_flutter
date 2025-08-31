import 'package:flutter/material.dart';
import 'package:inkombe_flutter/Authentication/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();

  }

  _navigateToNextScreen() async{
    await Future.delayed(const Duration(seconds: 3));

  //   Get SharedPreference instance
    final prefs = await SharedPreferences.getInstance();

  //   Check the onboarding instances
    final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (isOnboardingComplete) {
      if (mounted){
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPageRouter())
        );
      }
    } else{
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage())
      );
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/IDmyCow.png',
                height: 300,
                width: 300,

              ),
            ),
          ]
        ),
      ),
    );
  }
}
