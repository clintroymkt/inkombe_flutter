import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final storageRef = FirebaseStorage.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("User");

  final CollectionReference cattleCollection =
      FirebaseFirestore.instance.collection("Cattle");

  Future savingUserData(
    String email,
  ) async {
    return await userCollection.doc(currentUser?.uid).set({
      "fullName": "",
      "description": "",
      "email": email,
      "cattle": [],
      "profilePic": "",
      "uid": currentUser?.uid,
      'reg': false, //whether account is verified or not
      'admin': false //super user access
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }



//   create cattle
  Future<void> createCattle(
      String age,
      String breed,
      String sex,
      String diseasesAilments,
      String height,
      String name,
      String weight,
      String image,
      List<List<double>> faceEmbeddings,
      List<List<double>> noseEmbeddings,
      String date,
      ) async {
    try {
      // Convert nested lists to serializable format
      final serializedFaceEmbeddings = faceEmbeddings.asMap().map(
            (index, embedding) => MapEntry(index.toString(), embedding),
      );

      final serializedNoseEmbeddings = noseEmbeddings.asMap().map(
            (index, embedding) => MapEntry(index.toString(), embedding),
      );

      await cattleCollection.add({
        "name": name,
        "age": age,
        "weight(kg)": weight,
        "height(m)": height,
        "breed": breed,
        "diet": '',
        "sex": sex,
        "diseases/ailments": diseasesAilments,
        "location": '',
        'image': image,
        'faceEmbeddings': serializedFaceEmbeddings,
        'noseEmbeddings': serializedNoseEmbeddings,
        "ownerUid": currentUser?.uid,
        "dateAdded": date,
      });
    } catch (e, stack) {
      debugPrint('Error creating cattle: $e\n$stack');
      rethrow;
    }
  }

  getCattleUpdates() {
    return cattleCollection
        .where('ownerUid', isEqualTo: currentUser?.uid)
        .orderBy("dateAdded", descending: true)
        .limit(3)
        .snapshots();
  }
  getCattleUpdates2() {
    return cattleCollection
        .where('ownerUid', isEqualTo: currentUser?.uid)
        .orderBy("dateAdded", descending: true)
        .snapshots();
  }
  getAllCattle(){
    return cattleCollection
        .orderBy("date", descending:true)
        .get();
  }
  // for identifying cattle we need static snapshot
  getAllSingleUserCattle() {
    return cattleCollection
        .where('ownerUid', isEqualTo: currentUser?.uid)
        // .orderBy("date", descending: true)
        .get();
  }

  streamAllSingleUserCattle() {
    return cattleCollection
        .where('ownerUid', isEqualTo: currentUser?.uid)
        .orderBy("date", descending: true)
        .snapshots();
  }

  getSingleCow(docId) {
    return cattleCollection.doc(docId).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data;
    });
  }

  uploadImage(
      img,
      String age,
      String breed,
      String sex,
      String diseasesAilments,
      String height,
      String name,
      String weight,
      List<List<double>> faceEmbeddings,
      List<List<double>>  noseEmbeddings) async {
    var random = Random();
    var rand = random.nextInt(1000000000);
    // Give the image a random name
    String image_name = "image:$rand";
    try {
      final ext = extension(img.path);
      final image = storageRef.ref("cow-images").child('$image_name$ext');
      await image.putFile(img);
      String url = await image.getDownloadURL();
      print(url);
      DateTime _date = DateTime.now();
      createCattle(age, breed, sex, diseasesAilments, height, name, weight, url,
          faceEmbeddings, noseEmbeddings, _date.toString());
      return ("Uploaded image");
      print("Uploaded image");
      // ignore: nullable_type_in_catch_clause
    } on FirebaseException catch (e) {
      print(e);
      return ("error");
    }
  }
}
