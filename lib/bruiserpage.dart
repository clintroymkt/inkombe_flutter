import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class Bruiserpage extends StatefulWidget {
  final String docId;
  const Bruiserpage({
    super.key,
    required this.docId
  });

  @override
  State<Bruiserpage> createState() => _BruiserpageState();
}

class _BruiserpageState extends State<Bruiserpage> {
  Map<String, dynamic>? data;

  Future<Map<String, dynamic>> preloadData() async {
    return await DatabaseService().getSingleCow(widget.docId);
  }

  @override
  void initState() {
    // TODO: implement initState
    preloadData();
    super.initState();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    preloadData();
    data;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only( top: 277),
                child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(19),
                                            topRight: Radius.circular(19),
                                          ),
                                          color: Color(0xFFFFFFFF),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 49),
                                        width: double.infinity,
                                        child:  FutureBuilder<Map<String, dynamic>>(
                                              future: preloadData(),
                                              builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                              return Center(child: Text('Error: ${snapshot.error}'));
                                              } else if (snapshot.hasData) {
                                              Map<String, dynamic>? data = snapshot.data;
                                              return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children:   [
                                                Container(
                                                  margin: const EdgeInsets.only( bottom: 22, left: 18),
                                                  child: Text(
                                                    data!['name'].toString(),
                                                    style: const TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontSize: 24,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only( bottom: 12, left: 16),
                                                  child: const Text(
                                                    "Scientific name: Holstein-Fresian",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only( bottom: 12, left: 17),
                                                  child: const Text(
                                                    "Breed name: Fresian",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only( bottom: 12, left: 16),
                                                  child: const Text(
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
                                                    "Age:  2 Years",
                                                    style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only( bottom: 12, left: 17),
                                                  child: Text(
                                                    "Height(cm): 115",
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
                                                    "Notes: \n Weight updated to 150(KG) - 30/07/2024",
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
                                                        child: Image.network(
                                                          "https://i.imgur.com/1tMFzp8.png",
                                                          fit: BoxFit.fill,
                                                        )
                                                    )
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only( bottom: 19, left: 17),
                                                  child: const Text(
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
                                                            padding: const EdgeInsets.only( left: 29, right: 29),
                                                            margin: const EdgeInsets.only( right: 12),
                                                            width: 117,
                                                            height: 108,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(22),
                                                              image: const DecorationImage(
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
                                                          Container(
                                                            padding: const EdgeInsets.only( left: 29, right: 29),
                                                            width: 117,
                                                            height: 108,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(22),
                                                              image: const DecorationImage(
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
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                              ]
                                          );
                                              }
                                              else {
                                                return const Placeholder(); //return empty widget
                                              }
    }
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
                                      image: const DecorationImage(
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
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 289,
                        child: Container(
                          transform: Matrix4.translationValues(0, -277, 0),
                          height: 289,
                          width: double.infinity,
                          decoration: const BoxDecoration(
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
                                    margin: const EdgeInsets.only( top: 40, bottom: 121, left: 16, right: 16),
                                    width: double.infinity,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only( left: 8, right: 8),
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                  fit: BoxFit.cover
                                              ),
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin: const EdgeInsets.only( top: 8),
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
                                            padding: const EdgeInsets.only( left: 8, right: 8),
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage("https://i.imgur.com/1tMFzp8.png"),
                                                  fit: BoxFit.cover
                                              ),
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin: const EdgeInsets.only( top: 8),
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
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                    padding: const EdgeInsets.only( top: 5, bottom: 5, left: 40, right: 5),
                                    margin: const EdgeInsets.symmetric(horizontal: 72),
                                    width: double.infinity,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
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
                                                color: const Color(0xFFD98E47),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              width: 100,
                                              child: const Column(
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
        ),
      ),
    );
  }
}