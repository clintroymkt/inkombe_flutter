import 'package:flutter/material.dart';
class Kingpage extends StatelessWidget {

  const Kingpage({super.key});
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
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: Container(
                            margin: EdgeInsets.only( top: 277),
                            width: 465,
                            child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IntrinsicHeight(
                                          child: Container(
                                            width: double.infinity,
                                            child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        IntrinsicHeight(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(19),
                                                                topRight: Radius.circular(19),
                                                              ),
                                                              color: Color(0xFFFFFFFF),
                                                            ),
                                                            padding: EdgeInsets.symmetric(vertical: 49),
                                                            width: double.infinity,
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 22, left: 17),
                                                                    child: Text(
                                                                      "King",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 24,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 16),
                                                                    child: Text(
                                                                      "Scientific name: Bos taurus taurus",
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 17),
                                                                    child: Text(
                                                                      "Breed name: Jersey",
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 16),
                                                                    child: Text(
                                                                      "Owner: Clint Mukarakate",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 16),
                                                                    child: Text(
                                                                      "Age:  3 Years",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 17),
                                                                    child: Text(
                                                                      "Height(cm): 117",
                                                                      style: TextStyle(
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 16),
                                                                    child: Text(
                                                                      "Weight(kg): 150",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 12, left: 17),
                                                                    child: Text(
                                                                      "Diet: ",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 22, left: 17),
                                                                    child: Text(
                                                                      "Known Diseases: ",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 79, left: 17, right: 17),
                                                                    width: double.infinity,
                                                                    child: Text(
                                                                      "Notes: \n Health check at vet - 30/07/2024",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(13),
                                                                      ),
                                                                      margin: EdgeInsets.only( bottom: 41, left: 15, right: 15),
                                                                      width: 172,
                                                                      height: 127,
                                                                      child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(13),
                                                                          child: Image.asset(
                                                                            "assets/icons/king.png",
                                                                            fit: BoxFit.fill,
                                                                          )
                                                                      )
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only( bottom: 19, left: 17),
                                                                    child: Text(
                                                                      "Location History",
                                                                      style: TextStyle(
                                                                        color: Color(0xFF000000),
                                                                        fontSize: 20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  IntrinsicHeight(
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(22),
                                                                        color: Color(0x4DD98F48),
                                                                      ),
                                                                      padding: EdgeInsets.only( top: 27, bottom: 27, left: 16, right: 16),
                                                                      width: double.infinity,
                                                                      child: Row(
                                                                          children: [
                                                                            Container(
                                                                              padding: EdgeInsets.only( left: 29, right: 29),
                                                                              margin: EdgeInsets.only( right: 12),
                                                                              width: 117,
                                                                              height: 108,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(22),
                                                                                image: DecorationImage(
                                                                                    image: AssetImage("assets/icons/king.png"),
                                                                                    fit: BoxFit.cover
                                                                                ),
                                                                              ),
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                        margin: EdgeInsets.only( top: 61),
                                                                                        width: 5,
                                                                                        height: 2,
                                                                                        child: Image.asset(
                                                                                          "assets/icons/king.png",
                                                                                          fit: BoxFit.fill,
                                                                                        )
                                                                                    ),
                                                                                  ]
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              padding: EdgeInsets.only( left: 29, right: 29),
                                                                              width: 117,
                                                                              height: 108,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(22),
                                                                                image: DecorationImage(
                                                                                    image: AssetImage("assets/icons/king.pngassets/icons/king.png"),
                                                                                    fit: BoxFit.cover
                                                                                ),
                                                                              ),
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                        margin: EdgeInsets.only( top: 61),
                                                                                        width: 5,
                                                                                        height: 2,
                                                                                        child: Image.network(
                                                                                          "https://i.imgur.com/1tMFzp8.png",
                                                                                          fit: BoxFit.fill,
                                                                                        )
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
                                                      ]
                                                  ),
                                                  Positioned(
                                                    bottom: 296,
                                                    right: 0,
                                                    width: 172,
                                                    height: 127,
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(13),
                                                        ),
                                                        transform: Matrix4.translationValues(7, 0, 0),
                                                        width: 172,
                                                        height: 127,
                                                        child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(13),
                                                            child: Image.network(
                                                              "https://i.imgur.com/1tMFzp8.png",
                                                              fit: BoxFit.fill,
                                                            )
                                                        )
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 81,
                                                    right: 0,
                                                    width: 117,
                                                    height: 108,
                                                    child: Container(
                                                      padding: EdgeInsets.only( left: 29, right: 29),
                                                      transform: Matrix4.translationValues(31, 0, 0),
                                                      width: 117,
                                                      height: 108,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(22),
                                                        image: DecorationImage(
                                                            image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                            fit: BoxFit.cover
                                                        ),
                                                      ),
                                                      child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                                margin: EdgeInsets.only( top: 61),
                                                                width: 5,
                                                                height: 2,
                                                                child: Image.network(
                                                                  "https://i.imgur.com/1tMFzp8.png",
                                                                  fit: BoxFit.fill,
                                                                )
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 289,
                                    child: Container(
                                      transform: Matrix4.translationValues(0, -277, 0),
                                      height: 289,
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
                                            IntrinsicHeight(
                                              child: Container(
                                                margin: EdgeInsets.only( top: 40, bottom: 121, left: 16, right: 16),
                                                width: double.infinity,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.only( left: 8, right: 8),
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                              fit: BoxFit.cover
                                                          ),
                                                        ),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                  margin: EdgeInsets.only( top: 8),
                                                                  height: 24,
                                                                  width: double.infinity,
                                                                  child: Image.network(
                                                                    "https://i.imgur.com/1tMFzp8.png",
                                                                    fit: BoxFit.fill,
                                                                  )
                                                              ),
                                                            ]
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.only( left: 8, right: 8),
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                              fit: BoxFit.cover
                                                          ),
                                                        ),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                  margin: EdgeInsets.only( top: 8),
                                                                  height: 24,
                                                                  width: double.infinity,
                                                                  child: Image.network(
                                                                    "https://i.imgur.com/1tMFzp8.png",
                                                                    fit: BoxFit.fill,
                                                                  )
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
                                                  borderRadius: BorderRadius.circular(100),
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                                padding: EdgeInsets.only( top: 5, bottom: 5, left: 40, right: 5),
                                                margin: EdgeInsets.symmetric(horizontal: 72),
                                                width: double.infinity,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Care",
                                                        style: TextStyle(
                                                          color: Color(0xFF000000),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      IntrinsicHeight(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(100),
                                                            color: Color(0xFFD98E47),
                                                          ),
                                                          padding: EdgeInsets.symmetric(vertical: 14),
                                                          width: 100,
                                                          child: Column(
                                                              children: [
                                                                Text(
                                                                  "Info",
                                                                  style: TextStyle(
                                                                    color: Color(0xFFFFFFFF),
                                                                    fontSize: 14,
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