import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Likes',
      style: optionStyle,
    ),
    Text(
      'Search',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
  ];

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
                padding: EdgeInsets.only( top: 41),
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Container(
                            margin: EdgeInsets.only( bottom: 61, left: 11, right: 11),
                            width: double.infinity,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Clint Mukarakate ',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 20,
                                    ),
                                  ),
                                  Container(
                                      width: 15,
                                      height: 19,
                                      child: Image.asset(
                                        'assets/icons/bell.svg',
                                        fit: BoxFit.fill,
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only( bottom: 28, left: 22),
                          child: Text(
                            'Home',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 28,
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color(0x33D98E47),
                            ),
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.only( bottom: 44, left: 19, right: 19),
                            width: double.infinity,
                            child: Row(
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        color: Color(0xFFD98E47),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      margin: EdgeInsets.only( right: 33),
                                      width: 100,
                                      child: Column(
                                          children: [
                                            Text(
                                              'Daily',
                                              style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Weekly',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: SizedBox(),
                                    ),
                                  ),
                                  Text(
                                    'Monthly',
                                    style: TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 14,
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only( bottom: 16, left: 20),
                          child: Text(
                            'Recent Updates ',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            color: Color(0x1C89D6AD),
                            padding: EdgeInsets.only( top: 20, bottom: 20, left: 16, right: 16),
                            margin: EdgeInsets.only( bottom: 31),
                            width: double.infinity,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFF59E0B),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only( bottom: 8),
                                      width: double.infinity,
                                      child: Row(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(2),
                                                    topRight: Radius.circular(4),
                                                    bottomRight: Radius.circular(4),
                                                    bottomLeft: Radius.circular(2),
                                                  ),
                                                ),
                                                margin: EdgeInsets.only( right: 14),
                                                width: 93,
                                                height: 98,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(2),
                                                      topRight: Radius.circular(4),
                                                      bottomRight: Radius.circular(4),
                                                      bottomLeft: Radius.circular(2),
                                                    ),
                                                    child: Image.network(
                                                      'assets/icons/Bruiser.svg',
                                                      fit: BoxFit.fill,
                                                    )
                                                )
                                            ),
                                            IntrinsicHeight(
                                              child: Container(
                                                margin: EdgeInsets.only( right: 39),
                                                width: 108,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only( bottom: 12, left: 2),
                                                        child: Text(
                                                          'Bruiser',
                                                          style: TextStyle(
                                                            color: Color(0xFF262626),
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: Container(
                                                          margin: EdgeInsets.only( bottom: 9),
                                                          width: double.infinity,
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                    width: 12,
                                                                    height: 12,
                                                                    child: Image.network(
                                                                      'assets/icons/calorange.svg',
                                                                      fit: BoxFit.fill,
                                                                    )
                                                                ),
                                                                Text(
                                                                  'Weight Update',
                                                                  style: TextStyle(
                                                                    color: Color(0xFF737373),
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: Container(
                                                          width: double.infinity,
                                                          child: Row(
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only( right: 4),
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: Image.network(
                                                                      'https://i.imgur.com/1tMFzp8.png',
                                                                      fit: BoxFit.fill,
                                                                    )
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    width: double.infinity,
                                                                    child: Text(
                                                                      'Today',
                                                                      style: TextStyle(
                                                                        color: Color(0xFFF59E0B),
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only( left: 18, right: 18),
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                    fit: BoxFit.cover
                                                ),
                                              ),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                          margin: EdgeInsets.only( top: 16),
                                                          height: 18,
                                                          width: double.infinity,
                                                          child: Image.network(
                                                            'https://i.imgur.com/1tMFzp8.png',
                                                            fit: BoxFit.fill,
                                                          )
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFD98E47),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      padding: EdgeInsets.all(2),
                                      width: double.infinity,
                                      child: Row(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(2),
                                                    topRight: Radius.circular(4),
                                                    bottomRight: Radius.circular(4),
                                                    bottomLeft: Radius.circular(2),
                                                  ),
                                                ),
                                                margin: EdgeInsets.only( right: 14),
                                                width: 93,
                                                height: 98,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(2),
                                                      topRight: Radius.circular(4),
                                                      bottomRight: Radius.circular(4),
                                                      bottomLeft: Radius.circular(2),
                                                    ),
                                                    child: Image.network(
                                                      'https://i.imgur.com/1tMFzp8.png',
                                                      fit: BoxFit.fill,
                                                    )
                                                )
                                            ),
                                            IntrinsicHeight(
                                              child: Container(
                                                margin: EdgeInsets.only( right: 45),
                                                width: 101,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only( bottom: 12, left: 2),
                                                        child: Text(
                                                          'King',
                                                          style: TextStyle(
                                                            color: Color(0xFF262626),
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: Container(
                                                          margin: EdgeInsets.only( bottom: 8),
                                                          width: double.infinity,
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                    width: 12,
                                                                    height: 12,
                                                                    child: Image.network(
                                                                      'https://i.imgur.com/1tMFzp8.png',
                                                                      fit: BoxFit.fill,
                                                                    )
                                                                ),
                                                                Text(
                                                                  'Health Check',
                                                                  style: TextStyle(
                                                                    color: Color(0xFF737373),
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: Container(
                                                          width: double.infinity,
                                                          child: Row(
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only( right: 4),
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: Image.network(
                                                                      'https://i.imgur.com/1tMFzp8.png',
                                                                      fit: BoxFit.fill,
                                                                    )
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    width: double.infinity,
                                                                    child: Text(
                                                                      'Today',
                                                                      style: TextStyle(
                                                                        color: Color(0xFFD98E47),
                                                                        fontSize: 12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]
                                                          ),
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only( left: 15, right: 15),
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                    fit: BoxFit.cover
                                                ),
                                              ),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                          margin: EdgeInsets.only( top: 17),
                                                          height: 21,
                                                          width: double.infinity,
                                                          child: Image.network(
                                                            'https://i.imgur.com/1tMFzp8.png',
                                                            fit: BoxFit.fill,
                                                          )
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only( bottom: 17, left: 18),
                          child: Text(
                            'To-Do List',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            color: Color(0x1C89D6AD),
                            padding: EdgeInsets.only( left: 16, right: 16),
                            margin: EdgeInsets.only( bottom: 44),
                            width: double.infinity,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xFFE5E5E5),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.only( top: 20),
                                      width: double.infinity,
                                      child: Row(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(2),
                                                    topRight: Radius.circular(4),
                                                    bottomRight: Radius.circular(4),
                                                    bottomLeft: Radius.circular(2),
                                                  ),
                                                ),
                                                margin: EdgeInsets.only( right: 14),
                                                width: 93,
                                                height: 98,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(2),
                                                      topRight: Radius.circular(4),
                                                      bottomRight: Radius.circular(4),
                                                      bottomLeft: Radius.circular(2),
                                                    ),
                                                    child: Image.network(
                                                      'https://i.imgur.com/1tMFzp8.png',
                                                      fit: BoxFit.fill,
                                                    )
                                                )
                                            ),
                                            Expanded(
                                              child: IntrinsicHeight(
                                                child: Container(
                                                  margin: EdgeInsets.only( right: 4),
                                                  width: double.infinity,
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only( bottom: 12, left: 2),
                                                          child: Text(
                                                            'Dipping',
                                                            style: TextStyle(
                                                              color: Color(0xFF262626),
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        IntrinsicHeight(
                                                          child: Container(
                                                            margin: EdgeInsets.only( bottom: 8, left: 6, right: 6),
                                                            width: double.infinity,
                                                            child: Row(
                                                                children: [
                                                                  Container(
                                                                      margin: EdgeInsets.only( right: 8),
                                                                      width: 12,
                                                                      height: 12,
                                                                      child: Image.network(
                                                                        'https://i.imgur.com/1tMFzp8.png',
                                                                        fit: BoxFit.fill,
                                                                      )
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                      width: double.infinity,
                                                                      child: Text(
                                                                        '8 cows',
                                                                        style: TextStyle(
                                                                          color: Color(0xFF737373),
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                        IntrinsicHeight(
                                                          child: Container(
                                                            width: double.infinity,
                                                            child: Row(
                                                                children: [
                                                                  Container(
                                                                      margin: EdgeInsets.only( right: 4),
                                                                      width: 24,
                                                                      height: 24,
                                                                      child: Image.network(
                                                                        'https://i.imgur.com/1tMFzp8.png',
                                                                        fit: BoxFit.fill,
                                                                      )
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                      width: double.infinity,
                                                                      child: Text(
                                                                        'In 6 days',
                                                                        style: TextStyle(
                                                                          color: Color(0xFFA3A3A3),
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only( left: 16, right: 16),
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                    fit: BoxFit.cover
                                                ),
                                              ),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                          margin: EdgeInsets.only( top: 16),
                                                          height: 20,
                                                          width: double.infinity,
                                                          child: Image.network(
                                                            'https://i.imgur.com/1tMFzp8.png',
                                                            fit: BoxFit.fill,
                                                          )
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      color: Color(0xFFFFFFFF),
                                      padding: EdgeInsets.only( top: 12, bottom: 12, left: 20, right: 20),
                                      width: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only( bottom: 4),
                                                  height: 19,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    'https://i.imgur.com/1tMFzp8.png',
                                                    fit: BoxFit.fill,
                                                  )
                                              ),
                                            ),
                                            Text(
                                              'Home',
                                              style: TextStyle(
                                                color: Color(0xFFD98E47),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      color: Color(0xFFFFFFFF),
                                      padding: EdgeInsets.symmetric(vertical: 11),
                                      width: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only( bottom: 7, left: 27, right: 27),
                                                  height: 17,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    'https://i.imgur.com/1tMFzp8.png',
                                                    fit: BoxFit.fill,
                                                  )
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only( left: 17),
                                              child: Text(
                                                'Search',
                                                style: TextStyle(
                                                  color: Color(0xFF525252),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      color: Color(0xFFFFFFFF),
                                      padding: EdgeInsets.only( left: 16, right: 16),
                                      width: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only( left: 11, right: 11),
                                              margin: EdgeInsets.only( top: 8),
                                              height: 40,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                    fit: BoxFit.cover
                                                ),
                                              ),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                          margin: EdgeInsets.only( top: 11),
                                                          height: 18,
                                                          width: double.infinity,
                                                          child: Image.network(
                                                            'https://i.imgur.com/1tMFzp8.png',
                                                            fit: BoxFit.fill,
                                                          )
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      color: Color(0xFFFFFFFF),
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      width: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only( bottom: 3, left: 24, right: 24),
                                                  height: 24,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    'https://i.imgur.com/1tMFzp8.png',
                                                    fit: BoxFit.fill,
                                                  )
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only( left: 10),
                                              child: Text(
                                                'Database',
                                                style: TextStyle(
                                                  color: Color(0xFF525252),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      color: Color(0xFFFFFFFF),
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      width: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only( bottom: 3, left: 24, right: 24),
                                                  height: 24,
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    'https://i.imgur.com/1tMFzp8.png',
                                                    fit: BoxFit.fill,
                                                  )
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only( left: 13),
                                              child: Text(
                                                'Settings',
                                                style: TextStyle(
                                                  color: Color(0xFF525252),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    ),
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
          gap: 8,
          activeColor: Colors.black,
          iconSize: 24,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[100]!,
          color: Colors.black,
          tabs: [
  GButton(
  icon: LineIcons.home,
  text: 'Home',
  ),
  GButton(
  icon: LineIcons.heart,
  text: 'Likes',
  ),
  GButton(
  icon: LineIcons.search,
  text: 'Search',
  ),
  GButton(
  icon: LineIcons.user,
  text: 'Profile',
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