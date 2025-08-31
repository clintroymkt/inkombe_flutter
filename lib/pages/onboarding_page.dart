import 'dart:async';

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

  Timer? _timer;
  // Onboarding pages
  final List<Widget> _pages = [
    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title: 'Keep Track of Your Cattle!',
      description: 'Add your Cattle’s names, vitals, health records and more.',
    ),
    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title: 'Scan to ID your Cows',
      description:
          'Take a picture and add the cow int your own personal database.',
    ),
    const OnBoardingSlide(
      image: 'assets/IDmyCow.png',
      title: 'Learn more about Cattle',
      description: 'Learn more about cattle health and care guide.',
    ),
  ];

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {}
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    _pageController.dispose();
    super.dispose();
  }

  void _markOnboardingComplete() async {
    _cancelTimer();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPageRouter()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
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
                    _cancelTimer();
                    _startTimer();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return _pages[index];
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                          onTap: () {
                            _currentPage == _pages.length - 1
                                ? _markOnboardingComplete() // On last page, complete onboarding
                                : () {
                                    _cancelTimer();
                                    _pageController.nextPage(
                                      // Go to next page
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                    _startTimer();
                                  };
                          },
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                                color: const Color(0xFF064151),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text(
                                _currentPage == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ))),
                ],
              ),
              const SizedBox(height: 20),
              // Next/Get Started Button
            ],
          ),
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Center(
            child: Image.asset(
              image,
              height: 300,
              width: 300,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        ]);
  }
}
