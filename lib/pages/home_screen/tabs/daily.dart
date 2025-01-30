import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/database_service.dart';
import '../../../widgets/list_card.dart';


class DailyTab extends StatefulWidget {
  const DailyTab({super.key});

  @override
  State<DailyTab> createState() => _DailyTabState();

}

class _DailyTabState extends State<DailyTab> {

  Stream<QuerySnapshot>? updates;

  void preloadUpdates() {
    updates = DatabaseService().getCattleUpdates();
  }

  @override
  void initState() {
    preloadUpdates();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    preloadUpdates();
    updates;
  }

  var doc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16, left: 20),
          child: const Text(
            'Recent Updates ',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 24,
            ),
          ),
        ),
        IntrinsicHeight(
          child: Container(
            color: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            margin: const EdgeInsets.only(bottom: 31),
            width: double.infinity,
            child: StreamBuilder(
              stream: updates,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var docs = snapshot.data.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (doc in docs)
                        ListCard(
                          title: doc.data()['name'].toString(),
                          date: doc.data()['date'].toString(),
                          imageUri: doc.data()['image'].toString(),
                          docId: doc.id,
                        ),
                    ],
                  );
                }
                return const SizedBox(); // Return empty widget here
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 17, left: 18),
          child: const Text(
            'To-Do List',
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 24,
            ),
          ),
        ),
        IntrinsicHeight(
          child: Container(
            color: const Color(0xFFFFFFFF),
            padding: const EdgeInsets.only(left: 16, right: 16),
            margin: const EdgeInsets.only(bottom: 44),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFFFFFFFF),
                    ),
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.only(top: 20),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                              bottomLeft: Radius.circular(2),
                            ),
                          ),
                          margin: const EdgeInsets.only(right: 14),
                          width: 93,
                          height: 98,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                              bottomLeft: Radius.circular(2),
                            ),
                            child: Image.asset(
                              'assets/icons/dippic.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Expanded(
                          child: IntrinsicHeight(
                            child: Container(
                              margin: EdgeInsets.only(right: 4),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 12, left: 2),
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
                                      margin: EdgeInsets.only(bottom: 8, left: 6, right: 6),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 8),
                                            width: 12,
                                            height: 12,
                                            child: Image.asset(
                                              'assets/icons/dropframe.png',
                                              fit: BoxFit.fill,
                                            ),
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 4),
                                            width: 24,
                                            height: 24,
                                            child: Image.asset(
                                              'assets/icons/calorange.png',
                                              fit: BoxFit.fill,
                                            ),
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/icons/dropgrey.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
