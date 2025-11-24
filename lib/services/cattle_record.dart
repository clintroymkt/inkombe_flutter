class CattleRecord {
  final String id;
  final String age;
  final String breed;
  final String sex;
  final String diseasesAilments;
  final String height;
  final String name;
  final String weight;
  final List<String>? localImagePaths; // Store file paths instead of File objects
  final List<String>? imageUrls;
  final List<List<double>> faceEmbeddings;
  final List<List<double>> noseEmbeddings;
  final String date;
  final String? ownerUid;
  final bool isSynced;
  final int? lastSyncAttempt;
  final int? syncAttempts;

  CattleRecord({
    required this.id,
    required this.age,
    required this.breed,
    required this.sex,
    required this.diseasesAilments,
    required this.height,
    required this.name,
    required this.weight,
    this.localImagePaths, // Changed from List<File>?
    this.imageUrls,
    required this.faceEmbeddings,
    required this.noseEmbeddings,
    required this.date,
    this.ownerUid,
    this.isSynced = false,
    this.lastSyncAttempt,
    this.syncAttempts = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'breed': breed,
      'sex': sex,
      'diseasesAilments': diseasesAilments,
      'height': height,
      'name': name,
      'weight': weight,
      'localImagePaths': localImagePaths, // Store paths instead of File objects
      'imageUrls': imageUrls,
      'faceEmbeddings': faceEmbeddings,
      'noseEmbeddings': noseEmbeddings,
      'date': date,
      'ownerUid': ownerUid,
      'isSynced': isSynced,
      'lastSyncAttempt': lastSyncAttempt,
      'syncAttempts': syncAttempts,
    };
  }

  factory CattleRecord.fromJson(Map<String, dynamic> json) {
    return CattleRecord(
      id: json['id'] ?? '',
      age: json['age'] ?? '',
      breed: json['breed'] ?? '',
      sex: json['sex'] ?? '',
      diseasesAilments: json['diseasesAilments'] ?? '',
      height: json['height'] ?? '',
      name: json['name'] ?? '',
      weight: json['weight'] ?? '',

      localImagePaths: json['localImagePaths'] != null
          ? List<String>.from(json['localImagePaths'])
          : null,

      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,

      faceEmbeddings: json['faceEmbeddings'] != null
          ? List<List<double>>.from(json['faceEmbeddings'].map(
              (e) => List<double>.from(e)))
          : [],

      noseEmbeddings: json['noseEmbeddings'] != null
          ? List<List<double>>.from(json['noseEmbeddings'].map(
              (e) => List<double>.from(e)))
          : [],

      date: json['date'] ?? '',
      ownerUid: json['ownerUid'],
      isSynced: json['isSynced'] ?? false,
      lastSyncAttempt: json['lastSyncAttempt'],
      syncAttempts: json['syncAttempts'] ?? 0,
    );
  }
}