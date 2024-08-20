import 'package:firebase_auth/firebase_auth.dart';
import 'package:inkombe_flutter/services/database_service.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithEmailAndPassword(String email, String password) async{
    try{
      User user =(await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      return true;
    } on FirebaseAuthException catch (e){
      print(e);
      return(e.message);
    }
  }

  Future signOutUser() async {
    FirebaseAuth.instance.signOut();
  }
  Future signUpUserWithEmailAndPassword(String email, String password) async{
    try{
      User user =(await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
     DatabaseService(uid: user.uid).savingUserData(email);
      return true;
    } on FirebaseAuthException catch (e){
      return(e.message);
    }
  }



}