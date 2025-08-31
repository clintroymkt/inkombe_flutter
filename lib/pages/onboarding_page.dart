import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/pages/main_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding pages
  final List<Widget> _pages = [
    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title:'',
      description:'',

    ),

    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title:'',
      description:'',

    ),

    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title:'',
      description:'',

    ),

  ];

  void _markOnboardingComplete() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPageRouter())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return _pages[index];
                },
              ),
            ),

            Row(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List<Widget>.generate(
                    _pages.length,
                        (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: _currentPage == _pages.length - 1
                        ? _markOnboardingComplete // On last page, complete onboarding
                        : () => _pageController.nextPage( // Go to next page
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                    child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),
            // Next/Get Started Button

          ],
        ),
      ),
    );
  }
}

// Widget for a single onboarding slide

class OnBoardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnBoardingSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [

          // Image
          Center(
            child: Image.asset(
              image,
              height: 300,
              width: 300,
            ),
          ),

          // Title
          Text(title, style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),),

          // Description
          Text(description, style: const TextStyle(
              fontSize: 16,
          ),)
        ]

      ),
    );

  }
}