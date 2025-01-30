import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inkombe_flutter/kingpage.dart';
import 'package:inkombe_flutter/pages/home_screen/tabs/daily.dart';
import 'package:inkombe_flutter/pages/home_screen/tabs/placeholder.dart';

import '../../services/database_service.dart';
import '../../widgets/list_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0; // Track the selected tab index




  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You can use the index to switch displays or perform other actions
    print('Selected Index: $index');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFFFFFFFF),
                  padding: EdgeInsets.only(top: 41),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 61, left: 11, right: 11),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Welcome User',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 20,
                                  ),
                                ),
                                Container(
                                  width: 15,
                                  height: 19,
                                  child: Image.asset(
                                    'assets/icons/bell.png',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 28, left: 22),
                          child: const Text(
                            'Home',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 28,
                            ),
                          ),
                        ),
                        // Tab Navigation
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color(0x33D98E47),
                            ),
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only(bottom: 44, left: 19, right: 19),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildTab(0, 'Daily'),
                                _buildTab(1, 'Weekly'),
                                _buildTab(2, 'Monthly'),
                              ],
                            ),
                          ),
                        ),
                        // Content based on selected tab
                        _buildContent(),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual tab
  Widget _buildTab(int index, String title) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: _selectedIndex == index ? const Color(0xFFD98E47) : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          width: 100,
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _selectedIndex == index ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build content based on selected tab
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DailyTab();
      case 1:
        return const PlaceholderWidget(icon: Icons.construction, text: 'We are working on it',);
      case 2:
        return const PlaceholderWidget(icon: Icons.construction, text: 'We are working on it',);
      default:
        return Center(child: Text('Select a tab'));
    }
  }
}