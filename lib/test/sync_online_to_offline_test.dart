import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import '../services/cattle_record.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {
  @override
  String get uid => 'owner123';
}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late CattleRepository testRepository;
  late Directory testDir;

  setUp(() async {
    // 1. Initialize Flutter bindings
    TestWidgetsFlutterBinding.ensureInitialized();

    // 2. Create a temporary directory for Hive
    testDir = Directory('/tmp/test_hive_${DateTime.now().millisecondsSinceEpoch}');
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
    await testDir.create(recursive: true);

    // 3. Initialize CattleRepository with test directory
    await CattleRepository.init(testDirectory: testDir.path);

    // 4. Setup fake Firestore and mocks
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockAuth.currentUser).thenReturn(mockUser);

    // 5. Create repository with injected dependencies
    testRepository = CattleRepository.withDependencies(
      firestore: fakeFirestore,
      auth: mockAuth,
      storage: MockFirebaseStorage(),
      isOnline: () async => true, // Mock as always online
      httpClient: MockHttpClient(),
      uuid: Uuid(),
    );
  });

  tearDown(() async {
    // Clean up test directory
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  group('CattleRepository Integration Tests', () {
    test('Should successfully sync cattle from cloud to local', () async {
      // Setup test data in fake Firestore
      final collection = fakeFirestore.collection('cattle');
      final cattleId = 'online_id_0';

      final testData = {
        'id': cattleId,
        'age': '${Random().nextInt(10) + 1}',
        'breed': 'Holstein',
        'sex': 'F',
        'diseasesAilments': 'None',
        'height': '${100 + Random().nextInt(50)}',
        'name': 'Cow-test',
        'weight': '${300 + Random().nextInt(300)}',
        'localImagePaths': null,
        'imageUrls': null,
        'image': null,
        'faceEmbeddings': {'0': _embedding256()},
        'noseEmbeddings': {'0': _embedding256()},
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'ownerUid': 'owner123', // Must match mock user uid
        'isSynced': true,
        'lastSyncAttempt': DateTime.now().millisecondsSinceEpoch,
        'syncAttempts': 0,
      };

      await collection.doc(cattleId).set(testData);

      // Call the method
      final result = await testRepository.syncSingleCattleFromCloud(cattleId);

      // Verify the result
      expect(result, 'synced', reason: 'Should successfully sync existing cattle');

      // Verify the cattle was stored locally in Hive
      final localBox = CattleRepository.getCattleBox();
      final localData = localBox?.get(cattleId);
      expect(localData, isNotNull, reason: 'Cattle should be stored locally');

      // Verify the data integrity
      if (localData != null) {
        final cattleRecord = CattleRecord.fromJson(
            Map<String, dynamic>.from(localData)
        );

        expect(cattleRecord.id, cattleId);
        expect(cattleRecord.ownerUid, 'owner123');
        expect(cattleRecord.isSynced, true);
        expect(cattleRecord.name, 'Cow-test');

        // Verify embeddings were deserialized correctly
        expect(cattleRecord.faceEmbeddings, isNotEmpty);
        expect(cattleRecord.faceEmbeddings[0].length, 256);
      }
    });

    test('Should return "not found" for non-existent cattle', () async {
      // Don't add any data to Firestore
      final result = await testRepository.syncSingleCattleFromCloud('non_existent_id');
      expect(result, 'not found');
    });

    test('Should return "unauthorized" for cattle owned by different user', () async {
      // Setup cattle with different owner
      final collection = fakeFirestore.collection('cattle');
      final cattleId = 'other_owner_cattle';

      final otherOwnerData = {
        'id': cattleId,
        'ownerUid': 'different_owner', // Different from mock user
        'name': 'Other Owner Cow',
        'age': '3',
        'breed': 'Angus',
        'sex': 'F',
        'diseasesAilments': 'None',
        'height': '130',
        'weight': '400',
        'date': DateTime.now().toIso8601String(),
        'isSynced': true,
        'faceEmbeddings': {'0': _embedding256()},
        'noseEmbeddings': {'0': _embedding256()},
      };

      await collection.doc(cattleId).set(otherOwnerData);

      final result = await testRepository.syncSingleCattleFromCloud(cattleId);
      expect(result, 'unauthorized');
    });

    test('Should return "skip" when local version is up-to-date', () async {
      // First, sync a cattle to local storage
      final collection = fakeFirestore.collection('cattle');
      final cattleId = 'fresh_cattle';

      final freshData = {
        'id': cattleId,
        'ownerUid': 'owner123',
        'name': 'Fresh Cow',
        'age': '2',
        'breed': 'Hereford',
        'sex': 'M',
        'diseasesAilments': 'Healthy',
        'height': '125',
        'weight': '350',
        'date': DateTime.now().toIso8601String(),
        'isSynced': true,
        'faceEmbeddings': {'0': _embedding256()},
        'noseEmbeddings': {'0': _embedding256()},
      };

      await collection.doc(cattleId).set(freshData);

      // First sync - should work
      final firstResult = await testRepository.syncSingleCattleFromCloud(cattleId);
      expect(firstResult, 'synced');

      // Second sync with same data - should skip
      final secondResult = await testRepository.syncSingleCattleFromCloud(cattleId);
      expect(secondResult, 'skip');
    });

    test('Should handle legacy single embedding format', () async {
      // Test with legacy format (List instead of Map)
      final collection = fakeFirestore.collection('cattle');
      final cattleId = 'legacy_format_cattle';

      final legacyData = {
        'id': cattleId,
        'ownerUid': 'owner123',
        'name': 'Legacy Cow',
        'age': '5',
        'breed': 'Holstein',
        'sex': 'F',
        'diseasesAilments': 'None',
        'height': '140',
        'weight': '500',
        'date': DateTime.now().toIso8601String(),
        'isSynced': true,
        'faceEmbeddings': _embedding256(), // Legacy: List<double> instead of Map
        'noseEmbeddings': _embedding256(), // Legacy: List<double> instead of Map
      };

      await collection.doc(cattleId).set(legacyData);

      final result = await testRepository.syncSingleCattleFromCloud(cattleId);
      expect(result, 'synced');

      // Verify legacy format was handled correctly
      final localBox = CattleRepository.getCattleBox();
      final localData = localBox?.get(cattleId);
      expect(localData, isNotNull);

      if (localData != null) {
        final cattleRecord = CattleRecord.fromJson(
            Map<String, dynamic>.from(localData)
        );

        // Legacy single embedding should be converted to 3 identical embeddings
        expect(cattleRecord.faceEmbeddings.length, 3);
        expect(cattleRecord.noseEmbeddings.length, 3);
      }
    });

    test('Should return "offline" when network is not available', () async {
      // Create repository with offline network mock
      final offlineRepository = CattleRepository.withDependencies(
        firestore: fakeFirestore,
        auth: mockAuth,
        storage: MockFirebaseStorage(),
        isOnline: () async => false, // Mock offline
        httpClient: MockHttpClient(),
        uuid: Uuid(),
      );

      final result = await offlineRepository.syncSingleCattleFromCloud('any_id');
      expect(result, 'offline');
    });
  });

  // ===========================================================================
  // YOUR ORIGINAL TEST - KEPT AS IS
  // ===========================================================================

  test('five IDs overlap and first two locals share lastSyncAttempt', () async {
    // Setup fake Firestore with your original test data
    await _populateTestData(fakeFirestore);

    // Use your original test logic (adapting it slightly)
    final collection = fakeFirestore.collection('cattle');
    final snapshot = await collection.get();
    final onlineCattleDocs = snapshot.docs;

    // Create local records that match the pattern
    final matchingIds = onlineCattleDocs.take(5).map((d) => d.id).toList();
    final sharedStamp = DateTime.now().millisecondsSinceEpoch;
    final localCattleLocalList = <CattleRecord>[];

    for (int i = 0; i < 10; i++) {
      final isMatch = i < matchingIds.length;
      final id = isMatch ? matchingIds[i] : 'local_only_id_$i';

      localCattleLocalList.add(CattleRecord(
        id: id,
        age: '5',
        breed: 'Holstein',
        sex: 'F',
        diseasesAilments: 'None',
        height: '140',
        name: 'Test Cow',
        weight: '500',
        localImagePaths: null,
        imageUrls: null,
        image: null,
        faceEmbeddings: [],
        noseEmbeddings: [],
        date: DateTime.now().toIso8601String(),
        ownerUid: 'owner123',
        isSynced: true,
        lastSyncAttempt: (isMatch && i < 2) ? sharedStamp : DateTime.now().millisecondsSinceEpoch,
        syncAttempts: 0,
      ));
    }

    final localIds = localCattleLocalList.map((c) => c.id).toSet();
    final onlineIds = onlineCattleDocs.map((d) => d.id).toSet();
    final overlap = localIds.intersection(onlineIds);

    expect(overlap.length, 5, reason: 'should have 5 matching IDs');

    final sharedStamps = localCattleLocalList
        .where((c) => overlap.contains(c.id))
        .take(2)
        .map((c) => c.lastSyncAttempt)
        .toSet();

    expect(sharedStamps.length, 1,
        reason: 'first two matching locals must share timestamp');
  });
}

// Helper function to populate test data
Future<void> _populateTestData(FakeFirebaseFirestore fakeFirestore) async {
  final collection = fakeFirestore.collection('cattle');
  final rnd = Random();

  // Add 20 documents to fake Firestore
  for (int i = 0; i < 20; i++) {
    final id = 'online_id_$i';
    final data = {
      'id': id,
      'age': '${rnd.nextInt(10) + 1}',
      'breed': ['Holstein', 'Angus', 'Hereford'][rnd.nextInt(3)],
      'sex': rnd.nextBool() ? 'M' : 'F',
      'diseasesAilments': rnd.nextBool() ? 'None' : 'Foot rot',
      'height': '${100 + rnd.nextInt(50)}',
      'name': 'Cow-${id.substring(0, 4)}',
      'weight': '${300 + rnd.nextInt(300)}',
      'localImagePaths': null,
      'imageUrls': null,
      'image': null,
      'faceEmbeddings': {'0': _embedding256()},
      'noseEmbeddings': {'0': _embedding256()},
      'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'ownerUid': 'owner123',
      'isSynced': true,
      'lastSyncAttempt': DateTime.now()
          .subtract(Duration(days: rnd.nextInt(30)))
          .millisecondsSinceEpoch,
      'syncAttempts': rnd.nextInt(5) + 1,
    };

    await collection.doc(id).set(data);
  }
}

List<double> _embedding256() =>
    List.generate(256, (_) => Random().nextDouble() * 2 - 1);