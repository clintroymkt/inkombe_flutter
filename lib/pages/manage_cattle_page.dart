import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import 'package:inkombe_flutter/widgets/CustomButton.dart';
import 'package:inkombe_flutter/widgets/color_theme.dart';
import '../services/cattle_record.dart';
import '../widgets/list_card.dart';
import '../widgets/sync_progress_dialog.dart';

class ManageCattlePage extends StatefulWidget {
  const ManageCattlePage({super.key});

  @override
  State<ManageCattlePage> createState() => _ManageCattlePageState();
}
//.
class _ManageCattlePageState extends State<ManageCattlePage> {
  Future<List<CattleRecord>>? cattleFuture;
  List<CattleRecord>? cattleRecords;
  User? currentUser = FirebaseAuth.instance.currentUser;

  void preloadUpdates() {
    cattleFuture = CattleSyncService.getAllCattle();
  }

  // Sync function
  /// @callback onProgress is for tracking records handled
  /// @callback synced is for counting actual synced records
  /// @callback failed is for tracking failed records
  /// @callback skipped is for tracking skipped records, these records would already be synchronized
  ///
  Future<void> syncCattleData(
      void Function(int) onProgress,
      void Function(int) synced,
      void Function(int) failed,
      void Function(int) skipped)
  async {
    final cattleList = CattleRepository().getAllCattle();


    // Sync each cattle with progress updates
    for (int i = 0; i < cattleList.length; i++) {
      final cattle = cattleList[i];
      // debugPrint('Syncing: ${cattle.id}');

      // Your sync logic
      final state = await CattleSyncService.forceSyncToCloud(cattle.id);

      if (state == 'no cattle')
      {
        failed(i + 1);
      } else if (state == 'failed') {
        failed(i + 1);

      }
      else if (state == 'skip'){
        skipped(i + 1);
      } else if (state == 'synced'){
        synced(i + 1);
      }
      debugPrint('Sync result: $state');



      // Update progress (i+1 because we want 1-based counting)
      onProgress(i + 1);

      // Optional delay to prevent overwhelming server
      await Future.delayed(const Duration(milliseconds: 100));
    }
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
      // print( doc.localImagePaths![0]);
      // return doc.localImagePaths![0];
    }
    // Then try image URLs
    if (doc.imageUrls != null && doc.imageUrls!.isNotEmpty) {
      // print(doc.imageUrls![0]);
      // return doc.imageUrls![0];
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomButton(icon: Icons.refresh, text: 'Refresh', onPressed: refreshData, backgroundColor: ThemeColors.secondary()),
                            CustomButton(
                              icon: Icons.cloud_upload,
                              text: 'Sync Data',
                              backgroundColor: ThemeColors.secondary(),
                              onPressed: () {
                                // Show the progress dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // Prevent closing by tapping outside
                                  builder: (context) => SyncProgressDialog(
                                    totalRecords: CattleRepository.getCattleBox()?.keys.length ?? 0,
                                    syncFunction: (onProgress, synched, failed, skipped) => syncCattleData(onProgress, synched, failed, skipped),
                                  ),
                                );
                              },
                            ),
                                ]
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

                                  // for (final doc in docs){
                                  //  print(doc.imageUrls);
                                  //  print(doc.localImagePaths);
                                  // }

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