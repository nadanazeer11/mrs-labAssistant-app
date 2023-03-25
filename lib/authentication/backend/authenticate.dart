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
      final User? currentUser = auth.currentUser;
      userCredential = await auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
      await _db.collection('users').add({
        "email":user.email,
        "password":user.password,
        "name":user.name,
        "projects":user.projects,
        "tasks":user.tasks,
        "createP":user.createP,
        "addU":user.addU
      });
      // final User ?newUser = userCredential.user;
      // await auth.signOut();

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
      debugPrint("email $email");
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
  // Future<bool> checkPass(String? uid) async{
  //   try{
  //     DocumentSnapshot x=await _db.collection('users').doc(uid).get();
  //     String pass=x.get('p')
  //   }
  // }

  // Future<bool> changePassword(String currentPassword, String newPassword,String ? uid) async {
  //   bool success = false;
  //
  //   //Create an instance of the current user.
  //   var user = FirebaseAuth.instance.currentUser!;
  //   //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.
  //
  //   final cred = await EmailAuthProvider.credential(email: user.email!, password: currentPassword);
  //   await user.reauthenticateWithCredential(cred).then((value) async {
  //     await user.updatePassword(newPassword).then((_) {
  //       success = true;
  //       _db.collection('users').doc(uid).update({"password": newPassword});
  //     }).catchError((error) {
  //       print(error);
  //     });
  //   }).catchError((err) {
  //     print(err);
  //   });
  //
  //   return success;
  // }


  Future<FirebaseAuthException?> changePassword(String currentPassword, String newPassword, String? uid) async {
    var user = FirebaseAuth.instance.currentUser!;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    try {
      await user.reauthenticateWithCredential(cred);
      try {
        await user.updatePassword(newPassword);
        try {
          await _db.collection('users').doc(uid).update({"password": newPassword});
        } catch (e) {
          print('An error occurred while updating the password in Firestore: $e');
          throw Exception("");
        }
      } on FirebaseAuthException catch (e) {
        print('An error occurred while updating the password: $e');
        return e;
      }
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        print('The current password is incorrect');

      } else {
        print('An error occurred while re-authenticating the user: $e');

      }
      return e;
    }





  }

}
