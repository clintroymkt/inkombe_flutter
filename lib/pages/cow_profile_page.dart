import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class Bruiserpage extends StatefulWidget {
  final String docId;
  const Bruiserpage({super.key, required this.docId});

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
  late String cowImage = "null";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                child: Stack(clipBehavior: Clip.none, children: [
                  SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(clipBehavior: Clip.none, children: [
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
                                padding: const EdgeInsets.fromLTRB(0, 289, 0, 0),
                                width: double.infinity,
                                child: FutureBuilder<Map<String, dynamic>>(
                                    future: preloadData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        Map<String, dynamic>? data =
                                            snapshot.data;
                                        cowImage = data!['image'];
                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //banner image ####################################################
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  transform: Matrix4.translationValues(0, -289, 0),
                                                  height: 289,
                                                  width: double.infinity,
                                                  decoration:  BoxDecoration(
                                                    image: DecorationImage(
                                                        image:
                                                        NetworkImage(cowImage),
                                                        fit: BoxFit.cover),
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        IntrinsicHeight(
                                                          child: Container(
                                                            margin: const EdgeInsets.only(
                                                                top: 40, bottom: 121, left: 16, right: 16),
                                                            width: double.infinity,
                                                            child: const Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                                children: [


                                                                ]),
                                                          ),
                                                        ),
                                                        IntrinsicHeight(
                                                          child: Center(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(100),
                                                                color: const Color(0xFFFFFFFF),
                                                              ),
                                                              padding: const EdgeInsets.only(
                                                                  top: 5, bottom: 5, left: 5, right: 5),
                                                              margin: const EdgeInsets.symmetric(
                                                                  horizontal: 10),
                                                              width: 220,
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment.center,
                                                                  children: [
                                                                    IntrinsicHeight(
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(100),
                                                                          color: const Color(0xFFD98E47),
                                                                        ),
                                                                        padding: const EdgeInsets.symmetric(
                                                                            vertical: 14),
                                                                        width: 100,
                                                                        child: const Column(children: [
                                                                          Text(
                                                                            "Info",
                                                                            style: TextStyle(
                                                                              color: Color(0xFFFFFFFF),
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                      ),
                                                                    ),
                                                                    IntrinsicHeight(
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                          BorderRadius.circular(100),
                                                                          color: const Color(0xFFFFFFFF),
                                                                        ),
                                                                        padding: const EdgeInsets.symmetric(
                                                                            vertical: 14),
                                                                        width: 100,
                                                                        child: const Column(children: [
                                                                          Text(
                                                                            "Edit",
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ) ,



                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 22, left: 18),
                                                child: Text(
                                                  data['name'].toString(),
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12, left: 17),
                                                child: Text(
                                                  "Breed name: ${data['breed'].toString()}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12, left: 16),
                                                child: Text(
                                                  "Age:  ${data['age(years)'].toString()}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12, left: 16),
                                                child: Text(
                                                  "Sex:  ${data['sex'].toString()}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 12, left: 17),
                                                child: Text(
                                                  "Height(m): ${data['height(m)'].toString()}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 12, left: 16),
                                                child: Text(
                                                  "Weight(kg): ${data['weight(kg)'].toString()}",
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 12, left: 17),
                                                child: Text(
                                                  "Diet: ${data['diet'].toString().isEmpty ? "No data" : data['diet'].toString()}",
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 22, left: 17),
                                                child: Text(
                                                  "Known Diseases: ${data['diet'].toString().isEmpty ? "No Data" : data['diet'].toString()} ",
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 79,
                                                    left: 17,
                                                    right: 17),
                                                width: double.infinity,
                                                child: Text(
                                                  "Notes: \n ${data['notes'].toString().isEmpty ? "No data" : data['diet'].toString()}",
                                                  style: const TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 19, left: 17),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                    color: Color(0x4DD98F48),
                                                  ),
                                                  padding: const EdgeInsets.only(
                                                      top: 27,
                                                      bottom: 27,
                                                      left: 16,
                                                      right: 16),
                                                  width: double.infinity,
                                                  child: Row(children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 29,
                                                              right: 29),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 12),
                                                      width: 117,
                                                      height: 108,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(22),
                                                        image: const DecorationImage(
                                                            image: NetworkImage(
                                                                "https://i.imgur.com/1tMFzp8.png"),
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),


                                                  ]),
                                                ),
                                              ),
                                            ]);
                                      } else {
                                        return const Placeholder(); //return empty widget
                                      }
                                    }),
                              ),
                            ]),


                      ]),
                    ),
                  ),


                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
