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
  final String? image;
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
    this.image,
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
      'image':image,
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
      image: json['image']?.toString() ?? '',
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
      /* ========== 1.  new shape: Map<String,List>  ========== */
      if (embeddingsData is Map) {
        final map = embeddingsData.cast<String, List>();
        // sort by numeric key so 0,1,2 stay in order
        final sortedEntries = map.entries.toList()
          ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
        return sortedEntries
            .map((e) => e.value.map<double>((v) => _toDouble(v)).toList())
            .toList();
      }

      /* ========== 2.  legacy shape: List<List>  ========== */
      if (embeddingsData is List) {
        return embeddingsData.map<List<double>>((embedding) {
          if (embedding is List) {
            return embedding.map<double>(_toDouble).toList();
          }
          return [];
        }).toList();
      }
    } catch (e) {
      print('Error parsing embeddings: $e');
    }

    return [];
  }

/* helper to keep the numeric conversion in one place */
  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}