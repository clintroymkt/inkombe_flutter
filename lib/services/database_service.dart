import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService{
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
      'admin' : false //super user access
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

//   create cattle
Future createCattle(
    String userDocId,
    Int age,
    String breed,
    String diet,
    String diseasesAilments,
    Float height,
    String location,
    String modelId,
    String name,
    String owner,
    String weight)
async {
  cattleCollection.add({
    "age": age,
    "breed":breed,
    "diet": diet,
    "diseases/ailments": diseasesAilments,
    "height(m)": height,
    "location": location,
    "name":name,
    "owner":owner,
    "weight(kg)":weight,
    "model_id": "",
    "owner_uid": currentUser?.uid
  }
  ).then((docRef)=>{
      userCollection.doc(userDocId).update(
        {
          "cattle":FieldValue.arrayUnion([docRef.id]) //add cattle to user document
          //don't forget to remove when deleting cattle
        }
      )

  });
}
  getCattleUpdates() {
    return cattleCollection.where('ownerUid', isEqualTo: currentUser?.uid).orderBy("date", descending: true).snapshots();
  }

  getSingleCow(docId){
    return cattleCollection.doc(docId).get().then((DocumentSnapshot doc){
      final data = doc.data() as Map<String, dynamic>;
      return data;
    });
  }


}