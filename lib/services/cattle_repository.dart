import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:inkombe_flutter/services/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'cattle_record.dart';
import 'network_service.dart';
import 'package:uuid/uuid.dart';



class CattleRepository {
  // Dependencies
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final Future<bool> Function() _isOnline;
  final http.Client _httpClient;
  final Uuid _uuid;

  // Derived properties
  CollectionReference get cattleCollection => _firestore.collection('cattle');
  User? get currentUser => _auth.currentUser;

  // Hive storage
  static const String _cattleBoxName = 'cattle_records';
  static const String _syncQueueBoxName = 'cattle_sync_queue';
  static Box? _cattleBox;
  static Box? _syncQueueBox;

  // ===========================================================================
  // CONSTRUCTORS
  // ===========================================================================

  /// Default constructor for production use - uses Firebase singletons
  CattleRepository() : this.withDependencies(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
    isOnline: NetworkService.isOnline, // Pass static method
    httpClient: http.Client(),
    uuid: Uuid(),
  );

  /// Dependency-injected constructor for testing
  CattleRepository.withDependencies({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
    required Future<bool> Function() isOnline, // Accept function
    required http.Client httpClient,
    required Uuid uuid,
  }) : _firestore = firestore,
        _auth = auth,
        _storage = storage,
        _isOnline = isOnline, // Store function
        _httpClient = httpClient,
        _uuid = uuid;


  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Static initialization - must be called before using any repository instance
  static Future<void> init({String? testDirectory}) async {
    final directory = testDirectory != null
        ? Directory(testDirectory)
        : await getApplicationDocumentsDirectory();

    Hive.init(directory.path);
    _cattleBox = await Hive.openBox(_cattleBoxName);
    _syncQueueBox = await Hive.openBox(_syncQueueBoxName);
  }

  // ===========================================================================
  // PUBLIC METHODS
  // ===========================================================================

  /// Enhanced createCattle with offline support
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
      String cattleId = _uuid.v1();

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
        localImagePaths: imagePaths,
        faceEmbeddings: faceEmbeddings,
        noseEmbeddings: noseEmbeddings,
        date: date,
        ownerUid: currentUser?.uid,
        isSynced: false,
        imageUrls: [],
      );

      // Store locally
      await _storeCattleLocally(cattleRecord);

      // Add to sync queue
      await _addToSyncQueue(cattleId);

      // Try immediate sync if online
      if (!await _isOnline()) {
        await syncCattleToCloudRecord(cattleId);
      }

      return cattleId;
    } catch (e, stack) {
      debugPrint('Error creating cattle: $e\n$stack');
      rethrow;
    }
  }

  /// Sync cattle from local to cloud
  /// @return 'no cattle' means cow not found
  /// @return 'skip' means already synced
  /// @return 'synced' means synchronized
  /// @return 'failed' means failed to sync
  Future<String> syncCattleToCloudRecord(String cattleId) async {

    try {
      final localData = _cattleBox?.get(cattleId);
      if (localData == null) return 'no cattle';

      final cattleRecord =
      CattleRecord.fromJson(Map<String, dynamic>.from(localData));

      // Upload images if needed
      List<String>? imageUrls = cattleRecord.imageUrls;
      if ((imageUrls == null || imageUrls.isEmpty) &&
          cattleRecord.localImagePaths != null) {
        final List<File> imageFiles = cattleRecord.localImagePaths!
            .map((path) => File(path))
            .where((file) => file.existsSync())
            .toList();

        if (imageFiles.isNotEmpty) {
          imageUrls = await _uploadCattleImage(imageFiles, cattleId);

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
              lastSyncAttempt: DateTime.now().millisecondsSinceEpoch,
              syncAttempts: cattleRecord.syncAttempts,
            );

            await _storeCattleLocally(updatedRecord);
          }
        }
      }

      // Prepare Firestore data
      final firestoreData = cattleRecord.toJson();

      // Serialize embeddings for Firestore
      firestoreData['faceEmbeddings'] = _serializeEmbeddings(
          cattleRecord.faceEmbeddings);
      firestoreData['noseEmbeddings'] = _serializeEmbeddings(
          cattleRecord.noseEmbeddings);
      firestoreData.remove('localImagePaths'); // Don't send local paths

      // Upload to Firestore
      await cattleCollection
          .doc(cattleId)
          .set(firestoreData, SetOptions(merge: true));

      // Mark as synced
      await _markAsSynced(cattleId);

      return 'synced';
    } catch (e) {
      debugPrint('Sync failed for cattle $cattleId: $e');
      await _incrementSyncAttempts(cattleId);
      return 'failed';
    }
  }


  /// Sync single cattle from cloud to local
  Future<String> syncSingleCattleFromCloud(String cattleId) async {
    try {
      // Check network
      if (!await _isOnline()) {
        debugPrint('No internet connection for cloud sync');
        return 'offline';
      }

      // Check authentication
      final user = currentUser;
      if (user == null) {
        debugPrint('No authenticated user');
        return 'logged out';
      }

      debugPrint('Starting cloud-to-local sync for cattle: $cattleId');

      // Fetch from Firestore
      final doc = await cattleCollection.doc(cattleId).get();

      if (!doc.exists) {
        debugPrint('Cattle $cattleId not found in cloud');
        return 'not found';
      }

      // Verify ownership
      final cloudData = doc.data() as Map<String, dynamic>;
      final cloudOwnerUid = cloudData['ownerUid']?.toString();

      if (cloudOwnerUid != user.uid) {
        debugPrint('Unauthorized: Cattle $cattleId does not belong to current user');
        return 'unauthorized';
      }

      // Parse document
      final cattleRecord = await _parseCloudDocument(cloudData, cattleId);

      // Check if update is needed
      final localData = _cattleBox?.get(cattleId);
      if (localData != null) {
        final localRecord = CattleRecord.fromJson(
            Map<String, dynamic>.from(localData));

        final cloudTimestamp = cloudData['lastSyncAttempt'] ?? 0;
        final localTimestamp = localRecord.lastSyncAttempt;

        final shouldUpdate = cloudTimestamp > (localTimestamp ?? 0) ||
            !localRecord.isSynced;

        if (!shouldUpdate) {
          debugPrint('Local version is up-to-date for cattle: $cattleId');
          return 'skip';
        }
      }

      // Download and cache images
       final localImagePaths = await _downloadAndCacheImages(cattleRecord);

      print(localImagePaths);

      if (localImagePaths.isNotEmpty) {
        final updatedRecord = CattleRecord(
          id: cattleRecord.id,
          age: cattleRecord.age,
          breed: cattleRecord.breed,
          sex: cattleRecord.sex,
          diseasesAilments: cattleRecord.diseasesAilments,
          height: cattleRecord.height,
          name: cattleRecord.name,
          weight: cattleRecord.weight,
          localImagePaths: localImagePaths,
          imageUrls: cattleRecord.imageUrls,
          faceEmbeddings: cattleRecord.faceEmbeddings,
          noseEmbeddings: cattleRecord.noseEmbeddings,
          date: cattleRecord.date,
          ownerUid: cattleRecord.ownerUid,
          isSynced: true,
          lastSyncAttempt: DateTime.now().millisecondsSinceEpoch,
          syncAttempts: cattleRecord.syncAttempts,
        );

        await _storeCattleLocally(updatedRecord);

        //sync the lastsync attampt to cloud
        // Prepare Firestore data
        final firestoreData = updatedRecord.toJson();

        // Serialize embeddings for Firestore
        firestoreData['faceEmbeddings'] = _serializeEmbeddings(
            cattleRecord.faceEmbeddings);
        firestoreData['noseEmbeddings'] = _serializeEmbeddings(
            cattleRecord.noseEmbeddings);
        firestoreData.remove('localImagePaths'); // Don't send local paths

        // Upload to Firestore
        await cattleCollection
            .doc(cattleId)
            .set(firestoreData, SetOptions(merge: true));

        return 'synced';
      }

      return 'no images';




    } catch (e, stack) {
      debugPrint('Error syncing cattle $cattleId from cloud: $e\n$stack');
      return 'failed';
    }
  }

  /// Get all cattle from local storage
  List<CattleRecord> getAllCattle() {
    final allKeys = _cattleBox?.keys.toList() ?? [];
    final cattleList = <CattleRecord>[];

    for (final key in allKeys) {
      final data = _cattleBox?.get(key);
      if (data != null) {
        cattleList.add(CattleRecord.fromJson(
            Map<String, dynamic>.from(data)));
      }
    }
    return cattleList;
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /// Store cattle record locally
  Future<void> _storeCattleLocally(CattleRecord record) async {
    await _cattleBox?.put(record.id, record.toJson());
  }

  /// Add to sync queue
  Future<void> _addToSyncQueue(String cattleId) async {
    await _syncQueueBox?.put(cattleId, {
      'cattleId': cattleId,
      'action': 'create',
      'attempts': 0,
      'lastAttempt': null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Mark record as synced
  Future<void> _markAsSynced(String cattleId) async {
    final localData = _cattleBox?.get(cattleId);
    if (localData != null) {
      localData['isSynced'] = true;
      localData['lastSyncAttempt'] = DateTime.now().millisecondsSinceEpoch;
      await _cattleBox?.put(cattleId, localData);
    }
    await _syncQueueBox?.delete(cattleId);
  }

  /// Increment sync attempts
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

  /// Upload cattle images to Firebase Storage
  Future<List<String>?> _uploadCattleImage(
      List<File> imageFiles, String cattleId) async {
    try {
      int count = 0;
      List<String> downloadUrls = [];

      for (File file in imageFiles) {
        final ref = _storage
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

  /// Serialize embeddings for Firestore
  Map<String, List<double>> _serializeEmbeddings(List<List<double>> embeddings) {
    return embeddings.asMap().map(
          (index, embedding) => MapEntry(index.toString(), embedding),
    );
  }

  /// Parse Firestore document into CattleRecord
  Future<CattleRecord> _parseCloudDocument(
      Map<String, dynamic> cloudData, String cattleId) async {
    final faceEmbeddings = _deserializeEmbeddings(cloudData['faceEmbeddings']);
    final noseEmbeddings = _deserializeEmbeddings(cloudData['noseEmbeddings']);

    return CattleRecord(
      id: cattleId,
      age: cloudData['age']?.toString() ?? '',
      breed: cloudData['breed']?.toString() ?? '',
      sex: cloudData['sex']?.toString() ?? '',
      diseasesAilments: cloudData['diseasesAilments']?.toString() ?? '',
      height: cloudData['height']?.toString() ?? '',
      name: cloudData['name']?.toString() ?? '',
      weight: cloudData['weight']?.toString() ?? '',
      localImagePaths: [],
      imageUrls: cloudData['imageUrls'] is List
          ? List<String>.from(cloudData['imageUrls'])
          : [],
      image: cloudData['image']?.toString() ?? '',
      faceEmbeddings: faceEmbeddings,
      noseEmbeddings: noseEmbeddings,
      date: cloudData['date']?.toString() ?? '',
      ownerUid: cloudData['ownerUid']?.toString(),
      isSynced: cloudData['isSynced'] ?? false,
      lastSyncAttempt: cloudData['lastSyncAttempt'] ?? 0,
      syncAttempts: 0,
    );
  }

  /// Deserialize embeddings from Firestore format
  List<List<double>> _deserializeEmbeddings(dynamic data) {
    if (data == null) return [];

    try {
      if (data is Map) {
        return data.entries.map((entry) {
          if (entry.value is List) {
            return (entry.value as List)
                .map<double>((v) => v.toDouble())
                .toList();
          }
          return <double>[];
        }).toList();

      } else if (data is List) {
        List<double> singleEmbedding =
        data.map<double>((v) => v.toDouble()).toList();
        return List.generate(3, (_) => singleEmbedding);
      }
    } catch (e) {
      debugPrint('Error deserializing embeddings: $e');
    }

    return [];
  }

  /// Download and cache images locally
  Future<List<String>> _downloadAndCacheImages(CattleRecord record) async {
    final List<String> localPaths = [];
    int count = 0;

    if (record.imageUrls == null || record.imageUrls!.isEmpty) {
      final url = record.image;
      for (int i = 0; i < 3; i++) {
        final fileName = '${record.id}_$i.jpg';
        final localFile = await _downloadImageToLocal(url!, fileName);
        if (localFile != null) {
          localPaths.add(localFile.path);
        }
      }
    } else {
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

    return localPaths;


  }

  /// Download single image to local storage
  Future<File?> _downloadImageToLocal(String imageUrl, String fileName) async {
    try {
        Directory directory;
        try {
          // Try to get application directory
          directory = await getApplicationDocumentsDirectory();
        } catch (e) {
          // If in test environment, use temporary directory
          directory = Directory.systemTemp;
        }
      final filePath = '${directory.path}/cattle_images/$fileName';
      final file = File(filePath);

      await file.parent.create(recursive: true);
      final response = await _httpClient.get(Uri.parse(imageUrl));
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      debugPrint('Error downloading image $fileName: $e');
      return null;
    }
  }


  // ===========================================================================
  // STATIC ACCESSORS (for backward compatibility)
  // ===========================================================================

  /// Get cattle box for external access
  static Box? getCattleBox() => _cattleBox;

  /// Get sync queue box for external access
  static Box? getSyncQueueBox() => _syncQueueBox;
}