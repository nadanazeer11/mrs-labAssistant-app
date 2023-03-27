import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
FirebaseFirestore _db=FirebaseFirestore.instance;
Future<String>getLoggedInName()async{
  try{
    User? user=FirebaseAuth.instance.currentUser;
    debugPrint(user?.email);
    QuerySnapshot querySnapshot=await _db.collection('users').where(
        'email',isEqualTo: user?.email).limit(1).get();
    DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
    if(documentSnapshot.exists){
      Map<String,dynamic> data=documentSnapshot.data() as Map<String,dynamic>;
      return data['name'] as String;
    }
    else{
      return "none";
    }
  }
  catch(e){
    throw Exception("d");
  }
}
Future<String>getIdofUser() async{
  try{
    User? user=FirebaseAuth.instance.currentUser;
    debugPrint(user?.email);
    QuerySnapshot querySnapshot=await _db.collection('users').where(
        'email',isEqualTo: user?.email).limit(1).get();
    DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
    return documentSnapshot.id;
  }
  catch(e){
    throw Exception("d");
  }

}
Future<String> getPassword()async{
  try{
    User? user=FirebaseAuth.instance.currentUser;
    debugPrint(user?.email);
    QuerySnapshot querySnapshot=await _db.collection('users').where(
        'email',isEqualTo: user?.email).limit(1).get();
    DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
    return documentSnapshot.get('password');
  }
  catch(e){
    throw Exception("d");
  }
}
Future<String> getemail()async{
  try{
    User? user=FirebaseAuth.instance.currentUser;
    debugPrint(user?.email);
    QuerySnapshot querySnapshot=await _db.collection('users').where(
        'email',isEqualTo: user?.email).limit(1).get();
    DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
    return documentSnapshot.get('email');
  }
  catch(e){
    throw Exception("d");
  }
}
