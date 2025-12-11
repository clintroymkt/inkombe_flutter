import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:inkombe_flutter/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'cattle_record.dart';
import 'network_service.dart';
import 'package:uuid/uuid.dart';

class CattleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference cattleCollection =
      DatabaseService().cattleCollection;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  CollectionReference get cattleCollectionRef => cattleCollection;
  static const String _cattleBoxName = 'cattle_records';
  static const String _syncQueueBoxName = 'cattle_sync_queue';
  static Box? _cattleBox;
  static Box? _syncQueueBox;
  final uuid = Uuid();

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _cattleBox = await Hive.openBox(_cattleBoxName);
    _syncQueueBox = await Hive.openBox(_syncQueueBoxName);
  }

  // Enhanced createCattle with offline support
  Future<String> createCattle({
    required String age,
    required String breed,
    required String sex,
    required String diseasesAilments,
    required String height,
    required String name,
    required String weight,
    required List<File>? images,
    required List<List<double>> faceEmbeddings,
    required List<List<double>> noseEmbeddings,
    required String date,
  }) async {
    try {
      String cattleId = uuid.v1();

      // Convert File objects to file paths for local storage
      List<String>? imagePaths;
      if (images != null) {
        imagePaths = images.map((file) => file.path).toList();
      }

      // Create cattle record
      final cattleRecord = CattleRecord(
        id: cattleId,
        age: age,
        breed: breed,
        sex: sex,
        diseasesAilments: diseasesAilments,
        height: height,
        name: name,
        weight: weight,
        localImagePaths: imagePaths, // Store paths instead of File objects
        faceEmbeddings: faceEmbeddings,
        noseEmbeddings: noseEmbeddings,
        date: date,
        ownerUid: currentUser?.uid,
        isSynced: false,
        imageUrls: [],
      );

      // 2. Store cattle record locally
      await _storeCattleLocally(cattleRecord);

      // 3. Add to sync queue for online synchronization
      await _addToSyncQueue(cattleId);

      // 4. Try immediate sync if online
      if (await NetworkService.isOnline()) {
        await syncCattleToCloudRecord(cattleId);
      }

      return cattleId;
    } catch (e, stack) {
      debugPrint('Error creating cattle: $e\n$stack');
      rethrow;
    }
  }

  // Store cattle record locally
  Future<void> _storeCattleLocally(CattleRecord record) async {
    await _cattleBox?.put(record.id, record.toJson());
  }

  // Add to sync queue
  Future<void> _addToSyncQueue(String cattleId) async {
    await _syncQueueBox?.put(cattleId, {
      'cattleId': cattleId,
      'action': 'create',
      'attempts': 0,
      'lastAttempt': null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// @return no cattle means cow not found
  /// @return skip means already synced
  /// @return synced means synchronised
  /// @return failed means failed to sync
  Future<String> syncCattleToCloudRecord(String cattleId) async {
    try {
      final localData = _cattleBox?.get(cattleId);
      if (localData == null) return 'no cattle';

      final cattleRecord =
          CattleRecord.fromJson(Map<String, dynamic>.from(localData));

      // if ( cattleRecord.isSynced){
      //   return 'skip';
      // }

      // 1. Upload image to Firebase Storage if not already done
      List<String>? imageUrls = cattleRecord.imageUrls;
      if ((imageUrls == null || imageUrls.isEmpty) &&
          cattleRecord.localImagePaths != null) {
        // Convert file paths back to File objects for upload
        final List<File> imageFiles = cattleRecord.localImagePaths!
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();

        if (imageFiles.isNotEmpty) {
          imageUrls = await await _uploadCattleImage(imageFiles, cattleId);

          // Update local record with image URLs
          if (imageUrls != null) {
            final updatedRecord = CattleRecord(
              id: cattleRecord.id,
              age: cattleRecord.age,
              breed: cattleRecord.breed,
              sex: cattleRecord.sex,
              diseasesAilments: cattleRecord.diseasesAilments,
              height: cattleRecord.height,
              name: cattleRecord.name,
              weight: cattleRecord.weight,
              localImagePaths: cattleRecord.localImagePaths,
              imageUrls: imageUrls,
              faceEmbeddings: cattleRecord.faceEmbeddings,
              noseEmbeddings: cattleRecord.noseEmbeddings,
              date: cattleRecord.date,
              ownerUid: cattleRecord.ownerUid,
              isSynced: cattleRecord.isSynced,
              lastSyncAttempt: cattleRecord.lastSyncAttempt,
              syncAttempts: cattleRecord.syncAttempts,
            );

            await _storeCattleLocally(updatedRecord);
          }
        }
      }

      // 2. Upload cattle data to Firestore (without localImagePaths)
      final firestoreData = cattleRecord.toJson();

      // 3. serialize lists of embeddings for upload
      final serializedFaceEmbeddings = cattleRecord.faceEmbeddings.asMap().map(
            (index, embedding) => MapEntry(index.toString(), embedding),
          );

      final serializedNoseEmbeddings = cattleRecord.noseEmbeddings.asMap().map(
            (index, embedding) => MapEntry(index.toString(), embedding),
          );
      firestoreData
          .remove('localImagePaths'); // Don't send local paths to Firestore

      firestoreData['faceEmbeddings'] = serializedFaceEmbeddings;
      firestoreData['noseEmbeddings'] = serializedNoseEmbeddings;

      await cattleCollection
          .doc(cattleId)
          .set(firestoreData, SetOptions(merge: true));

      // 4. Mark as synced and remove from queue
      await _markAsSynced(cattleId);

      return 'synced';
    } catch (e) {
      debugPrint('Sync failed for cattle $cattleId: $e');
      await _incrementSyncAttempts(cattleId);
      return 'failed';
    }
  }

  // Upload cattle image to Firebase Storage
  Future<List<String>?> _uploadCattleImage(
      List<File> imageFiles, String cattleId) async {
    try {
      int count = 0;
      List<String> downloadUrls = [];

      for (File file in imageFiles) {
        final ref = storage
            .ref()
            .child('cattle_images/${currentUser?.uid}/$cattleId _ $count.jpg');
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'uploaded_from': 'cattle_app'},
          ),
        );

        final taskSnapshot = await uploadTask;
        downloadUrls.add(await taskSnapshot.ref.getDownloadURL());
        count += 1;
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  // Mark record as synced
  Future<void> _markAsSynced(String cattleId) async {
    final localData = _cattleBox?.get(cattleId);
    if (localData != null) {
      localData['isSynced'] = true;
      localData['lastSyncAttempt'] = DateTime.now().millisecondsSinceEpoch;
      await _cattleBox?.put(cattleId, localData);
    }
    await _syncQueueBox?.delete(cattleId);
  }

  // Increment sync attempts
  Future<void> _incrementSyncAttempts(String cattleId) async {
    final queueItem = _syncQueueBox?.get(cattleId);
    if (queueItem != null) {
      final attempts = (queueItem['attempts'] ?? 0) + 1;
      await _syncQueueBox?.put(cattleId, {
        ...queueItem,
        'attempts': attempts,
        'lastAttempt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Get cattle box for external access
  static Box? getCattleBox() => _cattleBox;

  // Get sync queue box for external access
  static Box? getSyncQueueBox() => _syncQueueBox;

  List<CattleRecord> getAllCattle() {
    final allKeys = CattleRepository.getCattleBox()?.keys.toList() ?? [];
    final cattleList = <CattleRecord>[];

    // Load all cattle records
    for (final key in allKeys) {
      final data = CattleRepository.getCattleBox()?.get(key);
      if (data != null) {
        cattleList.add(CattleRecord.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    return cattleList;
  }

  ///##########################################################################
  ///#########################################################################
  ///
  /// For online to offline sync
  /// Sync from Cloud Firestore to local Hive storage
  /// Use this when you want to download all user's cattle for offline access
  ///
  Future<String> syncSingleCattleFromCloud(String cattleId) async {
    try {
      // 1. Check network connectivity
      if (!await NetworkService.isOnline()) {
        debugPrint('No internet connection for cloud sync');
        return 'offline';
      }

      // 2. Check user authentication
      final user = currentUser;
      if (user == null) {
        debugPrint('No authenticated user');
        return 'logged out';
      }

      debugPrint('Starting cloud-to-local sync for cattle: $cattleId');

      // 3. Fetch specific cattle document from Firestore
      final doc = await cattleCollection.doc(cattleId).get();

      if (!doc.exists) {
        debugPrint('Cattle $cattleId not found in cloud');
        return 'not found';
      }

      // 4. Verify ownership (optional but recommended)
      final cloudData = doc.data() as Map<String, dynamic>;
      final cloudOwnerUid = cloudData['ownerUid']?.toString();

      if (cloudOwnerUid != user.uid) {
        debugPrint('Unauthorized: Cattle $cattleId does not belong to current user');
        return 'unauthorized';
      }

      // 5. Parse and convert to CattleRecord
      final cattleRecord = await _parseCloudDocument(cloudData, cattleId);

      // 6. Check if update is needed (optional timestamp check)
      final localData = _cattleBox?.get(cattleId);
      bool shouldUpdate = true;

      if (localData != null) {
        final localRecord = CattleRecord.fromJson(Map<String, dynamic>.from(localData));

        // Only update if cloud has newer data or local is not synced
        final cloudTimestamp = _getLastUpdated(cloudData);
        final localTimestamp = localRecord.lastSyncAttempt;

        shouldUpdate = cloudTimestamp > (localTimestamp ?? 0) || !localRecord.isSynced;

        if (!shouldUpdate) {
          debugPrint('Local version is up-to-date for cattle: $cattleId');
          return 'skip';
        }
      }

      // 7. Download and cache images if available
      if (cattleRecord.imageUrls != null &&
          cattleRecord.imageUrls!.isNotEmpty) {
        debugPrint('Downloading images for cattle: $cattleId');
        await _downloadAndCacheImages(cattleRecord);
      } else {

      debugPrint('Downloading images for cattle: $cattleId');
      await _downloadAndCacheImages(cattleRecord);
      }

      // 8. Store cattle record locally
      await _storeCattleLocally(cattleRecord);
      debugPrint('Successfully synced cattle $cattleId from cloud to local');

      return 'synced';

    } catch (e, stack) {
      debugPrint('Error syncing cattle $cattleId from cloud: $e\n$stack');
      return 'failed';
    }
  }

  /// Parse a Firestore document into a CattleRecord
  Future<CattleRecord> _parseCloudDocument(
      Map<String, dynamic> cloudData, String cattleId) async {
    // 1. Convert serialized embeddings back to List<List<double>>
    final faceEmbeddings = _deserializeEmbeddings(cloudData['faceEmbeddings']);
    final noseEmbeddings = _deserializeEmbeddings(cloudData['noseEmbeddings']);

    // 2. Get local image paths if they exist
    List<String>? localImagePaths = [];

    // 3. Create the record
    return CattleRecord(
      id: cattleId,
      age: cloudData['age']?.toString() ?? '',
      breed: cloudData['breed']?.toString() ?? '',
      sex: cloudData['sex']?.toString() ?? '',
      diseasesAilments: cloudData['diseasesAilments']?.toString() ?? '',
      height: cloudData['height']?.toString() ?? '',
      name: cloudData['name']?.toString() ?? '',
      weight: cloudData['weight']?.toString() ?? '',
      localImagePaths: localImagePaths,
      imageUrls: cloudData['imageUrls'] is List
          ? List<String>.from(cloudData['imageUrls'])
          : [],
      image: cloudData['image']?.toString() ?? '',
      faceEmbeddings: faceEmbeddings,
      noseEmbeddings: noseEmbeddings,
      date: cloudData['date']?.toString() ?? '',
      ownerUid: cloudData['ownerUid']?.toString(),
      isSynced: true, // From cloud, so it's synced
      lastSyncAttempt: DateTime.now().millisecondsSinceEpoch,
      syncAttempts: 0,
    );
  }

  /// Deserialize embeddings from Firestore format
  List<List<double>> _deserializeEmbeddings(dynamic data) {
    if (data == null) return [];

    try {
      if (data is Map) {
        // Firestore stores embeddings as map: {"0": [256 values], "1": [256 values]}
        // Each value is a single embedding with 256 elements
        return data.entries.map((entry) {
          if (entry.value is List) {
            return (entry.value as List)
                .map<double>((v) => v.toDouble())
                .toList();
          }
          return <double>[];
        }).toList();

      } else if (data is List) {
        // ARRAY FORMAT: It's a single embedding with 256 values
        // Example: [v1, v2, v3, ..., v256]

        // Convert the single array to List<double>
        List<double> singleEmbedding = data.map<double>((v) => v.toDouble()).toList();

        // Repeat this single embedding 3 times to create 3 identical embeddings
        return List.generate(3, (_) => singleEmbedding);
      }
    } catch (e) {
      debugPrint('Error deserializing embeddings: $e');
    }

    return [];
  }

  /// Download and cache images locally
  Future<void> _downloadAndCacheImages(CattleRecord record) async {
    final List<String> localPaths = [];
    int count =0;
    if (record.imageUrls == null || record.imageUrls!.isEmpty){

      final url = record.image;
      for (int i=0;i<3;i){
        final fileName = '${record.id}_$i.jpg';
        final localFile = await _downloadImageToLocal(url!, fileName);

        if (localFile != null) {
          localPaths.add(localFile.path);
        }
      }
    }else{

      for (final url in record.imageUrls!) {
        try {
          final fileName = '${record.id}_$count.jpg';
          final localFile = await _downloadImageToLocal(url, fileName);

          if (localFile != null) {
            localPaths.add(localFile.path);
          }
          count++;
        } catch (e) {
          debugPrint('Failed to download image: $e');
        }
      }
    }



    // Update record with local paths
    if (localPaths.isNotEmpty) {
      final updatedRecord = CattleRecord(
        id: record.id,
        age: record.age,
        breed: record.breed,
        sex: record.sex,
        diseasesAilments: record.diseasesAilments,
        height: record.height,
        name: record.name,
        weight: record.weight,
        localImagePaths: localPaths,
        imageUrls: record.imageUrls,
        faceEmbeddings: record.faceEmbeddings,
        noseEmbeddings: record.noseEmbeddings,
        date: record.date,
        ownerUid: record.ownerUid,
        isSynced: true,
        lastSyncAttempt: record.lastSyncAttempt,
        syncAttempts: record.syncAttempts,
      );

      await _storeCattleLocally(updatedRecord);
    }
  }

  /// Download single image to local storage
  Future<File?> _downloadImageToLocal(String imageUrl, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/cattle_images/$fileName';
      final file = File(filePath);

      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);

      // Download the file
      final http.Response response = await http.get(Uri.parse(imageUrl));
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      debugPrint('Error downloading image $fileName: $e');
      return null;
    }
  }

  /// Clean up local records that no longer exist in cloud
  Future<void> _cleanupOrphanedRecords(List<String> cloudIds) async {
    final localIds = _cattleBox?.keys.toList().cast<String>() ?? [];

    for (final localId in localIds) {
      if (!cloudIds.contains(localId)) {
        // This local record doesn't exist in cloud - delete it
        await _cattleBox?.delete(localId);
        await _syncQueueBox?.delete(localId);
        debugPrint('Removed orphaned record: $localId');
      }
    }
  }

  /// Get last updated timestamp from cloud data
  int _getLastUpdated(Map<String, dynamic> cloudData) {
    // Check for Firestore timestamp field
    if (cloudData['updatedAt'] is Timestamp) {
      return (cloudData['updatedAt'] as Timestamp).millisecondsSinceEpoch;
    }
    if (cloudData['lastUpdated'] is Timestamp) {
      return (cloudData['lastUpdated'] as Timestamp).millisecondsSinceEpoch;
    }
    if (cloudData['timestamp'] is Timestamp) {
      return (cloudData['timestamp'] as Timestamp).millisecondsSinceEpoch;
    }

    // Fallback to current time
    return DateTime.now().millisecondsSinceEpoch;
  }


}
