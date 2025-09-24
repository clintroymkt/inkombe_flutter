class CattleRecord {
  final String? id;
  final String age;
  final String breed;
  final String sex;
  final String diseasesAilments;
  final String height;
  final String name;
  final String weight;
  final String? imagePath; // Local image path
  late final String? imageUrl; // Firebase Storage URL
  final List<List<double>> faceEmbeddings;
  final List<List<double>> noseEmbeddings;
  final String date;
  final String? ownerUid;
  final bool isSynced;
  final DateTime? lastSyncAttempt;
  final int syncAttempts;

  CattleRecord({
    this.id,
    required this.age,
    required this.breed,
    required this.sex,
    required this.diseasesAilments,
    required this.height,
    required this.name,
    required this.weight,
    this.imagePath,
    this.imageUrl,
    required this.faceEmbeddings,
    required this.noseEmbeddings,
    required this.date,
    this.ownerUid,
    this.isSynced = false,
    this.lastSyncAttempt,
    this.syncAttempts = 0,
  });

  Map<String, dynamic> toJson() {
    // Convert embeddings to Firestore-friendly format
    final serializedFaceEmbeddings = faceEmbeddings.asMap().map(
          (index, embedding) => MapEntry(index.toString(), embedding),
    );

    final serializedNoseEmbeddings = noseEmbeddings.asMap().map(
          (index, embedding) => MapEntry(index.toString(), embedding),
    );

    return {
      if (id != null) 'id': id,
      'name': name,
      'age': age,
      'weight(kg)': weight,
      'height(m)': height,
      'breed': breed,
      'diet': '',
      'sex': sex,
      'diseases/ailments': diseasesAilments,
      'location': '',
      'imageUrl': imageUrl,
      'faceEmbeddings': serializedFaceEmbeddings,
      'noseEmbeddings': serializedNoseEmbeddings,
      'ownerUid': ownerUid,
      'dateAdded': date,
      'isSynced': isSynced,
      'lastSyncAttempt': lastSyncAttempt?.millisecondsSinceEpoch,
      'syncAttempts': syncAttempts,
      'localImagePath': imagePath,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static CattleRecord fromJson(Map<String, dynamic> json) {
    // Convert serialized embeddings back to List<List<double>>
    final faceEmbeddingsMap = Map<String, dynamic>.from(json['faceEmbeddings'] ?? {});
    final noseEmbeddingsMap = Map<String, dynamic>.from(json['noseEmbeddings'] ?? {});


    final faceEntries = faceEmbeddingsMap.entries.toList();
    faceEntries.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    final faceEmbeddings = faceEntries.map((entry) => List<double>.from(entry.value)).toList();

    final noseEntries = noseEmbeddingsMap.entries.toList();
    noseEntries.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    final noseEmbeddings = noseEntries.map((entry) => List<double>.from(entry.value)).toList();

    return CattleRecord(
      id: json['id'],
      age: json['age'] ?? '',
      breed: json['breed'] ?? '',
      sex: json['sex'] ?? '',
      diseasesAilments: json['diseases/ailments'] ?? '',
      height: json['height(m)'] ?? '',
      name: json['name'] ?? '',
      weight: json['weight(kg)'] ?? '',
      imagePath: json['localImagePath'],
      imageUrl: json['imageUrl'],
      faceEmbeddings: faceEmbeddings,
      noseEmbeddings: noseEmbeddings,
      date: json['dateAdded'] ?? '',
      ownerUid: json['ownerUid'],
      isSynced: json['isSynced'] ?? false,
      lastSyncAttempt: json['lastSyncAttempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSyncAttempt'])
          : null,
      syncAttempts: json['syncAttempts'] ?? 0,
    );
  }
}