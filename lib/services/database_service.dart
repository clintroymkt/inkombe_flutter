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
    String age,
    String breed,
    String diet,
    String diseasesAilments,
    String height,
    String name,
    String weight)
async {
  cattleCollection.add({
    "age": age,
    "breed":breed,
    "diet": diet,
    "date":'',
    "diseases/ailments": diseasesAilments,
    "height(m)": height,
    "location": '',
    "name":name,
    "weight(kg)":weight,
    'image':'',
    "ownerUid": currentUser?.uid,

  }
  ).then((docRef)=>{
    // userDocId = userCollection.doc().
    //   userCollection.where(
    //     {
    //       "cattle":FieldValue.arrayUnion([docRef.id]) //add cattle to user document
    //       //don't forget to remove when deleting cattle
    //     }
    //   )


  });
}
  getCattleUpdates() {
    return cattleCollection.where('ownerUid', isEqualTo: currentUser?.uid).orderBy("date", descending: true).limit(3).snapshots();
  }

  getAllCattle() {
    return cattleCollection.where('ownerUid', isEqualTo: currentUser?.uid).orderBy("date", descending: true).snapshots();
  }

  getSingleCow(docId){
    return cattleCollection.doc(docId).get().then((DocumentSnapshot doc){
      final data = doc.data() as Map<String, dynamic>;
      return data;
    });
  }


}