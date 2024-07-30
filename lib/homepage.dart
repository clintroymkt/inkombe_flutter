import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inkombe_flutter/bruiserpage.dart';
import 'package:inkombe_flutter/kingpage.dart';

class Homepage extends StatelessWidget {
const Homepage({super.key});

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
                                        'assets/icons/bell.png',
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
                              color: Color(0xFFFFFFFF),
                              padding: EdgeInsets.only( top: 20, bottom: 20, left: 16, right: 16),
                              margin: EdgeInsets.only( bottom: 31),
                              width: double.infinity,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    GestureDetector(
                                      child: IntrinsicHeight(
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
                                                        child: Image.asset(
                                                          'assets/icons/bruiser.png',
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
                                                                        child: Image.asset(
                                                                          'assets/icons/weightorange.png',
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
                                                                        child: Image.asset(
                                                                          'assets/icons/calorange.png',
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
                                                        image: AssetImage('assets/icons/weightorange.png'),
                                                        fit: BoxFit.cover
                                                    ),
                                                  ),

                                                ),
                                              ]
                                          ),
                                        ),
                                      ),

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bruiserpage()),
    );
  },
                                    ),

                                    GestureDetector(
                                      child: IntrinsicHeight(
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
                                                        child: Image.asset(
                                                          'assets/icons/king.png',
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
                                                                        child: Image.asset(
                                                                          'assets/icons/dropframe.png',
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
                                                                        child: Image.asset(
                                                                          'assets/icons/calorange.png',
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
                                                        image: AssetImage("assets/icons/healthorange.png"),
                                                        fit: BoxFit.cover
                                                    ),
                                                  ),

                                                ),
                                              ]
                                          ),
                                        ),
                                      ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Kingpage()),
    );
  },
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
                            color: Color(0xFFFFFFFF),
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
                                                    child: Image.asset(
                                                      'assets/icons/dippic.png',
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
                                                                      child: Image.asset(
                                                                        'assets/icons/dropframe.png',
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
                                                                      child: Image.asset(
                                                                        'assets/icons/calorange.png',
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
                                                    image: AssetImage("assets/icons/dropgrey.png"),
                                                    fit: BoxFit.cover
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
  );
}
}