class CattleRecord {
  final String id;
  final String age;
  final String breed;
  final String sex;
  final String diseasesAilments;
  final String height;
  final String name;
  final String weight;
  final List<String>? localImagePaths;
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
    this.localImagePaths,
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
      'localImagePaths': localImagePaths,
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
      id: json['id']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      sex: json['sex']?.toString() ?? '',
      diseasesAilments: json['diseasesAilments']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      localImagePaths: json['localImagePaths'] != null
          ? List<String>.from(json['localImagePaths'])
          : null,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      faceEmbeddings: _parseEmbeddings(json['faceEmbeddings']),
      noseEmbeddings: _parseEmbeddings(json['noseEmbeddings']),
      date: json['date']?.toString() ?? '',
      ownerUid: json['ownerUid']?.toString(),
      isSynced: json['isSynced'] ?? false,
      lastSyncAttempt: json['lastSyncAttempt'],
      syncAttempts: json['syncAttempts'] ?? 0,
    );
  }

  static List<List<double>> _parseEmbeddings(dynamic embeddingsData) {
    if (embeddingsData == null) return [];

    try {
      if (embeddingsData is List) {
        return embeddingsData.map<List<double>>((embedding) {
          if (embedding is List) {
            return embedding.map<double>((value) {
              if (value is double) return value;
              if (value is int) return value.toDouble();
              if (value is String) return double.tryParse(value) ?? 0.0;
              return 0.0;
            }).toList();
          }
          return [];
        }).toList();
      }
    } catch (e) {
      print('Error parsing embeddings: $e');
    }

    return [];
  }
}