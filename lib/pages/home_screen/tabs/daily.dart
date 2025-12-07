import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';

import '../../../services/cattle_record.dart';
import '../../../widgets/list_card.dart';

class DailyTab extends StatefulWidget {
  const DailyTab({super.key});

  @override
  State<DailyTab> createState() => _DailyTabState();
}

class _DailyTabState extends State<DailyTab> {
  Stream<QuerySnapshot>? updates;
  Future<List<CattleRecord>>? cattleFuture;

  void preloadUpdates() {
    cattleFuture = CattleSyncService.getAllCattle();
  }

  void refreshData() {
    setState(() {
      cattleFuture = CattleSyncService.getAllCattle();
    });
  }

  String? _getFirstImagePath(CattleRecord doc) {
    // First try local image paths
    if (doc.localImagePaths != null && doc.localImagePaths!.isNotEmpty) {
      return doc.localImagePaths![0];
    }
    // Then try image URLs
    if (doc.imageUrls != null && doc.imageUrls!.isNotEmpty) {
      return doc.imageUrls![0];
    }
    // Return null if no images available
    return null;
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
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 16, right: 16),
            margin: const EdgeInsets.only(bottom: 31),
            width: double.infinity,
            child: FutureBuilder<List<CattleRecord>>(
              future: cattleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading cattle: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: refreshData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final docs = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final doc in docs)

                        ListCard(
                          title: doc.name,
                          date: doc.date,
                          imageUri: doc.imageUrls != null && doc.imageUrls!.isNotEmpty
                              ? doc.imageUrls![0]
                              : null,
                          imagePath: doc.localImagePaths != null && doc.localImagePaths!.isNotEmpty
                              ? doc.localImagePaths![0]
                              : null,
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
                                    margin:
                                        EdgeInsets.only(bottom: 12, left: 2),
                                    child: const Text(
                                      'Dipping',
                                      style: TextStyle(
                                        color: Color(0xFF262626),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IntrinsicHeight(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 8, left: 6, right: 6),
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
