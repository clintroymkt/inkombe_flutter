import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import '../services/cattle_record.dart';
import '../widgets/list_card.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  Future<List<CattleRecord>>? cattleFuture;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final CattleSyncService _cattleSync = CattleSyncService();

  void preloadUpdates() {
    cattleFuture = CattleSyncService.getAllCattle();
    print(currentUser?.uid);
  }

  void refreshData() {
    setState(() {
      cattleFuture = CattleSyncService.getAllCattle();
    });
  }

  @override
  void initState() {
    preloadUpdates();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper method to get the first available image
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.only(top: 41),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 17, left: 18),
                          child: Column(
                            children: [
                              const Text(
                                'Actions',
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) =>  const CreateCowPage()),
                                    // );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF064151),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Add Cow',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: GestureDetector(
                                  onTap: refreshData,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Refresh Data',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 16, left: 20),
                          child: const Text(
                            'Cattle',
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

                                  if (docs.isEmpty) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.pets, size: 64, color: Colors.grey),
                                          SizedBox(height: 16),
                                          Text(
                                            'No cattle records found',
                                            style: TextStyle(color: Colors.grey, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  for (final doc in docs){
                                   print(doc.imageUrls);
                                   print(doc.localImagePaths);
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (final doc in docs)
                                        ListCard(
                                          title: doc.name,
                                          date: doc.date,
                                          imagePath: _getFirstImagePath(doc),
                                          imageUri: doc.imageUrls?.isNotEmpty == true
                                              ? doc.imageUrls![0]
                                              : null,
                                          docId: doc.id,
                                        ),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: Text('No data available'),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
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
}