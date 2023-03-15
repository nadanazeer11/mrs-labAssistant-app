import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrs/models/Users.dart';
import 'package:velocity_x/velocity_x.dart';
class Authenticate{
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore _db=FirebaseFirestore.instance;
  Future<bool> signupMethod(Userr user) async {
    UserCredential? userCredential;
    try {
      userCredential =
      await auth.createUserWithEmailAndPassword(
          email: user.email, password: user.password);
      await _db.collection('users').add({
        "email":user.email,
        "password":user.password,
        "name":user.name,
        "projects":user.projects,
        "tasks":user.tasks
      });
     return true;
    }
    catch(e) {
      throw Exception('Error Checking if user exists');
    }

  }
  Future<bool> userNameCheck(String name) async{
    try{
      final querySnapshot=await _db.collection('users').where('name',isEqualTo: name).get();
      return querySnapshot.docs.isNotEmpty;
    }
    catch(e){
      throw Exception('Error Checking if user exists');
    }
  }
  Future<bool> emailCheck(String email) async{
    try{
      final querySnapshot=await _db.collection('users').where('email',isEqualTo: email).get();
      return querySnapshot.docs.isNotEmpty;
    }
    catch(e){
      throw Exception('Error Checking if user exists');
    }
  }
  FutureOr<FirebaseAuthException?> loginMethod(String email,String password)async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseAuthException catch (e) {
      return e;
    }
    return null;
  }
  Future<void>logoutMethod()async{
    try{
      await auth.signOut();
    }
    catch(e){
      throw Exception("cant signout");
    }
  }
}
