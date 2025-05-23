import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:inkombe_flutter/pages/database_page.dart';
import 'package:inkombe_flutter/pages/home_screen/home_page.dart';
import 'package:inkombe_flutter/pages/scan_page.dart';
import 'package:line_icons/line_icons.dart';

class Homepage extends StatefulWidget {
const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Text (
      'Search',
      style: optionStyle,
    ),
    ScanPage(),
    DatabasePage(),
    Text(
      'Settings',
      style: optionStyle,
    ),
  ];

  @override
Widget build(BuildContext context) {

  return Scaffold(
    body:_widgetOptions[_selectedIndex],
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child:Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 0,
          activeColor: Color(0xFFD98F48),
          iconSize: 30,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[100]!,

          color: Colors.black,
          tabs: const [
          GButton(
            icon: LineIcons.home,
            text: 'Home',

          ),
          GButton(
            icon: LineIcons.search,
            text: 'Search',
          ),
            GButton(
              icon: LineIcons.qrcode,
              text: 'Scan',
            ),
          GButton(
            icon: LineIcons.list,
            text: 'Database',
          ),
          GButton(
            icon: LineIcons.edit,
            text: 'Settings',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
          setState(() {
          _selectedIndex = index;
          });
          },
              ),
            ),
          ),
            ),);
}
}